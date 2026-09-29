#!/usr/bin/env python3
"""Scan .desktop files and emit a JSON array of launchable apps.

Output shape: [{"name": str, "exec": [str, ...], "terminal": bool, "icon": str}]
`exec` is already tokenized and stripped of %f/%u/%F/%U/%i/%c/%k field codes,
ready to hand straight to a Process/execDetached call.
"""
import configparser
import json
import os
import re
import shlex
import sys

APP_DIRS = [
    "/usr/share/applications",
    "/usr/local/share/applications",
    os.path.expanduser("~/.local/share/applications"),
]

FIELD_CODE_RE = re.compile(r"%[fFuUick]")


def parse_desktop_file(path):
    cp = configparser.RawConfigParser(strict=False)
    try:
        cp.read(path, encoding="utf-8")
    except Exception:
        return None

    if "Desktop Entry" not in cp:
        return None
    entry = cp["Desktop Entry"]

    if entry.get("Type", "Application") != "Application":
        return None
    if entry.getboolean("NoDisplay", fallback=False):
        return None
    if entry.getboolean("Hidden", fallback=False):
        return None

    exec_raw = entry.get("Exec")
    if not exec_raw:
        return None

    exec_clean = FIELD_CODE_RE.sub("", exec_raw).strip()
    try:
        exec_tokens = shlex.split(exec_clean)
    except ValueError:
        exec_tokens = exec_clean.split()

    if not exec_tokens:
        return None

    return {
        "name": entry.get("Name", os.path.basename(path)),
        "exec": exec_tokens,
        "terminal": entry.getboolean("Terminal", fallback=False),
        "icon": entry.get("Icon", ""),
    }


def main():
    seen_names = set()
    apps = []
    for d in APP_DIRS:
        if not os.path.isdir(d):
            continue
        for fname in sorted(os.listdir(d)):
            if not fname.endswith(".desktop"):
                continue
            parsed = parse_desktop_file(os.path.join(d, fname))
            if parsed and parsed["name"] not in seen_names:
                seen_names.add(parsed["name"])
                apps.append(parsed)

    json.dump(apps, sys.stdout)


if __name__ == "__main__":
    main()
