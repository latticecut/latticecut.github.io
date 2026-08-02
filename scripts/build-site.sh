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

required_project_files=(
  index.html
  data-city.svg
  assets/favicon-B13FBozU.svg
  assets/index-8eaa617c.js
  assets/index-DgmCWThy.css
  assets/og-data-portrait-d2bec58a.png
  report/ai-mathematical-proof-analysis.pdf
  data/difficulty_scored_entries.csv
  data/difficulty_monthly_breakdown.csv
  data/takeoff_counts_jan2025.csv
  data/reference-map.json
  data/analysis-log.json
)

for project_file in "${required_project_files[@]}"; do
  generated_file="$build_root/_site/projects/ai-math/$project_file"
  if [[ ! -s "$generated_file" ]]; then
    print -u2 "Missing required project runtime file in generated site: $generated_file"
    exit 1
  fi
done

rsync -a "$build_root/Gemfile.lock" "$repo_root/Gemfile.lock"
rsync -a --delete "$build_root/_site/" "$repo_root/_site/"
