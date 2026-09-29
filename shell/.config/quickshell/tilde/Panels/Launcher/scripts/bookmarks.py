#!/usr/bin/env python3
"""Parse qutebrowser bookmarks and quickmarks into a flat JSON array.

Output shape: [{"title": str, "url": str, "source": "bookmark"|"quickmark"}]
"""
import json
import os
import sys

BOOKMARKS_FILE = os.path.expanduser("~/.local/share/qutebrowser/bookmarks/urls")
QUICKMARKS_FILE = os.path.expanduser("~/.config/qutebrowser/quickmarks")


def parse_bookmarks(path):
    # Format: "<url> <title...>" per line
    out = []
    if not os.path.isfile(path):
        return out
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.split(" ", 1)
            url = parts[0]
            title = parts[1] if len(parts) > 1 else url
            out.append({"title": title, "url": url, "source": "bookmark"})
    return out


def parse_quickmarks(path):
    # Format: "<name> <url>" per line
    out = []
    if not os.path.isfile(path):
        return out
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            parts = line.rsplit(" ", 1)
            if len(parts) != 2:
                continue
            name, url = parts
            out.append({"title": name, "url": url, "source": "quickmark"})
    return out


def main():
    combined = parse_quickmarks(QUICKMARKS_FILE) + parse_bookmarks(BOOKMARKS_FILE)
    # De-dupe by URL, preferring quickmarks (usually more meaningful names).
    seen = set()
    unique = []
    for entry in combined:
        if entry["url"] in seen:
            continue
        seen.add(entry["url"])
        unique.append(entry)
    json.dump(unique, sys.stdout)


if __name__ == "__main__":
    main()
