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
SOCIAL_IMAGE_NAME = "og-data-portrait-d2bec58a.png"

entry_count = CSV.read(LEDGER, headers: true).length
city_svg = File.read(File.join(PUBLIC, "data-city.svg"), encoding: "UTF-8")
city_width = city_svg[/<svg[^>]+\bwidth="(\d+)"/, 1]
city_height = city_svg[/<svg[^>]+\bheight="(\d+)"/, 1]
raise "Could not read data-city dimensions" unless city_width && city_height
public_index = File.read(File.join(PUBLIC, "index.html"), encoding: "UTF-8")
source_path = Dir[File.join(PUBLIC, "assets", "index-*.js")].find do |candidate|
  contents = File.read(candidate, encoding: "UTF-8")
  contents.include?("Evidence through 21 July 2026") && contents.include?("contains 64 audited entries")
end
raise "Could not locate preserved 64-row JavaScript source bundle" unless source_path
source_name = File.basename(source_path)
bundle = File.read(source_path, encoding: "UTF-8")

replacements = {
  "2026-07" => "2026-08",
  "21 July 2026" => "2 August 2026",
  "contains 64 audited entries" => "contains #{entry_count} audited entries",
  "Each row is one supplied public result package" => "Each row is one audited public result package",
  "This rerun holds the 64-row baseline fixed; the score rationales flag later novelty corrections rather than silently changing the corpus." =>
    "This refreshed corpus applies the same counting rule to new discoveries and retrospective corrections; independent result packages may remain separate, while later support or verification does not create another row. Every material addition, removal and status change is recorded in the analysis log.",
  "The supplied source bundle does not record which model produced that baseline collection. This dashboard and the hybrid-scoring rerun were prepared with" =>
    "The original 64-row baseline does not record its collection model. This refresh and the hybrid-scoring rerun were prepared with",
  "consult the report for sources and full context." =>
    "consult the linked sources and raw data; use the baseline report for earlier context.",
  "Read the full report ↗" => "Read the baseline report ↗",
  "Download report" => "Download baseline report",
  "width:`929`,height:`297`" => "width:`#{city_width}`,height:`#{city_height}`"
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
  html = html.gsub(/og-data-portrait-[A-Za-z0-9_-]+\.png/, SOCIAL_IMAGE_NAME)
  html = html.gsub(%r{\./assets/index-[A-Za-z0-9_-]+\.js}, "./assets/#{new_name}")
  File.write(path, html, encoding: "UTF-8")
end

card = File.read(PROJECT_CARD, encoding: "UTF-8")
card = card.sub(/^updated: .*$/, "updated: 2026-08-02")
card = card.sub(%r{^thumbnail: .*data-city-thumbnail[^\n]*$}, "thumbnail: /assets/projects/ai-math/data-city-thumbnail-20260802.png")
File.write(PROJECT_CARD, card, encoding: "UTF-8")

puts "Wrote #{new_name} for #{entry_count} entries and refreshed both site shells"
