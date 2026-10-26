#!/usr/bin/env python3
"""Probe local recordings and extract review samples without changing sources."""

import argparse
import hashlib
import json
import math
from pathlib import Path
import re
import shutil
import subprocess
import sys


def file_hash(path):
    digest = hashlib.sha256()
    with path.open("rb") as source:
        for chunk in iter(lambda: source.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def probe(path):
    result = subprocess.run(
        [
            "ffprobe", "-v", "error", "-show_entries",
            "stream=index,codec_type,codec_name,width,height,avg_frame_rate,"
            "r_frame_rate,duration,sample_rate,channels,bit_rate:"
            "format=duration,size,bit_rate", "-of", "json", str(path),
        ],
        capture_output=True, text=True, check=True,
    )
    metadata = json.loads(result.stdout)
    video = next(
        (s for s in metadata.get("streams", []) if s.get("codec_type") == "video"),
        None,
    )
    if video is None:
        raise ValueError(f"No video stream: {path}")
    duration = None
    for value in (video.get("duration"), metadata.get("format", {}).get("duration")):
        try:
            candidate = float(value)
        except (ValueError, TypeError):
            continue
        if math.isfinite(candidate) and candidate > 0:
            duration = candidate
            break
    if duration is None:
        raise ValueError(f"No usable duration: {path}")
    return metadata, video, duration


def sample_times(duration, interval, extras):
    for value in extras:
        if not math.isfinite(value) or not 0 <= value < duration:
            raise ValueError(f"Sample time {value} is outside [0, {duration})")
    times = {round(i * interval, 6) for i in range(math.ceil(duration / interval))}
    times.update(round(value, 6) for value in extras)
    # Include a near-ending image without seeking beyond the last decoded frame.
    times.add(round(max(0, duration - 0.25), 6))
    return sorted(time for time in times if time < duration)


def save_manifest(path, data):
    pending = path.with_suffix(".tmp")
    pending.write_text(json.dumps(data, indent=2) + "\n")
    pending.replace(path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("videos", nargs="+", type=Path)
    parser.add_argument("--output", required=True, type=Path, help="New study directory.")
    parser.add_argument("--interval", type=float, default=5.0, help="Seconds per sample.")
    parser.add_argument("--at", action="append", type=float, default=[], help="Extra time; repeatable.")
    parser.add_argument("--probe-only", action="store_true")
    parser.add_argument("--max-samples", type=int, default=1000, help="Per-video extraction limit.")
    args = parser.parse_args()
    if not math.isfinite(args.interval) or args.interval <= 0:
        parser.error("--interval must be finite and positive")
    if args.max_samples <= 0:
        parser.error("--max-samples must be positive")
    needed = ["ffprobe"] + ([] if args.probe_only else ["ffmpeg"])
    for command in needed:
        if shutil.which(command) is None:
            parser.error(f"Required local tool not found: {command}")
    output = args.output.expanduser().resolve()
    if output.exists():
        parser.error("--output must be a new directory; existing studies are preserved")

    prepared = []
    for index, supplied in enumerate(args.videos, 1):
        source = supplied.expanduser().resolve(strict=True)
        if not source.is_file():
            raise ValueError(f"Not a file: {source}")
        metadata, video, duration = probe(source)
        # Check count before allocating a potentially huge sampling list.
        estimated = math.ceil(duration / args.interval) + len(args.at) + 1
        if not args.probe_only and estimated > args.max_samples:
            parser.error(f"{source.name}: sample limit exceeded; adjust interval or --max-samples")
        times = [] if args.probe_only else sample_times(duration, args.interval, args.at)
        slug = re.sub(r"[^a-z0-9]+", "-", source.stem.lower()).strip("-") or "video"
        prepared.append({
            "id": f"{index:02d}-{slug}", "source": str(source),
            "source_sha256": file_hash(source), "duration_seconds": duration,
            "video_stream": video, "probe": metadata, "samples": [],
            "review_status": "not-reviewed", "planned_times_seconds": times,
        })

    output.mkdir(parents=True, exist_ok=False)
    manifest = {
        "status": "extracting", "interval_seconds": args.interval,
        "time_note": "Times are requested seek positions, not measured frame presentation timestamps.",
        "review_note": "Extracted images must be inspected; extraction is not video review.",
        "videos": prepared,
    }
    manifest_path = output / "manifest.json"
    save_manifest(manifest_path, manifest)
    try:
        for item in prepared:
            folder = output / item["id"]
            folder.mkdir()
            for index, timestamp in enumerate(item["planned_times_seconds"]):
                frame = folder / f"frame-{index:06d}.png"
                subprocess.run(
                    [
                        "ffmpeg", "-v", "error", "-nostdin", "-n", "-ss", str(timestamp),
                        "-i", item["source"], "-map", "0:v:0", "-frames:v", "1", str(frame),
                    ],
                    capture_output=True, text=True, check=True,
                )
                if not frame.is_file() or frame.stat().st_size == 0:
                    raise RuntimeError(f"No frame at requested time {timestamp}: {item['source']}")
                item["samples"].append({
                    "requested_time_seconds": timestamp,
                    "image": str(frame.relative_to(output)), "review_status": "not-reviewed",
                })
                save_manifest(manifest_path, manifest)
        manifest["status"] = "probed" if args.probe_only else "samples-extracted"
        save_manifest(manifest_path, manifest)
    except Exception as error:
        manifest["status"] = "failed"
        manifest["error"] = str(error)
        save_manifest(manifest_path, manifest)
        raise
    print(json.dumps({
        "manifest": str(manifest_path), "videos": len(prepared),
        "samples": sum(len(item["samples"]) for item in prepared),
        "review_status": "not-reviewed",
    }))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, RuntimeError, subprocess.CalledProcessError) as error:
        print(f"study_video: {error}", file=sys.stderr)
        sys.exit(1)
