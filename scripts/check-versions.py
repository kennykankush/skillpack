#!/usr/bin/env python3
"""Fail if any plugin's plugin.json version/description drifts from marketplace.json."""
import json, pathlib, sys

root = pathlib.Path(__file__).resolve().parent.parent
catalog = {p["name"]: p for p in json.loads((root / ".claude-plugin/marketplace.json").read_text())["plugins"]}
errors = []
for pj in sorted(root.glob("plugins/*/.claude-plugin/plugin.json")):
    plugin = json.loads(pj.read_text())
    entry = catalog.get(plugin["name"])
    if entry is None:
        errors.append(f"{plugin['name']}: not listed in marketplace.json")
        continue
    if entry["version"] != plugin["version"]:
        errors.append(f"{plugin['name']}: plugin.json {plugin['version']} != marketplace.json {entry['version']}")
    cj = pj.parent.parent / ".codex-plugin/plugin.json"
    if cj.exists():
        cv = json.loads(cj.read_text()).get("version")
        if cv and cv.split("+")[0] != plugin["version"]:
            errors.append(f"{plugin['name']}: .codex-plugin {cv} != .claude-plugin {plugin['version']}")
if errors:
    print("version drift:\n  " + "\n  ".join(errors), file=sys.stderr)
    sys.exit(1)
print("versions in sync")
