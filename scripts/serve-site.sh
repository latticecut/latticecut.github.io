#!/bin/zsh

set -euo pipefail

repo_root="${0:A:h:h}"
build_root="${TMPDIR:-/tmp}/latticecut-build"
bundle_cmd=(bundle _2.1.3_)

# Rebuild whenever the resolved dependency graph changes or the temporary
# bundle is incomplete. Native gems stay outside the Dropbox path because this
# older Jekyll stack cannot reliably compile them when that path contains spaces.
if [[ ! -f "$build_root/Gemfile" ]] || \
   ! cmp -s "$repo_root/Gemfile" "$build_root/Gemfile" || \
   [[ ! -f "$build_root/Gemfile.lock" ]] || \
   ! cmp -s "$repo_root/Gemfile.lock" "$build_root/Gemfile.lock" || \
   ! (cd "$build_root" && \
       BUNDLE_FROZEN=true \
       BUNDLE_PATH="$build_root/vendor/bundle" \
       "${bundle_cmd[@]}" check >/dev/null 2>&1); then
  "$repo_root/scripts/build-site.sh"
fi

mkdir -p "$build_root/_serve_site"
cd "$build_root"

exec env \
  BUNDLE_FROZEN=true \
  BUNDLE_PATH="$build_root/vendor/bundle" \
  "${bundle_cmd[@]}" exec jekyll serve \
  --source "$repo_root" \
  --destination "$build_root/_serve_site" \
  --host 127.0.0.1 \
  --port 4000 \
  "$@"
