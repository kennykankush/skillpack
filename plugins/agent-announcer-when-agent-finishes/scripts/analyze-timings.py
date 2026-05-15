#!/usr/bin/env python3
"""Summarize agent-announcer timing logs.

Default input is the machine-readable JSONL emitted by announce.sh. The optional
legacy parser can also estimate old Qwen timings from /tmp/tab-tts.log, but those
records are second-granularity and do not include playback duration.
"""

from __future__ import annotations

import argparse
import datetime as dt
import json
import re
import statistics
import sys
from collections import Counter, defaultdict
from pathlib import Path
from typing import Any


DEFAULT_TIMING_LOG = Path("/tmp/tab-tts-timings.jsonl")
DEFAULT_LEGACY_LOG = Path("/tmp/tab-tts.log")

METRICS = (
    "hook_sync_ms",
    "summary_ms",
    "tts_ms",
    "total_to_audio_ready_ms",
    "total_to_play_done_ms",
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Summarize agent-announcer TTS timing JSONL."
    )
    parser.add_argument(
        "timing_log",
        nargs="?",
        default=str(DEFAULT_TIMING_LOG),
        help=f"JSONL timing log path (default: {DEFAULT_TIMING_LOG})",
    )
    parser.add_argument(
        "--legacy-log",
        nargs="?",
        const=str(DEFAULT_LEGACY_LOG),
        help=(
            "Also estimate old runs from /tmp/tab-tts.log, or pass a custom "
            "legacy human-log path."
        ),
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="Include failed provider attempts in the metric tables.",
    )
    parser.add_argument(
        "--limit",
        type=int,
        default=8,
        help="Number of slowest records to show (default: 8).",
    )
    parser.add_argument(
        "--legacy-max-age-sec",
        type=int,
        default=180,
        help="Ignore legacy provider pairings older than this many seconds (default: 180).",
    )
    return parser.parse_args()


def load_jsonl(path: Path) -> list[dict[str, Any]]:
    if not path.exists():
        return []

    rows: list[dict[str, Any]] = []
    with path.open("r", encoding="utf-8") as handle:
        for line_no, line in enumerate(handle, start=1):
            line = line.strip()
            if not line:
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError as exc:
                print(f"warning: skipped malformed JSONL line {line_no}: {exc}", file=sys.stderr)
                continue
            record.setdefault("_source", str(path))
            rows.append(record)
    return rows


def parse_legacy_ts(raw: str) -> dt.datetime | None:
    # Existing human logs have appeared in both:
    # [Sat 16 May 2026 02:50:00 CST]
    # [Sat May 16 02:53:16 CST 2026]
    parts = [part for part in raw.split() if not re.fullmatch(r"[A-Z]{2,5}", part)]
    cleaned = " ".join(parts)
    for fmt in ("%a %d %b %Y %H:%M:%S", "%a %b %d %H:%M:%S %Y"):
        try:
            return dt.datetime.strptime(cleaned, fmt)
        except ValueError:
            pass
    return None


def parse_key_values(message: str) -> dict[str, str]:
    values: dict[str, str] = {}
    for key, value in re.findall(r"([a-zA-Z_]+)=([^ ]+)", message):
        values[key] = value.strip()
    return values


def parse_legacy_log(path: Path, max_age_sec: int) -> list[dict[str, Any]]:
    if not path.exists():
        return []

    timestamped = re.compile(r"^\[(?P<ts>[^\]]+)\]\s+(?P<message>.*)$")
    open_runs: list[dict[str, Any]] = []
    rows: list[dict[str, Any]] = []

    with path.open("r", encoding="utf-8", errors="replace") as handle:
        for line in handle:
            match = timestamped.match(line.rstrip("\n"))
            if not match:
                continue
            ts = parse_legacy_ts(match.group("ts"))
            if ts is None:
                continue
            message = match.group("message")

            if "invoker=" in message and "stdin_len=" in message:
                values = parse_key_values(message)
                open_runs.append(
                    {
                        "ts": ts.isoformat(),
                        "run_id": f"legacy-{int(ts.timestamp())}-{len(open_runs)}",
                        "invoker": values.get("invoker", ""),
                        "cwd": values.get("pwd", ""),
                        "term": values.get("term", ""),
                        "mode": values.get("mode", ""),
                        "stdin_len": int(values.get("stdin_len", "0") or 0),
                        "_legacy_start": ts,
                        "_source": str(path),
                        "legacy_estimate": True,
                    }
                )
                continue

            if not open_runs:
                continue

            if "final tab=[" in message:
                for run in reversed(open_runs):
                    if "tab" not in run:
                        tab_match = re.search(r"final tab=\[([^\]]*)\]", message)
                        run["tab"] = tab_match.group(1) if tab_match else ""
                        run["_tab_ts"] = ts
                        break
                continue

            if "msg_len=" in message:
                for run in reversed(open_runs):
                    if "_msg_ts" not in run:
                        values = parse_key_values(message)
                        run["last_msg_len"] = int(values.get("msg_len", "0") or 0)
                        run["user_msg_len"] = int(values.get("user_msg_len", "0") or 0)
                        run["_msg_ts"] = ts
                        break
                continue

            if "summary_base=" in message:
                for run in reversed(open_runs):
                    if "_summary_ts" not in run:
                        values = parse_key_values(message)
                        run["summary_base_url"] = values.get("summary_base", "")
                        run["summary_model"] = values.get("model", "")
                        run["summary_attempted"] = 1
                        run["summary_status"] = "legacy_unknown"
                        run["_summary_ts"] = ts
                        break
                continue

            if 'phrase="' in message:
                for run in reversed(open_runs):
                    if "_phrase_ts" not in run:
                        phrase = message.split('phrase="', 1)[1].rsplit('"', 1)[0]
                        run["phrase_chars"] = len(phrase)
                        run["_phrase_ts"] = ts
                        break
                continue

            if "tts_provider=" in message:
                run_index = None
                for index, run in enumerate(open_runs):
                    if (
                        "_phrase_ts" in run
                        and "provider" not in run
                        and (ts - run["_phrase_ts"]).total_seconds() <= max_age_sec
                    ):
                        run_index = index
                        break
                if run_index is None:
                    continue

                run = open_runs.pop(run_index)
                values = parse_key_values(message)
                provider = values.get("tts_provider", "unknown")
                start = run.pop("_legacy_start")
                phrase_ts = run.pop("_phrase_ts")
                tab_ts = run.pop("_tab_ts", start)
                msg_ts = run.pop("_msg_ts", tab_ts)
                summary_ts = run.pop("_summary_ts", phrase_ts)
                run.update(
                    {
                        "status": "success",
                        "provider": provider,
                        "model": values.get("model", "legacy_unknown"),
                        "source": values.get("voice", values.get("audio", "")),
                        "audio": values.get("audio", ""),
                        "hook_sync_ms": int((msg_ts - start).total_seconds() * 1000),
                        "tab_detect_ms": int((tab_ts - start).total_seconds() * 1000),
                        "message_extract_ms": int((msg_ts - tab_ts).total_seconds() * 1000),
                        "summary_ms": max(0, int((summary_ts - msg_ts).total_seconds() * 1000)),
                        "tts_ms": int((ts - phrase_ts).total_seconds() * 1000),
                        "total_to_audio_ready_ms": int((ts - start).total_seconds() * 1000),
                    }
                )
                rows.append(run)

    return rows


def number(record: dict[str, Any], key: str) -> float | None:
    value = record.get(key)
    if isinstance(value, bool) or value is None:
        return None
    if isinstance(value, (int, float)):
        return float(value)
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def percentile(values: list[float], pct: float) -> float | None:
    if not values:
        return None
    values = sorted(values)
    if len(values) == 1:
        return values[0]
    pos = (len(values) - 1) * (pct / 100.0)
    lower = int(pos)
    upper = min(lower + 1, len(values) - 1)
    if lower == upper:
        return values[lower]
    return values[lower] + (values[upper] - values[lower]) * (pos - lower)


def fmt_ms(value: float | None) -> str:
    if value is None:
        return "-"
    if value >= 1000:
        return f"{value / 1000:.2f}s"
    return f"{value:.0f}ms"


def table(headers: list[str], rows: list[list[str]]) -> str:
    widths = [len(header) for header in headers]
    for row in rows:
        for index, cell in enumerate(row):
            widths[index] = max(widths[index], len(cell))
    output = []
    output.append("  ".join(header.ljust(widths[index]) for index, header in enumerate(headers)))
    output.append("  ".join("-" * width for width in widths))
    for row in rows:
        output.append("  ".join(cell.ljust(widths[index]) for index, cell in enumerate(row)))
    return "\n".join(output)


def metric_summary(records: list[dict[str, Any]]) -> list[list[str]]:
    rows = []
    for metric in METRICS:
        values = [value for record in records if (value := number(record, metric)) is not None]
        if not values:
            continue
        rows.append(
            [
                metric,
                str(len(values)),
                fmt_ms(min(values)),
                fmt_ms(statistics.median(values)),
                fmt_ms(percentile(values, 90)),
                fmt_ms(max(values)),
            ]
        )
    return rows


def provider_summary(records: list[dict[str, Any]]) -> list[list[str]]:
    groups: dict[tuple[str, str], list[dict[str, Any]]] = defaultdict(list)
    for record in records:
        groups[(str(record.get("provider", "")), str(record.get("model", "")))].append(record)

    rows = []
    for (provider, model), group in sorted(groups.items(), key=lambda item: (-len(item[1]), item[0])):
        audio = [value for record in group if (value := number(record, "total_to_audio_ready_ms")) is not None]
        tts = [value for record in group if (value := number(record, "tts_ms")) is not None]
        summary = [value for record in group if (value := number(record, "summary_ms")) is not None]
        chars = [value for record in group if (value := number(record, "phrase_chars")) is not None]
        rows.append(
            [
                provider or "-",
                model or "-",
                str(len(group)),
                fmt_ms(statistics.median(audio) if audio else None),
                fmt_ms(percentile(audio, 90) if audio else None),
                fmt_ms(statistics.median(tts) if tts else None),
                fmt_ms(statistics.median(summary) if summary else None),
                str(round(statistics.median(chars))) if chars else "-",
            ]
        )
    return rows


def slowest(records: list[dict[str, Any]], limit: int) -> list[list[str]]:
    ranked = sorted(
        records,
        key=lambda record: number(record, "total_to_audio_ready_ms") or -1,
        reverse=True,
    )
    rows = []
    for record in ranked[:limit]:
        rows.append(
            [
                str(record.get("ts", "")),
                str(record.get("provider", "")),
                str(record.get("status", "")),
                fmt_ms(number(record, "total_to_audio_ready_ms")),
                fmt_ms(number(record, "tts_ms")),
                fmt_ms(number(record, "summary_ms")),
                str(record.get("phrase_chars", "-")),
                str(record.get("run_id", "")),
            ]
        )
    return rows


def main() -> int:
    args = parse_args()
    records = load_jsonl(Path(args.timing_log))
    if args.legacy_log:
        records.extend(parse_legacy_log(Path(args.legacy_log), args.legacy_max_age_sec))

    if not records:
        print("No timing records found.")
        print(f"Expected JSONL at: {args.timing_log}")
        if not args.legacy_log:
            print("Tip: add --legacy-log to estimate from /tmp/tab-tts.log.")
        return 1

    status_counts = Counter(str(record.get("status", "unknown")) for record in records)
    provider_counts = Counter(str(record.get("provider", "none")) for record in records)
    metric_records = [
        record
        for record in records
        if args.all or str(record.get("status", "")) == "success"
    ]
    metric_records = [record for record in metric_records if number(record, "total_to_audio_ready_ms") is not None]

    print(f"records: {len(records)}")
    print("status: " + ", ".join(f"{key}={value}" for key, value in sorted(status_counts.items())))
    print("provider: " + ", ".join(f"{key}={value}" for key, value in sorted(provider_counts.items())))
    if any(record.get("legacy_estimate") for record in records):
        print("note: legacy rows are second-granularity estimates and exclude playback duration.")
    print()

    rows = metric_summary(metric_records)
    if rows:
        print(table(["metric", "n", "min", "p50", "p90", "max"], rows))
        print()

    rows = provider_summary(metric_records)
    if rows:
        print(
            table(
                ["provider", "model", "n", "audio p50", "audio p90", "tts p50", "summary p50", "chars p50"],
                rows,
            )
        )
        print()

    rows = slowest(metric_records, args.limit)
    if rows:
        print(table(["ts", "provider", "status", "audio", "tts", "summary", "chars", "run_id"], rows))

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
