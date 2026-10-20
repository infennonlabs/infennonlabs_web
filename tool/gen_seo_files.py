#!/usr/bin/env python3
"""Generate robots.txt, sitemap.xml and the crawlable home-page content from
lib/project_registry.dart.

Run from anywhere:
  python3 tool/gen_seo_files.py [--out DIR] [--inject-index PATH]

Without --out the files go to web/. With --inject-index the visually hidden
content block (heading, intro, links to every game) is inserted into that built
index.html right after <body>, plus Organization/WebSite JSON-LD in <head>; re-running
replaces both.
build_learning.sh calls this for the stable home build.
Placeholder entries (isPlaceholder: true) are left out everywhere.
"""
import argparse
import html
import json
import pathlib
import re
import sys

SITE = "https://infennonlabs.com"
ROOT = pathlib.Path(__file__).resolve().parent.parent
REGISTRY = ROOT / "lib" / "project_registry.dart"
WEB = ROOT / "web"

HEADING = "Infennon Labs: free early learning games for kids"
INTRO = (
    "Infennon Labs makes free, simple, focused learning games for children from "
    "PreK through 5th grade. There is no subscription and no distracting "
    "characters, just clear practice with the alphabet, counting, math, reading, "
    "science, money, time and everyday life skills. The games were built from "
    "experience with the author's own two kids, and they play right in your web "
    "browser."
)
# Standard visually-hidden pattern: still indexed and read by screen readers.
HIDDEN_STYLE = (
    "position:absolute;width:1px;height:1px;margin:-1px;padding:0;border:0;"
    "overflow:hidden;clip:rect(0,0,0,0);white-space:nowrap"
)
JSONLD_RE = re.compile(
    r'\s*<script type="application/ld\+json" id="seo-site-jsonld">.*?</script>', re.S
)
BLOCK_RE = re.compile(r'\s*<div id="seo-content".*?</div>\s*<!--/seo-content-->', re.S)


def _string_field(entry: str, name: str) -> str | None:
    match = re.search(rf"\b{name}:\s*'((?:[^'\\]|\\.)*)'", entry)
    if not match:
        return None
    return re.sub(r"\\(.)", r"\1", match.group(1))


def live_games() -> list[dict[str, str]]:
    text = REGISTRY.read_text()
    games = []
    for entry in text.split("ProjectEntry(")[2:]:  # [0] header, [1] class constructor
        slug = _string_field(entry, "slug")
        if not slug or re.search(r"isPlaceholder:\s*true", entry):
            continue
        games.append(
            {
                "slug": slug,
                "title": _string_field(entry, "title") or slug,
                "description": _string_field(entry, "description") or "",
            }
        )
    return games


def content_block(games: list[dict[str, str]]) -> str:
    items = []
    for game in games:
        label = html.escape(game["title"])
        if game["description"]:
            label += " – " + html.escape(game["description"])
        items.append(f'<li><a href="{SITE}/{game["slug"]}/">{label}</a></li>')
    return (
        f'<div id="seo-content" style="{HIDDEN_STYLE}">\n'
        f"<h1>{html.escape(HEADING)}</h1>\n"
        f"<p>{html.escape(INTRO)}</p>\n"
        '<nav aria-label="Games">\n<ul>\n' + "\n".join(items) + "\n</ul>\n</nav>\n"
        "</div><!--/seo-content-->"
    )


def site_jsonld() -> str:
    data = {
        "@context": "https://schema.org",
        "@graph": [
            {
                "@type": "Organization",
                "@id": f"{SITE}/#organization",
                "name": "Infennon Labs",
                "url": f"{SITE}/",
                "logo": f"{SITE}/home/icons/Icon-512.png",
            },
            {
                "@type": "WebSite",
                "@id": f"{SITE}/#website",
                "name": "Infennon Labs",
                "url": f"{SITE}/",
                "inLanguage": "en",
                "publisher": {"@id": f"{SITE}/#organization"},
            },
        ],
    }
    payload = json.dumps(data, ensure_ascii=False).replace("</", "<\\/")
    return f'  <script type="application/ld+json" id="seo-site-jsonld">{payload}</script>\n'


def inject_into_index(index_path: pathlib.Path, games: list[dict[str, str]]) -> None:
    page = index_path.read_text(encoding="utf-8")
    page = BLOCK_RE.sub("", page)
    page = JSONLD_RE.sub("", page)
    if "<body>" not in page or "</head>" not in page:
        sys.exit(f"ERROR: {index_path} needs <body> and </head> for the SEO markup")
    page = page.replace("</head>", site_jsonld() + "</head>", 1)
    page = page.replace("<body>", "<body>\n" + content_block(games) + "\n", 1)
    index_path.write_text(page, encoding="utf-8")
    print(f"injected content block ({len(games)} game links) into {index_path}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--out", type=pathlib.Path, default=WEB)
    parser.add_argument("--inject-index", type=pathlib.Path)
    args = parser.parse_args()
    games = live_games()
    if not games:
        sys.exit("ERROR: no game slugs found in lib/project_registry.dart")
    out = args.out
    out.mkdir(parents=True, exist_ok=True)
    urls = [f"{SITE}/"] + [f"{SITE}/{game['slug']}/" for game in games]
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
    if args.inject_index:
        inject_into_index(args.inject_index, games)


if __name__ == "__main__":
    main()
