#!/usr/bin/env python3
"""Generate web/robots.txt and web/sitemap.xml from lib/project_registry.dart.

Run from anywhere: python3 tool/gen_seo_files.py [--out DIR]
Without --out the files go to web/. build_learning.sh passes the staging dir.
Placeholder entries (isPlaceholder: true) are left out of the sitemap.
"""
import argparse
import pathlib
import re
import sys

SITE = "https://infennonlabs.com"
ROOT = pathlib.Path(__file__).resolve().parent.parent
REGISTRY = ROOT / "lib" / "project_registry.dart"
WEB = ROOT / "web"


def live_slugs() -> list[str]:
    text = REGISTRY.read_text()
    entries = text.split("ProjectEntry(")[2:]  # [0] header, [1] class constructor
    slugs = []
    for entry in entries:
        slug = re.search(r"slug:\s*'([^']+)'", entry)
        if not slug:
            continue
        if re.search(r"isPlaceholder:\s*true", entry):
            continue
        slugs.append(slug.group(1))
    return slugs


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=pathlib.Path, default=WEB)
    out = parser.parse_args().out
    slugs = live_slugs()
    if not slugs:
        sys.exit("ERROR: no game slugs found in lib/project_registry.dart")
    out.mkdir(parents=True, exist_ok=True)
    urls = [f"{SITE}/"] + [f"{SITE}/{slug}/" for slug in slugs]
    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">']
    for url in urls:
        lines.append(f"  <url><loc>{url}</loc></url>")
    lines.append("</urlset>")
    (out / "sitemap.xml").write_text("\n".join(lines) + "\n")
    (out / "robots.txt").write_text(
        f"User-agent: *\nAllow: /\n\nSitemap: {SITE}/sitemap.xml\n"
    )
    print(f"wrote sitemap.xml ({len(urls)} urls) and robots.txt")


if __name__ == "__main__":
    main()
