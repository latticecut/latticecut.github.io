#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "digest"
require "fileutils"

ROOT = File.expand_path("..", __dir__)
PUBLIC = File.join(ROOT, "projects", "ai-math")
PACKAGE = File.join(ROOT, "_projects", "ai-mathematical-proof-analysis-jekyll")
LEDGER = File.join(PUBLIC, "data", "difficulty_scored_entries.csv")
PROJECT_CARD = File.join(ROOT, "_projects", "ai-mathematical-proof-progress.md")

entry_count = CSV.read(LEDGER, headers: true).length
public_index = File.read(File.join(PUBLIC, "index.html"), encoding: "UTF-8")
source_name = public_index[%r{\./assets/(index-[A-Za-z0-9_-]+\.js)}, 1]
raise "Could not locate current JavaScript bundle" unless source_name
source_path = File.join(PUBLIC, "assets", source_name)
bundle = File.read(source_path, encoding: "UTF-8")

replacements = {
  "2026-07" => "2026-08",
  "21 July 2026" => "2 August 2026",
  "contains 64 audited entries" => "contains #{entry_count} audited entries",
  "Each row is one supplied public result package" => "Each row is one audited public result package",
  "This rerun holds the 64-row baseline fixed; the score rationales flag later novelty corrections rather than silently changing the corpus." =>
    "This refreshed corpus applies the same counting rule to new discoveries and retrospective corrections; every material addition, removal and status change is recorded in the analysis log.",
  "Read the full report ↗" => "Read the baseline report ↗",
  "Download report" => "Download baseline report"
}.freeze

replacements.each do |before, after|
  count = bundle.scan(before).length
  raise "Expected to replace #{before.inspect}, but it was absent" if count.zero?
  bundle = bundle.gsub(before, after)
end

digest = Digest::SHA256.hexdigest(bundle)[0, 8]
new_name = "index-#{digest}.js"
[PUBLIC, PACKAGE].each do |root|
  File.write(File.join(root, "assets", new_name), bundle, encoding: "UTF-8")
end

meta_copy = "Explore #{entry_count} audited AI contributions to mathematical proof using a transparent hybrid challenge score and three evidence-grounded categories."
[PUBLIC, PACKAGE].each do |root|
  path = File.join(root, "index.html")
  html = File.read(path, encoding: "UTF-8")
  html = html.gsub(/Explore \d+ audited AI contributions to mathematical proof using a transparent hybrid challenge score and three evidence-grounded categories\./, meta_copy)
  html = html.gsub(%r{\./assets/index-[A-Za-z0-9_-]+\.js}, "./assets/#{new_name}")
  File.write(path, html, encoding: "UTF-8")
end

card = File.read(PROJECT_CARD, encoding: "UTF-8")
card = card.sub(/^updated: .*$/, "updated: 2026-08-02")
card = card.sub(%r{^thumbnail: .*data-city-thumbnail[^\n]*$}, "thumbnail: /assets/projects/ai-math/data-city-thumbnail-20260802.png")
File.write(PROJECT_CARD, card, encoding: "UTF-8")

puts "Wrote #{new_name} for #{entry_count} entries and refreshed both site shells"
