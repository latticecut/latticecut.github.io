#!/bin/zsh

set -euo pipefail

repo_root="${0:A:h:h}"
build_root="${TMPDIR:-/tmp}/latticecut-build"
bundle_cmd=(bundle _2.1.3_)

# Keep native gems outside the Dropbox path: this older Jekyll stack cannot
# reliably compile them when the path contains spaces.
if [[ ! -x "$build_root/vendor/bundle/ruby/2.6.0/bin/jekyll" ]]; then
  "$repo_root/scripts/build-site.sh"
fi

mkdir -p "$build_root/_serve_site"
cd "$build_root"

exec "${bundle_cmd[@]}" exec jekyll serve \
  --source "$repo_root" \
  --destination "$build_root/_serve_site" \
  --host 127.0.0.1 \
  --port 4000 \
  "$@"
