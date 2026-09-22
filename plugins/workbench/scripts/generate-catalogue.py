#!/usr/bin/env python3
"""Regenerate ~/.agents/CATEGORIES.md from the live install state.

Sources of truth:
  - ~/.agents/skills/            flat skills (npx skills + local), lock at ~/.agents/.skill-lock.json
  - ~/.claude/plugins/           plugin-bundled skills (Claude-only mechanism)
  - ~/.claude/skills/lazyweb*    lazyweb's self-managed installer

Run after every install/uninstall. Referenced by workbench:skill-manager.
"""
import datetime
import glob
import json
import pathlib
import re

HOME = pathlib.Path.home()
AGENTS = HOME / ".agents"
CLAUDE = HOME / ".claude"

# Frontend is filed by STAGE OF THE JOB, not by topic — "when do I reach for this"
# is the question that keeps a large toolkit legible. Ordered: first match wins,
# so specific patterns go before generic ones.
CATEGORIES = [
    ("🎨 FRONTEND ① DECIDE — aesthetic direction, before any code",
     r"frontend-design|design-taste|high-end-visual|create-design-md|ui-skills-root"),
    ("🎨 FRONTEND ② BUILD — component craft and feel",
     r"emil-design|impeccable|component-design|design-system-patterns|composition-patterns"),
    ("🎨 FRONTEND ③ MOVE — motion and animation",
     r"motion|gsap|lottie|animate|interaction-design"),
    ("🎨 FRONTEND ④ FIX — upgrade what already exists",
     r"redesign-existing|improve-ui|baseline-ui|fluid-responsive|responsive-design"),
    ("🎨 FRONTEND ⑤ VERIFY — prove it is actually good",
     r"webapp-testing|playwright|browser|web-design-guidelines|web-quality|core-web-vitals|^seo$|best-practices|fixing-|accessib|vercel-|performance|dataviz"),
    ("✍️ WORDS — copy that does not read as AI",
     r"writing-guidelines|avoid-ai-writing|ai-writing|voice-preserving|false-positive|preservation-verifier|file-edit-in-place"),
    ("📊 DIAGRAMS", r"diagram"),
    ("🛡️ EVALS / SECURITY", r"promptfoo|security|redteam"),
    ("📱 MOBILE / NATIVE", r"mobile|react-native|ios|swift"),
    ("🔎 LAZYWEB", r"lazyweb"),
    ("🧠 MINE — workbench, agents, extra", r"workbench:|agents:|extra:"),
    ("🔧 INFRA", r"find-skills|codex:|lsp"),
    ("❓ OTHER", r"."),
]


def frontmatter(path):
    try:
        text = pathlib.Path(path).read_text(errors="replace")
    except OSError:
        return None, ""
    block = re.match(r"---\n(.*?)\n---", text, re.S)
    if not block:
        return None, ""
    name = re.search(r"^name:\s*(.+)$", block[1], re.M)
    desc = re.search(r"^description:\s*(.+)$", block[1], re.M)
    return (
        name[1].strip() if name else None,
        desc[1].strip().strip("\"'") if desc else "",
    )


def collect():
    lock = json.loads((AGENTS / ".skill-lock.json").read_text()).get("skills", {})
    flat, bundled = [], []

    for folder in sorted((AGENTS / "skills").iterdir()):
        if not folder.is_dir():
            continue
        name, desc = frontmatter(folder / "SKILL.md")
        if name:
            source = lock.get(folder.name, {}).get("source", "local")
            flat.append((name, desc, f"npx · {source}"))

    seen = {entry[0] for entry in flat}
    for path in sorted(glob.glob(str(CLAUDE / "skills/lazyweb*/SKILL.md"))):
        name, desc = frontmatter(path)
        if name and name not in seen:
            flat.append((name, desc, "lazyweb installer"))

    installed = json.loads((CLAUDE / "plugins/installed_plugins.json").read_text())["plugins"]
    for key, meta in installed.items():
        plugin = key.split("@")[0]
        version = meta[0]["version"]
        for path in sorted(glob.glob(f"{meta[0]['installPath']}/skills/*/SKILL.md")):
            name, desc = frontmatter(path)
            if name:
                bundled.append((f"{plugin}:{name}", desc, f"plugin {key} v{version}"))

    return flat, bundled, installed


def bucket(entries):
    buckets = {label: [] for label, _ in CATEGORIES}
    for entry in entries:
        for label, pattern in CATEGORIES:
            if re.search(pattern, entry[0]):
                buckets[label].append(entry)
                break
    return buckets


def render(flat, bundled, installed):
    buckets = bucket(flat + bundled)
    out = [
        "# User Skill & Plugin Index",
        "",
        f"*Last generated: {datetime.date.today()}*",
        "",
        f"**Global access:** {len(flat) + len(bundled)} skills — "
        f"{len(flat)} flat (`~/.agents/skills` + lazyweb) + {len(bundled)} plugin-bundled",
        "",
        "> Plugin skills are shown as `plugin:skill` and are a Claude-only mechanism.",
        "> Flat skills live in `~/.agents/skills/` and are symlinked into Claude, Codex and Gemini.",
        "> Regenerate with `plugins/workbench/scripts/generate-catalogue.py`.",
        "",
        "---",
        "",
        "## 🌍 Global Skills by Category",
    ]
    for label, _ in CATEGORIES:
        if not buckets[label]:
            continue
        out += ["", f"### {label}", ""]
        for name, desc, source in sorted(buckets[label]):
            out.append(f"- **`{name}`** *({source})*")
            if desc:
                out.append(f"  - {desc[:150]}")

    out += ["", "---", "", "## 🔌 Installed Plugins", ""]
    for key, meta in installed.items():
        out.append(f"- `{key}` v{meta[0]['version']} — updated {meta[0]['lastUpdated'][:10]}")

    marketplaces = json.loads((CLAUDE / "plugins/known_marketplaces.json").read_text())
    out += ["", "## 🛒 Marketplaces", ""]
    out += [f"- {name}" for name in marketplaces]
    return "\n".join(out) + "\n"


def main():
    flat, bundled, installed = collect()
    target = AGENTS / "CATEGORIES.md"

    existing = target.read_text() if target.exists() else ""
    log = existing.split("## 🧹 Housekeeping log", 1)
    footer = "\n## 🧹 Housekeeping log\n" + log[1] if len(log) > 1 else ""

    target.write_text(render(flat, bundled, installed) + footer)
    print(f"{len(flat) + len(bundled)} skills ({len(flat)} flat, {len(bundled)} bundled) -> {target}")


if __name__ == "__main__":
    main()
