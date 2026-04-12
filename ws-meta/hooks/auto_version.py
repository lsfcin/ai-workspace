#!/usr/bin/env python3
"""
auto_version.py — PostToolUse hook for Claude Code
Bumps PATCH version of dev projects on the first file edit per session.
Zero-token: pure Python + git, no LLM calls.

Triggered by: PostToolUse → matcher: Edit|Write
"""
import json
import os
import re
import subprocess
import sys
import tempfile

WORKSPACE = r"C:\Users\Lucas\Desktop\AI-Workspace"
DEV_DIR = os.path.join(WORKSPACE, "dev")

# Subdirectory prefixes (relative to project root) that are build artifacts
EXCLUDED_PREFIXES = (
    "build", ".dart_tool", ".gradle", ".idea", ".pub-cache",
    "node_modules", "__pycache__", ".git",
)

# Version file detection priority
VERSION_FILES = ["pubspec.yaml", "package.json", "pyproject.toml", "Cargo.toml", "VERSION"]


# ---------------------------------------------------------------------------
# Git helpers
# ---------------------------------------------------------------------------

def git(*args):
    return subprocess.run(
        ["git", "-C", WORKSPACE, *args],
        capture_output=True, text=True,
    )


# ---------------------------------------------------------------------------
# Project detection
# ---------------------------------------------------------------------------

def detect_project(file_path: str):
    """Return (project_name, project_root) if file is a tracked dev source file."""
    try:
        rel = os.path.relpath(file_path, DEV_DIR)
    except ValueError:
        return None  # different drive on Windows

    parts = rel.split(os.sep)
    if parts[0].startswith("..") or len(parts) < 2:
        return None  # not inside a project subdir

    project = parts[0]
    sub = os.sep.join(parts[1:])

    for excl in EXCLUDED_PREFIXES:
        if sub.lower().startswith(excl.lower()):
            return None

    return project, os.path.join(DEV_DIR, project)


# ---------------------------------------------------------------------------
# Session lock (ephemeral — OS clears on reboot)
# ---------------------------------------------------------------------------

def session_lock_path(project: str) -> str:
    return os.path.join(tempfile.gettempdir(), f"av_{project}.lock")


# ---------------------------------------------------------------------------
# Version file: find + bump
# ---------------------------------------------------------------------------

def find_version_file(project_root: str):
    for name in VERSION_FILES:
        path = os.path.join(project_root, name)
        if os.path.exists(path):
            return path, name
    return None, None


def create_version_file(project_root: str):
    path = os.path.join(project_root, "VERSION")
    with open(path, "w", encoding="utf-8") as f:
        f.write("0.1.0\n")
    return path, "VERSION"


def bump_version(vfile_path: str, vfile_name: str):
    """
    Bump PATCH in-place. Returns (old_display, new_display) or None on failure.
    pubspec.yaml also bumps the build number.
    """
    with open(vfile_path, encoding="utf-8") as f:
        content = f.read()

    if vfile_name == "pubspec.yaml":
        m = re.search(r'^(version:\s*)(\d+)\.(\d+)\.(\d+)\+(\d+)', content, re.MULTILINE)
        if not m:
            return None
        prefix, major, minor, patch, build = m.group(1), m.group(2), m.group(3), m.group(4), m.group(5)
        old_full = f"{major}.{minor}.{patch}+{build}"
        new_full = f"{major}.{minor}.{int(patch)+1}+{int(build)+1}"
        new_content = content.replace(f"{prefix}{old_full}", f"{prefix}{new_full}", 1)
        old_display, new_display = f"{major}.{minor}.{patch}", f"{major}.{minor}.{int(patch)+1}"

    elif vfile_name == "package.json":
        m = re.search(r'("version":\s*")(\d+)\.(\d+)\.(\d+)(")', content)
        if not m:
            return None
        major, minor, patch = m.group(2), m.group(3), m.group(4)
        old_display = f"{major}.{minor}.{patch}"
        new_display = f"{major}.{minor}.{int(patch)+1}"
        new_content = content.replace(
            f'"version": "{old_display}"', f'"version": "{new_display}"', 1
        )

    elif vfile_name in ("pyproject.toml", "Cargo.toml"):
        m = re.search(r'^(version\s*=\s*")(\d+)\.(\d+)\.(\d+)(")', content, re.MULTILINE)
        if not m:
            return None
        major, minor, patch = m.group(2), m.group(3), m.group(4)
        old_display = f"{major}.{minor}.{patch}"
        new_display = f"{major}.{minor}.{int(patch)+1}"
        new_content = re.sub(
            r'^(version\s*=\s*")' + re.escape(old_display) + '"',
            rf'\g<1>{new_display}"',
            content, count=1, flags=re.MULTILINE,
        )

    elif vfile_name == "VERSION":
        m = re.match(r'(\d+)\.(\d+)\.(\d+)', content.strip())
        if not m:
            return None
        major, minor, patch = m.group(1), m.group(2), m.group(3)
        old_display = f"{major}.{minor}.{patch}"
        new_display = f"{major}.{minor}.{int(patch)+1}"
        new_content = content.replace(old_display, new_display, 1)

    else:
        return None

    with open(vfile_path, "w", encoding="utf-8") as f:
        f.write(new_content)

    return old_display, new_display


# ---------------------------------------------------------------------------
# Commit message — derived entirely from git diff --stat
# ---------------------------------------------------------------------------

def build_commit_message(project: str, old_ver: str, new_ver: str) -> str:
    result = git("diff", "HEAD", "--", f"dev/{project}/")
    stat_result = git("diff", "--stat", "HEAD", "--", f"dev/{project}/")
    stat = stat_result.stdout.strip()

    if not stat:
        return f"auto: bump {project} {old_ver}→{new_ver}"

    lines = stat.split("\n")
    summary_line = lines[-1]
    file_lines = lines[:-1]

    ins_m = re.search(r'(\d+) insertion', summary_line)
    del_m = re.search(r'(\d+) deletion', summary_line)
    total_ins = int(ins_m.group(1)) if ins_m else 0
    total_del = int(del_m.group(1)) if del_m else 0
    total_lines = total_ins + total_del

    # Scale: major > 30 lines changed, minor otherwise
    scale = "major" if total_lines > 30 else "minor"

    # Nature: >70% ins → additions, <30% ins → removals, else → edits
    if total_lines == 0:
        nature = "edits"
    else:
        ins_pct = total_ins / total_lines
        if ins_pct > 0.70:
            nature = "additions"
        elif ins_pct < 0.30:
            nature = "removals"
        else:
            nature = "edits"

    # Parse per-file line counts, pick primary (most changed)
    file_changes = []
    for line in file_lines:
        m = re.match(r'\s*(.+?)\s*\|\s*(\d+)', line)
        if m:
            fname = os.path.basename(m.group(1).strip())
            count = int(m.group(2))
            file_changes.append((fname, count))

    file_changes.sort(key=lambda x: x[1], reverse=True)

    if not file_changes:
        return f"auto: {scale} {nature} · {project} {old_ver}→{new_ver}"

    primary = file_changes[0][0]
    others = file_changes[1:]

    if others:
        other_lines = sum(c for _, c in others)
        n = len(others)
        suffix = f" + {other_lines} lines across {n} {'file' if n == 1 else 'files'}"
    else:
        suffix = ""

    return f"auto: {scale} {nature} on {primary}{suffix} · {project} {old_ver}→{new_ver}"


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    if data.get("tool_name") not in ("Edit", "Write"):
        sys.exit(0)

    file_path = data.get("tool_input", {}).get("file_path", "")
    if not file_path:
        sys.exit(0)

    result = detect_project(file_path)
    if not result:
        sys.exit(0)

    project, project_root = result

    lock = session_lock_path(project)
    if os.path.exists(lock):
        sys.exit(0)  # already bumped this session

    vfile_path, vfile_name = find_version_file(project_root)
    if not vfile_path:
        vfile_path, vfile_name = create_version_file(project_root)

    versions = bump_version(vfile_path, vfile_name)
    if not versions:
        sys.exit(0)

    old_ver, new_ver = versions

    # Gate: write lock before committing so a hook failure doesn't re-run
    open(lock, "w").close()

    msg = build_commit_message(project, old_ver, new_ver)

    git("add", vfile_path)
    res = git("commit", "-m", msg)

    if res.returncode != 0 and "nothing to commit" not in res.stdout:
        print(f"[auto_version] commit failed: {res.stderr}", file=sys.stderr)


if __name__ == "__main__":
    main()
    sys.exit(0)
