#!/usr/bin/env python3
"""Progress telemetry for a watched goal: the checkpoint bar, planned against actual,
and a forecast recalculated from the observed speed.

    progress.py TRACKER.json                    print the progress block
    progress.py TRACKER.json --done N           record checkpoint N done now, then print
    progress.py TRACKER.json --add "NAME" --est HOURS [--after N]
                                                add a checkpoint found after the plan
    progress.py TRACKER.json --now YYYY-MM-DDTHH:MM   print as of a given time
    progress.py TRACKER.json --doing "TEXT" --by NAME [--checkpoint N]
                                                say what NAME is working on now
    progress.py TRACKER.json --idle --by NAME   clear NAME's "now" line
    progress.py TRACKER.json --done N --by NAME record N done by NAME (unverified)
    progress.py TRACKER.json --verified N --by NAME
                                                record that NAME checked N independently

A checkpoint the builder ticks with --by stays "awaiting check" until another session
records --verified: a claim and a confirmation are different facts, and a reader of the
tracker (the agendas pane) shows which is which. Writers take a lock on TRACKER.lock and
replace the file whole, so two sessions updating one tracker cannot lose each other's change.

Times are local wall-clock times without a zone. Set TZ (or the tracker's "tz", an IANA
name such as "Europe/London") so "now" and every recorded time come from the clock,
never from a typed value.

Speed is (estimated hours + prior) / (actual hours + prior) over checkpoints finished
after the plan was set. The prior (default one hour) keeps a single quick checkpoint from
swinging the forecast. Two forecasts are printed: at the observed speed, and a cautious
one at the plan's own speed. Gated checkpoints (waiting on the user) are listed apart and
left out of both.
"""
import argparse
import fcntl
import json
import os
import tempfile
from datetime import datetime, timedelta

FMT = "%Y-%m-%dT%H:%M"


def now_for(tracker, override):
    if override:
        return datetime.strptime(override, FMT)
    tz = tracker.get("tz")
    if tz:
        os.environ["TZ"] = tz
        try:
            import time
            time.tzset()
        except AttributeError:
            pass
    return datetime.now().replace(second=0, microsecond=0)


def parse(value):
    return datetime.strptime(value, FMT) if value else None


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("tracker")
    ap.add_argument("--now")
    ap.add_argument("--done", type=int, help="record checkpoint N as done at the clock's time")
    ap.add_argument("--add", help="name of a checkpoint found after the plan")
    ap.add_argument("--est", type=float, help="estimated hours for --add")
    ap.add_argument("--after", type=int, help="insert the added checkpoint after checkpoint N")
    ap.add_argument("--by", help="who is writing: a session name such as EXEUCTION")
    ap.add_argument("--doing", help="what --by is working on now, shown live by the agendas pane")
    ap.add_argument("--checkpoint", type=int, help="the checkpoint --doing belongs to")
    ap.add_argument("--idle", action="store_true", help="clear --by's \"now\" line")
    ap.add_argument("--verified", type=int, help="record checkpoint N as independently checked")
    args = ap.parse_args()
    if (args.doing or args.idle or args.verified is not None) and not args.by:
        raise SystemExit("--doing, --idle and --verified need --by NAME.")

    writes = args.done is not None or args.add or args.doing or args.idle or args.verified is not None
    lock = open(args.tracker + ".lock", "a") if writes else None
    if lock:
        fcntl.flock(lock, fcntl.LOCK_EX)
    # Read under the lock, so a write never starts from a copy another session has since replaced.
    with open(args.tracker) as f:
        tracker = json.load(f)
    now = now_for(tracker, args.now)
    cps = tracker["checkpoints"]
    changed = False

    if args.done is not None:
        target = next((c for c in cps if c["n"] == args.done), None)
        if target is None:
            raise SystemExit(f"No checkpoint {args.done} in the tracker.")
        target["actual"] = now.strftime(FMT)
        if args.by:
            target["doneBy"] = args.by
        changed = True
    if args.verified is not None:
        target = next((c for c in cps if c["n"] == args.verified), None)
        if target is None:
            raise SystemExit(f"No checkpoint {args.verified} in the tracker.")
        if not target.get("actual"):
            raise SystemExit(f"Checkpoint {args.verified} is not done yet; there is nothing to verify.")
        if target.get("doneBy") == args.by:
            raise SystemExit(f"{args.by} ticked checkpoint {args.verified}; it cannot also verify it.")
        target["verified"] = now.strftime(FMT)
        target["verifiedBy"] = args.by
        changed = True
    if args.doing:
        tracker["now"] = {"by": args.by, "doing": args.doing, "updated": now.strftime(FMT)}
        if args.checkpoint is not None:
            tracker["now"]["checkpoint"] = args.checkpoint
        changed = True
    if args.idle and (tracker.get("now") or {}).get("by") == args.by:
        tracker.pop("now", None)
        changed = True
    if args.add:
        if args.est is None:
            raise SystemExit("--add needs --est HOURS.")
        entry = {"n": max(c["n"] for c in cps) + 1, "name": f"(added {now:%H:%M}) {args.add}",
                 "estHours": args.est, "planned": None, "actual": None, "addedAfterPlan": True}
        index = len(cps)
        if args.after is not None:
            index = next(i for i, c in enumerate(cps) if c["n"] == args.after) + 1
        cps.insert(index, entry)
        changed = True
    if changed:
        folder = os.path.dirname(os.path.abspath(args.tracker))
        fd, tmp = tempfile.mkstemp(prefix=".tracker-", suffix=".json", dir=folder)
        with os.fdopen(fd, "w") as f:
            json.dump(tracker, f, indent=2)
            f.write("\n")
        os.replace(tmp, args.tracker)
    if lock:
        fcntl.flock(lock, fcntl.LOCK_UN)
        lock.close()

    hm = lambda d: d.strftime("%H:%M") if d.date() == now.date() else d.strftime("%d %b %H:%M")
    done = [c for c in cps if c.get("actual")]
    filled = round(20 * len(done) / len(cps))
    print(tracker.get("title") or tracker.get("agenda") or "Progress")
    print(f"  [{'#' * filled}{'-' * (20 - filled)}]  {len(done)} of {len(cps)} checkpoints")

    start, prior = parse(tracker["planStart"]), float(tracker.get("priorHours", 1.0))
    est_sum = act_sum = 0.0
    prev = start
    measured = 0
    for c in sorted((c for c in done if not c.get("preplan")), key=lambda c: parse(c["actual"])):
        finished = parse(c["actual"])
        took = max((finished - prev).total_seconds() / 3600, 0.0)
        prev = max(prev, finished)
        est_sum += c["estHours"]
        act_sum += took
        measured += 1
        if c.get("planned"):
            delta = (parse(c["planned"]) - finished).total_seconds() / 60
            when = f"planned {hm(parse(c['planned']))}, done {hm(finished)} ({abs(int(delta))} min {'early' if delta >= 0 else 'late'}; "
        else:
            when = f"added after the plan, done {hm(finished)} ("
        print(f"  #{c['n']:>2} {c['name']}: {when}took {took * 60:.0f} min vs {c['estHours'] * 60:.0f} estimated)")
    speed = (est_sum + prior) / (act_sum + prior)

    cursor = max(now, prev)
    remaining = [c for c in cps if not c.get("actual") and not (c.get("gated") or c.get("gate"))]
    if measured:
        print(f"  Speed: {speed:.2f}x the plan's, from {measured} checkpoint(s) since {hm(start)}")
    else:
        print("  Speed: the plan's own, until a checkpoint finishes")
    if not remaining:
        print("  Forecast: every checkpoint the agents can finish is done")
    else:
        fast = cursor + timedelta(hours=sum(c["estHours"] for c in remaining) / speed)
        slow = cursor + timedelta(hours=sum(c["estHours"] for c in remaining))
        planned_ends = [parse(c["planned"]) for c in cps if c.get("planned")]
        plan_end = max(planned_ends) if planned_ends else None
        vs = ""
        if plan_end:
            shift = (plan_end - fast).total_seconds() / 60
            vs = f" (planned {hm(plan_end)}; {abs(int(shift))} min {'ahead' if shift >= 0 else 'behind'})"
        print(f"  Forecast at the observed speed: the remaining {len(remaining)} done by {hm(fast)}{vs}")
        print(f"  Cautious forecast, at the plan's speed: done by {hm(slow)}")
        deadline = parse(tracker.get("deadline"))
        if deadline and now < deadline:
            t, by = cursor, len(done)
            for c in remaining:
                t = t + timedelta(hours=c["estHours"] / speed)
                by += t <= deadline
            print(f"  By {hm(deadline)}: {by} of {len(cps)} checkpoints")
    for c in cps:
        gate = c.get("gated") or c.get("gate")
        if gate and not c.get("actual"):
            print(f"  #{c['n']:>2} {c['name']}: waiting on {gate}")


if __name__ == "__main__":
    main()
