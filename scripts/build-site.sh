#!/bin/zsh

set -euo pipefail

repo_root="${0:A:h:h}"
build_root="${TMPDIR:-/tmp}/latticecut-build"
sdk_root="$(xcrun --show-sdk-path)"
bundle_cmd=(bundle _2.1.3_)

mkdir -p "$build_root"

# Build from a no-spaces temp path because older native gems in this stack
# mis-handle compiler arguments when the workspace path contains spaces.
rsync -a --delete \
  --exclude "_site" \
  --exclude "vendor" \
  --exclude "_projects/ai-mathematical-proof-analysis-jekyll" \
  "$repo_root/" "$build_root/"

cd "$build_root"

BUNDLE_FORCE_RUBY_PLATFORM=true \
SDKROOT="$sdk_root" \
CPLUS_INCLUDE_PATH="$sdk_root/usr/include/c++/v1" \
"${bundle_cmd[@]}" install --path vendor/bundle

BUNDLE_FORCE_RUBY_PLATFORM=true \
SDKROOT="$sdk_root" \
CPLUS_INCLUDE_PATH="$sdk_root/usr/include/c++/v1" \
"${bundle_cmd[@]}" exec jekyll build

rsync -a "$build_root/Gemfile.lock" "$repo_root/Gemfile.lock"
rsync -a --delete "$build_root/_site/" "$repo_root/_site/"
