#!/bin/zsh

set -euo pipefail

repo_root="${0:A:h:h}"
ai_math_only=false
if [[ "${1:-}" == "--ai-math-only" ]]; then
  ai_math_only=true
elif [[ -n "${1:-}" ]]; then
  print -u2 "Usage: $0 [--ai-math-only]"
  exit 1
fi
build_root="${TMPDIR:-/tmp}/latticecut-build"
sdk_root="$(xcrun --show-sdk-path)"
bundle_cmd=(bundle _2.1.3_)

mkdir -p "$build_root"

# Build from a no-spaces temp path because older native gems in this stack
# mis-handle compiler arguments when the workspace path contains spaces.
rsync -a --delete \
  --exclude ".bundle" \
  --exclude ".git" \
  --exclude ".jekyll-cache" \
  --exclude "_site" \
  --exclude "vendor" \
  --exclude "_projects/ai-mathematical-proof-analysis-jekyll" \
  "$repo_root/" "$build_root/"

cd "$build_root"

BUNDLE_FORCE_RUBY_PLATFORM=true \
BUNDLE_FROZEN=true \
BUNDLE_PATH="$build_root/vendor/bundle" \
SDKROOT="$sdk_root" \
CPLUS_INCLUDE_PATH="$sdk_root/usr/include/c++/v1" \
"${bundle_cmd[@]}" install

run_jekyll_build() {
  BUNDLE_FORCE_RUBY_PLATFORM=true \
  BUNDLE_FROZEN=true \
  BUNDLE_PATH="$build_root/vendor/bundle" \
  SDKROOT="$sdk_root" \
  CPLUS_INCLUDE_PATH="$sdk_root/usr/include/c++/v1" \
  "${bundle_cmd[@]}" exec jekyll build
}

run_jekyll_build

# Generate standalone copies from the fully rendered post pages, then rebuild
# so the PDFs become ordinary static assets in the published site.
if [[ "$ai_math_only" == false ]]; then
  node scripts/generate-essay-pdfs.mjs \
    --site "$build_root/_site" \
    --source "$build_root"
  run_jekyll_build
  node scripts/generate-essay-pdfs.mjs \
    --site "$build_root/_site" \
    --verify-only
fi

required_project_files=(
  index.html
  data-city.svg
  favicon.svg
  essay/open-problems-after-automation/index.html
  report/ai-mathematical-proof-analysis.pdf
  mathematics-progress-taxonomy.pdf
  taxonomy-v0.2-coding-manual.md
  data/difficulty_scored_entries.csv
  data/difficulty_monthly_breakdown.csv
  data/takeoff_counts_jan2025.csv
  data/reference-map.json
  data/analysis-log.json
  data/taxonomy-map.json
  data/taxonomy-registry.json
  data/taxonomy-colours.json
  data/ai-mathematical-proof-raw-data.zip
  data/result_claims.v0.2.csv
  data/result-reference-map.v0.2.json
  data/result-claims-monthly-breakdown.v0.2.csv
  data/challenge-context-policy.v1.1.0.json
  data/SHA256SUMS
  data/corpus-summary.json
  data/best-assessments.json
  data/best-assessments.csv
  data/assessment-monthly.csv
  data/assessment-review-queue.json
  data/assessment-revisions.json
  assessment-method.md
  og-v02.png
)

for project_file in "${required_project_files[@]}"; do
  generated_file="$build_root/_site/projects/ai-math/$project_file"
  if [[ ! -s "$generated_file" ]]; then
    print -u2 "Missing required project runtime file in generated site: $generated_file"
    exit 1
  fi
done

project_index="$build_root/_site/projects/ai-math/index.html"
asset_refs=("${(@f)$(rg -o 'assets/[^" ]+\.(js|css)' "$project_index" | sort -u)}")
if (( ${#asset_refs[@]} < 2 )); then
  print -u2 "Could not resolve compiled dashboard assets from $project_index"
  exit 1
fi
for asset_ref in "${asset_refs[@]}"; do
  generated_asset="$build_root/_site/projects/ai-math/$asset_ref"
  if [[ ! -s "$generated_asset" ]]; then
    print -u2 "Missing compiled dashboard asset: $generated_asset"
    exit 1
  fi
done

if [[ "$ai_math_only" == false ]]; then
  mkdir -p "$repo_root/assets/essay-pdfs"
  rsync -a --delete "$build_root/assets/essay-pdfs/" "$repo_root/assets/essay-pdfs/"
fi
rsync -a --delete "$build_root/_site/" "$repo_root/_site/"
