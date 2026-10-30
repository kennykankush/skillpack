#!/usr/bin/env python3
"""Check the frontend skill's infrastructure across Claude Code, Codex and Gemini.

Prints one line per item (OK / AUTH / MISSING / UPDATE / OFF) with the fix command,
then a summary. Read-only: it never installs anything. Exit code is 0 when everything
the current host needs is ready, 1 otherwise.

Usage: check.py [--host claude|codex|gemini|all] [--no-network]
"""
import json, os, re, shutil, subprocess, sys
from pathlib import Path

HOME = Path.home()
ARGS = sys.argv[1:]
HOST = ARGS[ARGS.index("--host") + 1] if "--host" in ARGS else "all"
NETWORK = "--no-network" not in ARGS

MCPS = {
    # name: (kind, target, note)
    "refero": ("http", "https://api.refero.design/mcp", "styles, screens, flows (paid)"),
    "mobbin": ("http", "https://api.mobbin.com/mcp", "screens, flows (paid)"),
    "lazyweb": ("http", "https://www.lazyweb.com/mcp", "screens, experiments"),
    "awwwards": ("stdio", "npx -y awwwards-mcp@1.14.0", "award-winning sites, motion capture (free)"),
    "madegood": ("http", "https://madegooddesigns.com/inspiration/mcp", "typography, brand (free)"),
    "chrome-devtools": ("stdio", "npx -y chrome-devtools-mcp@latest", "screenshots, computed CSS (free)"),
    "playwright": ("stdio", "npx -y @playwright/mcp@latest", "multi-viewport screenshots, flows (free)"),
    "better-icons": ("stdio", "npx -y better-icons", "200k+ icons via Iconify (free)"),
}
REQUIRED_MCPS = {"chrome-devtools"}  # the rest degrade gracefully

SKILLS = {
    # name: (required, source)
    "impeccable": (True, "npx impeccable install"),
    "emil-design-eng": (False, "npx skills add emilkowalski/skill"),
    "motion-director": (False, "https://github.com/frankxai/awesome-motion-design-agent-skills (skills/motion-director)"),
    "web-motion-auditor": (False, "https://github.com/frankxai/awesome-motion-design-agent-skills (skills/web-motion-auditor)"),
    "motion-design-lottie": (False, "https://github.com/lottiefiles/motion-design-skill (rename to motion-design-lottie)"),
    "design-motion-principles": (False, "npx skills add kylezantos/design-motion-principles"),
    "gsap-core": (False, "https://github.com/greensock/gsap-skills"),
    "ui-ux-pro-max": (False, "https://github.com/nextlevelbuilder/ui-ux-pro-max-skill (.claude/skills/ui-ux-pro-max)"),
    "refero-design": (False, "npx skills add https://github.com/referodesign/refero_skill --skill refero-design"),
    "better-icons": (False, "npx skills add better-auth/better-icons"),
}

REFS = HOME / ".agents/references/awesome-design-md"
TASTE = HOME / ".agents/taste/TASTE.md"
TEMPLATE = Path(__file__).resolve().parent.parent / "TASTE.template.md"

rows = []


def row(status, item, detail="", fix=""):
    rows.append((status, item, detail, fix))


def run(cmd, timeout=40):
    try:
        return subprocess.run(cmd, capture_output=True, text=True, timeout=timeout).stdout
    except Exception:
        return ""


def add_cmd(host, name):
    kind, target, _ = MCPS[name]
    if host == "claude":
        return f"claude mcp add --scope user --transport http {name} {target}" if kind == "http" else f"claude mcp add --scope user {name} -- {target}"
    if host == "codex":
        return f"codex mcp add {name} --url {target}" if kind == "http" else f"codex mcp add {name} -- {target}"
    entry = {"httpUrl": target} if kind == "http" else {"command": target.split()[0], "args": target.split()[1:]}
    return f'add "{name}": {json.dumps(entry)} under mcpServers in ~/.gemini/settings.json'


def check_claude():
    out = run(["claude", "mcp", "list"], timeout=90)
    for name in MCPS:
        line = next((l for l in out.splitlines() if l.startswith(name + ":")), "")
        if not line:
            row("MISSING", f"claude mcp {name}", MCPS[name][2], add_cmd("claude", name))
        elif "Connected" in line:
            row("OK", f"claude mcp {name}")
        elif "authentication" in line.lower():
            row("AUTH", f"claude mcp {name}", "needs login", "run /mcp in Claude Code and log in")
        else:
            row("OFF", f"claude mcp {name}", line.split(" - ")[-1].strip()[:60], "check with `claude mcp list`")


def check_codex():
    cfg = (HOME / ".codex/config.toml").read_text() if (HOME / ".codex/config.toml").exists() else ""
    for name in MCPS:
        if re.search(rf"^\[mcp_servers\.{re.escape(name)}\]", cfg, re.M):
            block = cfg.split(f"[mcp_servers.{name}]", 1)[1].split("\n[", 1)[0]
            row("OFF" if "enabled = false" in block else "OK", f"codex mcp {name}", "", "set enabled = true" if "enabled = false" in block else "")
        elif re.search(rf'^\[plugins\."{name}@[^"]+"\.mcp_servers\.{re.escape(name)}\]\nenabled = (\w+)', cfg, re.M):
            on = re.search(rf'^\[plugins\."{name}@[^"]+"\.mcp_servers\.{re.escape(name)}\]\nenabled = (\w+)', cfg, re.M).group(1) == "true"
            row("OK" if on else "OFF", f"codex mcp {name}", "via plugin", "" if on else f"set enabled = true under [plugins.\"{name}@...\".mcp_servers.{name}]")
        else:
            row("MISSING", f"codex mcp {name}", MCPS[name][2], add_cmd("codex", name))


def check_gemini():
    p = HOME / ".gemini/settings.json"
    servers = json.loads(p.read_text()).get("mcpServers", {}) if p.exists() else {}
    for name in MCPS:
        row("OK" if name in servers else "MISSING", f"gemini mcp {name}", "" if name in servers else MCPS[name][2],
            "" if name in servers else add_cmd("gemini", name) + "; then /mcp auth " + name)


def skill_dirs():
    dirs = [HOME / ".agents/skills", HOME / ".claude/skills", HOME / ".codex/skills", HOME / ".gemini/skills"]
    dirs += list((HOME / ".claude/plugins/cache").glob("*/*/*/skills"))
    return dirs


def check_skills():
    for name, (required, source) in SKILLS.items():
        found = next((d / name / "SKILL.md" for d in skill_dirs() if (d / name / "SKILL.md").exists()), None)
        if not found:
            row("MISSING", f"skill {name}", "required" if required else "optional", source)
            continue
        if name == "impeccable" and NETWORK:
            text = found.read_text()
            have = re.search(r"version:\s*([\d.]+)", text)
            latest = run(["npm", "view", "impeccable", "version"], timeout=20).strip()
            if have and latest and have.group(1) != latest:
                row("UPDATE", "skill impeccable", f"{have.group(1)} -> {latest}", "npx impeccable update")
                continue
        row("OK", f"skill {name}")


def check_files():
    if REFS.exists():
        n = len(list(REFS.glob("design-md/*/DESIGN.md")))
        row("OK", "brand systems", f"{n} DESIGN.md files")
    else:
        row("MISSING", "brand systems", "84 ready-made brand DESIGN.md files",
            f"git clone --depth 1 https://github.com/VoltAgent/awesome-design-md.git {REFS}")
    if TASTE.exists():
        row("OK", "taste memory", str(TASTE).replace(str(HOME), "~"))
    else:
        row("MISSING", "taste memory", "starts empty, learns from feedback",
            f"mkdir -p {TASTE.parent} && cp {TEMPLATE} {TASTE}")


hosts = {"claude": check_claude, "codex": check_codex, "gemini": check_gemini}
for h, fn in hosts.items():
    if HOST in (h, "all") and shutil.which(h):
        fn()
check_skills()
check_files()

w = max(len(r[1]) for r in rows)
for status, item, detail, fix in rows:
    print(f"{status:<8}{item:<{w + 2}}{detail}")
    if fix:
        print(f"{'':<8}{'':<{w + 2}}fix: {fix}")

problems = [r for r in rows if r[0] != "OK"]
blocking = [r for r in problems if r[0] in ("MISSING", "OFF") and (
    any(r[1].endswith(" " + m) for m in REQUIRED_MCPS) or (r[1].startswith("skill ") and SKILLS[r[1][6:]][0]))]
print(f"\n{len(rows) - len(problems)} ready, {len(problems)} need attention, {len(blocking)} blocking.")
sys.exit(1 if blocking else 0)
