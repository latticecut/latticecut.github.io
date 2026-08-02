#!/usr/bin/env ruby
# frozen_string_literal: true

require "digest"
require "fileutils"
require "json"

ROOT = File.expand_path("..", __dir__)
ARCHIVE_ROOT = File.expand_path(
  "../latticecut-ai-math-private-archive/2026-08-02-pre-update",
  ROOT
)
RUN_ROOT = File.join(ARCHIVE_ROOT, "update-run-record")

inputs = {
  "/private/tmp/ai-math-arxiv-20260701-20260802.xml" => "discovery/arxiv/all-0000.xml",
  "/private/tmp/ai-math-arxiv-20260701-20260802-2000.xml" => "discovery/arxiv/all-2000.xml",
  "/private/tmp/ai-math-arxiv-20260701-20260802-4000.xml" => "discovery/arxiv/all-4000.xml",
  "/private/tmp/ai-math-arxiv-20260701-20260802-6000.xml" => "discovery/arxiv/all-6000.xml",
  "/private/tmp/ai-math-arxiv-claude.xml" => "discovery/arxiv/target-claude.xml",
  "/private/tmp/ai-math-arxiv-codex.xml" => "discovery/arxiv/target-codex.xml",
  "/private/tmp/ai-math-arxiv-gpt56.xml" => "discovery/arxiv/target-gpt56.xml",
  "/private/tmp/ai-math-arxiv-rethelas.xml" => "discovery/arxiv/target-rethelas.xml",
  "/private/tmp/ai-math-arxiv-ai-candidates.tsv" => "discovery/extracted/ai-candidates.tsv",
  "/private/tmp/ai-math-arxiv-ai-union.tsv" => "discovery/extracted/ai-keyword-union.tsv",
  "/private/tmp/extract_arxiv_ai.rb" => "discovery/extracted/extract_arxiv_ai.rb",
  "/private/tmp/kingy-ai-math-records.json" => "discovery/tracker/kingy-ai-math-records-2026-08-01.1.json",
  "/private/tmp/ten-proofs-oai.pdf" => "discovery/announcements/openai-ten-proofs-oai.pdf",
  "/private/tmp/ai_math_update_search_protocol_2026_08_02.md" => "decisions/search-protocol.md",
  "/private/tmp/ai_math_update_decision_register_2026_08_02.json" => "decisions/decision-register.json",
  "/private/tmp/ai_math_backfill_entries.json" => "scoring-fragments/backfill-entries.json",
  "/private/tmp/ai_math_backfill_references.json" => "scoring-fragments/backfill-references.json",
  "/private/tmp/ai_math_extra_entries.json" => "scoring-fragments/tracker-extra-entries.json",
  "/private/tmp/ai_math_extra_references.json" => "scoring-fragments/tracker-extra-references.json",
  "/private/tmp/ai_math_late_entries.json" => "scoring-fragments/late-entries.json",
  "/private/tmp/ai_math_late_references.json" => "scoring-fragments/late-references.json",
  "/private/tmp/ai_math_aug1_entries.json" => "scoring-fragments/openai-aug1-entries.json",
  "/private/tmp/ai_math_aug1_references.json" => "scoring-fragments/openai-aug1-references.json",
  File.join(__dir__, "ai_math_update_2026_08_02_entries.json") => "final-update-batch/entries.json",
  File.join(__dir__, "ai_math_update_2026_08_02_references.json") => "final-update-batch/references.json"
}

%w[
  difficulty_scored_entries.csv
  difficulty_monthly_breakdown.csv
  takeoff_counts_jan2025.csv
  difficulty_method.txt
  reference-map.json
  analysis-log.json
  ai-mathematical-proof-raw-data.zip
].each do |name|
  inputs[File.join(ROOT, "projects", "ai-math", "data", name)] = File.join("final-public-data", name)
end

maintenance_scripts = %w[
  prepare_ai_math_update_2026_08_02.rb
  apply_ai_math_update_2026_08_02.rb
  refresh_ai_math_data.rb
  update_ai_math_site_shell_2026_08_02.rb
  render_ai_math_social_assets_2026_08_02.rb
  write_ai_math_private_decision_register_2026_08_02.rb
  archive_ai_math_update_run_2026_08_02.rb
]
maintenance_scripts.each do |name|
  inputs[File.join(__dir__, name)] = File.join("maintenance", name)
end

inputs.each do |source, relative_target|
  raise "Missing archival input: #{source}" unless File.file?(source)
  target = File.join(RUN_ROOT, relative_target)
  FileUtils.mkdir_p(File.dirname(target))
  FileUtils.cp(source, target)
end

manifest = {
  "archive_kind" => "private pre-update snapshot plus update-run provenance",
  "created_for" => "2026-08-02-data-refresh",
  "public_evidence_cutoff" => "2026-08-02",
  "baseline_entries" => 64,
  "added_packages" => 64,
  "removed_baseline_packages" => 2,
  "final_entries" => 126,
  "publication_note" => "This sibling archive is outside the Jekyll source tree and is not copied into the public site.",
  "run_record_files" => inputs.length
}
File.write(File.join(RUN_ROOT, "MANIFEST.json"), JSON.pretty_generate(manifest) + "\n", encoding: "UTF-8")

checksum_path = File.join(ARCHIVE_ROOT, "SHA256SUMS.txt")
files = Dir[File.join(ARCHIVE_ROOT, "**", "*")].select { |path| File.file?(path) && path != checksum_path }
lines = files.sort.map do |path|
  relative = path.delete_prefix("#{ARCHIVE_ROOT}/")
  "#{Digest::SHA256.file(path).hexdigest}  #{relative}"
end
File.write(checksum_path, lines.join("\n") + "\n", encoding: "UTF-8")

puts "Archived #{inputs.length} run-record files under #{RUN_ROOT}"
puts "Checksummed #{files.length} private archive files"
