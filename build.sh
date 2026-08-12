#!/bin/sh
# Two builds from one set of sources:
#   frequent-flyer.html — a complete standalone page; upload this to any web host
#   artifact.html       — a fragment; the Claude Artifact host wraps it in its own
#                         doctype/head/body, so this one must not carry its own
set -e
cd "$(dirname "$0")"

SCRIPTS="parts/b0_brand.html parts/b_data.html parts/c_engine.html parts/d_ui.html parts/e_events.html"

cat parts/a_shell.html $SCRIPTS > artifact.html

# a_shell.html holds head content (meta, title, style) followed by the app root
# div, so it gets split at </style> across the document's head and body.
ICON=$(cat parts/.icon.txt)
FAVICON=$(cat parts/.favicon.txt)
{
  printf '<!doctype html>\n<html lang="en">\n<head>\n'
  sed -n '1,/<\/style>/p' parts/a_shell.html
  sed -e "s|__FAVICON__|$FAVICON|g" -e "s|__ICON__|$ICON|g" parts/_doc_meta.html
  printf '</head>\n<body>\n'
  sed -n '/<div id="app">/,$p' parts/a_shell.html
  cat $SCRIPTS
  printf '</body>\n</html>\n'
} > frequent-flyer.html

for f in frequent-flyer.html artifact.html; do
  echo "built $f ($(wc -c < "$f" | tr -d ' ') bytes)"
done

# GitHub Pages serves index.html as the directory root, so keep a copy under
# that name — it's what makes the bare URL work without a filename on the end.
cp frequent-flyer.html index.html
