#!/usr/bin/env ruby
# frozen_string_literal: true
# The Python taxonomy builder owns classification. Preserve its exact outputs.
require "csv"
require "date"
require "digest"
require "fileutils"
require "json"
require "tmpdir"

ROOT = File.expand_path("..", __dir__)
PUBLIC_ROOT = File.join(ROOT, "projects", "ai-math")
PACKAGE_ROOT = File.join(ROOT, "_projects", "ai-mathematical-proof-analysis-jekyll")
DATA = File.join(PUBLIC_ROOT, "data")
PACKAGE_DATA = File.join(PACKAGE_ROOT, "data")
ZIP_NAME = "ai-mathematical-proof-raw-data.zip"
FILES = %w[
  difficulty_scored_entries.csv difficulty_monthly_breakdown.csv
  takeoff_counts_jan2025.csv difficulty_method.txt reference-map.json
  analysis-log.json taxonomy-map.json taxonomy-registry.json taxonomy-colours.json
  result_claims.v0.2.csv result-reference-map.v0.2.json
  result-claims-monthly-breakdown.v0.2.csv challenge-context-policy.v1.1.0.json
  corpus-summary.json
].freeze
def read_json(name)
  JSON.parse(File.read(File.join(DATA, name), encoding: "UTF-8"))
end
def read_csv(name)
  CSV.read(File.join(DATA, name), headers: true).map(&:to_h)
end
def same_ids(label, actual, expected)
  raise "#{label}: duplicate or mismatching IDs" unless actual.uniq.length == actual.length && actual.sort == expected.sort
end
FILES.each { |name| raise "Missing #{name}" unless File.size?(File.join(DATA, name)) }
rows = read_csv("difficulty_scored_entries.csv")
raise "Empty ledger" if rows.empty?
ids = rows.map { |row| row.fetch("id") }
same_ids("Sources", ids, ids.uniq)
rows.each do |row|
  raise "Source period mismatch" unless Date.iso8601(row.fetch("publication_date")).strftime("%Y-%m") == row.fetch("period")
end
refs = read_json("reference-map.json")
same_ids("References", refs.keys, ids)
raise "Empty references" unless refs.values.all? { |value| value.is_a?(Array) && !value.empty? }
latest = read_json("analysis-log.json").max_by { |run| [run.fetch("collectionEnded"), run.fetch("recordedAt"), run.fetch("id")] }
raise "Log count mismatch" unless latest && latest.fetch("entryCount") == rows.length
taxonomy = read_json("taxonomy-map.json")
meta = taxonomy.fetch("_meta")
records = taxonomy.reject { |id, _| id == "_meta" }
raise "Expected policy 1.1.0" unless meta.fetch("challengePolicyVersion") == "1.1.0"
raise "Metadata count mismatch" unless meta.fetch("sourceIncludedCount") == rows.length && meta.fetch("recordCount") == records.length
raise "Cutoff mismatch" unless meta.fetch("sourceCorpusCollectionEnded") == latest.fetch("collectionEnded")
summary = read_json("corpus-summary.json")
raise "Summary count mismatch" unless summary.fetch("sourceCount") == rows.length
raise "Summary run mismatch" unless summary.fetch("latestRun") == latest
aliases = meta.fetch("sourceIdAliases", {})
same_ids("Taxonomy owners", records.values.map { |r| r.fetch("sourceIncludedId") }.uniq, ids.map { |id| aliases.fetch(id, id) })
claims = read_csv("result_claims.v0.2.csv")
same_ids("Claims", claims.map { |r| r.fetch("id") }, records.keys)
same_ids("Claim references", read_json("result-reference-map.v0.2.json").keys, records.keys)
claims.each do |row|
  record = records.fetch(row.fetch("id"))
  raise "Claim owner mismatch" unless record.fetch("sourceIncludedId") == row.fetch("source_included_id")
  raise "Claim category mismatch" unless record.fetch("challengeContext").fetch("derived").fetch("category") == row.fetch("category")
end
{"scoredLedgerSha256" => "difficulty_scored_entries.csv", "referenceMapSha256" => "reference-map.json", "analysisLogSha256" => "analysis-log.json"}.each do |key, name|
  raise "Stale source hash: #{name}" unless meta.fetch("sourceSnapshot").fetch(key) == Digest::SHA256.file(File.join(DATA, name)).hexdigest
end
[["difficulty_monthly_breakdown.csv", rows], ["result-claims-monthly-breakdown.v0.2.csv", claims]].each do |name, members|
  monthly = read_csv(name)
  same_ids(name, monthly.map { |m| m.fetch("period") }, monthly.map { |m| m.fetch("period") }.uniq)
  monthly.each do |month|
    selected = members.select { |r| r.fetch("period") == month.fetch("period") }
    raise "Monthly total mismatch: #{name}" unless Integer(month.fetch("total"), 10) == selected.length
    %w[Expected Difficult Superhuman incomplete].each do |category|
      next unless month.key?(category.downcase)
      raise "Monthly category mismatch: #{name}" unless Integer(month.fetch(category.downcase), 10) == selected.count { |r| r.fetch("category") == category }
    end
  end
  raise "Monthly coverage mismatch" unless monthly.sum { |m| Integer(m.fetch("total"), 10) } == members.length
end
cumulative = 0
prior_period = ""
read_csv("takeoff_counts_jan2025.csv").each do |month|
  period = month.fetch("period")[0, 7]
  raise "Nonchronological takeoff" unless period > prior_period
  prior_period = period
  count = rows.count { |r| r.fetch("period") == period }
  cumulative += count
  raise "Takeoff mismatch" unless Integer(month.fetch("new_audited_entries"), 10) == count && Integer(month.fetch("cumulative_audited_entries"), 10) == cumulative
end
raise "Takeoff coverage mismatch" unless cumulative == rows.length
raise "Missing v0.2 chart" unless File.read(File.join(PUBLIC_ROOT, "data-city.svg")).include?("data-result-id=")

manifest = FILES.sort.map { |name| "#{Digest::SHA256.file(File.join(DATA, name)).hexdigest}  #{name}\n" }.join
File.write(File.join(DATA, "SHA256SUMS"), manifest)
FileUtils.mkdir_p(PACKAGE_DATA)
(FILES + ["SHA256SUMS"]).each { |name| FileUtils.cp(File.join(DATA, name), File.join(PACKAGE_DATA, name)) }
FileUtils.cp(File.join(PUBLIC_ROOT, "data-city.svg"), File.join(PACKAGE_ROOT, "data-city.svg"))
Dir.mktmpdir("ai-math-raw-data-") do |stage|
  names = (FILES + ["SHA256SUMS"]).sort
  names.each do |name|
    destination = File.join(stage, name)
    FileUtils.cp(File.join(DATA, name), destination)
    File.utime(Time.utc(1980, 1, 1), Time.utc(1980, 1, 1), destination)
  end
  raise "Could not create ZIP" unless system({"TZ" => "UTC"}, "zip", "-X", "-q", ZIP_NAME, *names, chdir: stage)
  FileUtils.cp(File.join(stage, ZIP_NAME), File.join(DATA, ZIP_NAME))
end
FileUtils.cp(File.join(DATA, ZIP_NAME), File.join(PACKAGE_DATA, ZIP_NAME))
puts "Validated #{rows.length} packages / #{claims.length} claims; refreshed #{latest.fetch('recordedAt')}, continuous coverage through #{latest.fetch('collectionEnded')}"
puts "Packaged #{FILES.length} exact datasets and SHA256SUMS; classifications and chart preserved"
