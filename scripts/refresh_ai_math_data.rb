#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "date"
require "fileutils"
require "json"

ROOT = File.expand_path("..", __dir__)
PUBLIC_ROOT = File.join(ROOT, "projects", "ai-math")
PACKAGE_ROOT = File.join(ROOT, "_projects", "ai-mathematical-proof-analysis-jekyll")
PUBLIC_DATA = File.join(PUBLIC_ROOT, "data")
PACKAGE_DATA = File.join(PACKAGE_ROOT, "data")
LEDGER_NAME = "difficulty_scored_entries.csv"
MONTHLY_NAME = "difficulty_monthly_breakdown.csv"
TAKEOFF_NAME = "takeoff_counts_jan2025.csv"
ZIP_NAME = "ai-mathematical-proof-raw-data.zip"
SYNCED_NAMES = [
  LEDGER_NAME,
  MONTHLY_NAME,
  TAKEOFF_NAME,
  "difficulty_method.txt",
  "reference-map.json",
  "analysis-log.json",
  "taxonomy-map.json",
  "taxonomy-registry.json",
  "taxonomy-colours.json"
].freeze
SCORE_FIELDS = %w[prior_target advance scope resistance].freeze
OUTPUT_FIELDS = %w[
  id period publication_date prior_target advance scope resistance
  difficulty_score category framing_year solution_year age_decades provisional
  description anchor_claim prior_rationale advance_rationale scope_rationale
  resistance_rationale age_rationale coding_confidence
  challenge_policy_version challenge_audit_status
].freeze

def truthy?(value)
  %w[1 true yes y].include?(value.to_s.strip.downcase)
end

def natural_id_key(id)
  id.scan(/\d+|\D+/).map { |part| part.match?(/\A\d+\z/) ? [0, part.to_i] : [1, part] }
end

def each_month(first_period, last_period)
  cursor = Date.strptime("#{first_period}-01", "%Y-%m-%d")
  finish = Date.strptime("#{last_period}-01", "%Y-%m-%d")
  while cursor <= finish
    yield cursor.strftime("%Y-%m")
    cursor = cursor.next_month
  end
end

def xml_escape(value)
  value.to_s.gsub("&", "&amp;").gsub('"', "&quot;").gsub("<", "&lt;").gsub(">", "&gt;")
end

def category_for(row, score, age)
  superhuman = row["prior_target"] == "1" && row["advance"] == "2" &&
    !truthy?(row["provisional"]) && !age.nil? && age >= 1.0
  return "Superhuman" if superhuman

  score >= 3 ? "Difficult" : "Expected"
end

def validate_and_normalize(rows)
  raise "Ledger is empty" if rows.empty?
  ids = rows.map { |row| row.fetch("id") }
  id_counts = Hash.new(0)
  ids.each { |id| id_counts[id] += 1 }
  duplicates = id_counts.select { |_id, count| count > 1 }.keys
  raise "Duplicate ledger IDs: #{duplicates.join(', ')}" unless duplicates.empty?

  rows.each do |row|
    row["challenge_policy_version"] = "0.1.0" if row["challenge_policy_version"].to_s.strip.empty?
    row["challenge_audit_status"] = "pending_v1_audit" if row["challenge_audit_status"].to_s.strip.empty?
    missing = OUTPUT_FIELDS.select { |field| !row.key?(field) }
    raise "Entry #{row['id']} is missing fields: #{missing.join(', ')}" unless missing.empty?

    date = Date.iso8601(row.fetch("publication_date"))
    expected_period = date.strftime("%Y-%m")
    raise "Entry #{row['id']} period #{row['period']} != #{expected_period}" unless row["period"] == expected_period

    components = SCORE_FIELDS.to_h { |field| [field, Integer(row.fetch(field), 10)] }
    raise "Entry #{row['id']} has invalid P" unless [0, 1].include?(components["prior_target"])
    raise "Entry #{row['id']} has invalid A" unless [0, 1, 2].include?(components["advance"])
    %w[scope resistance].each do |field|
      raise "Entry #{row['id']} has invalid #{field}" unless [0, 1].include?(components[field])
    end
    score = components.values.sum

    framing = row["framing_year"].to_s.strip.empty? ? nil : Integer(row["framing_year"], 10)
    solution = row["solution_year"].to_s.strip.empty? ? nil : Integer(row["solution_year"], 10)
    raise "Entry #{row['id']} has a framing year but no solution year" if framing && solution.nil?
    raise "Entry #{row['id']} solution predates framing" if framing && solution < framing
    age = framing && solution ? (solution - framing) / 10.0 : nil

    row["difficulty_score"] = score.to_s
    row["category"] = category_for(row, score, age)
    row["age_decades"] = age.nil? ? "" : format("%.1f", age)
    row["provisional"] = truthy?(row["provisional"]) ? "1" : "0"
    row["coding_confidence"] = row["coding_confidence"].to_s.strip.downcase
    raise "Entry #{row['id']} has no anchor claim" if row["anchor_claim"].to_s.strip.empty?
    raise "Entry #{row['id']} has no description" if row["description"].to_s.strip.empty?
  end

  rows.sort_by { |row| [row.fetch("publication_date"), natural_id_key(row.fetch("id"))] }
end

def write_csv(path, rows, fields)
  CSV.open(path, "w", write_headers: true, headers: fields, force_quotes: false) do |csv|
    rows.each { |row| csv << fields.map { |field| row[field] } }
  end
end

def derive_monthly(rows, collection_end)
  by_period = rows.group_by { |row| row.fetch("period") }
  result = []
  each_month("2025-01", collection_end.strftime("%Y-%m")) do |period|
    entries = by_period.fetch(period, [])
    counts = Hash.new(0)
    entries.each { |row| counts[row.fetch("category")] += 1 }
    total = entries.length
    non_expected = counts.fetch("Difficult", 0) + counts.fetch("Superhuman", 0)
    mean = total.zero? ? 0.0 : entries.sum { |row| Integer(row.fetch("difficulty_score"), 10) }.fdiv(total)
    result << {
      "period" => period,
      "expected" => counts.fetch("Expected", 0).to_s,
      "difficult" => counts.fetch("Difficult", 0).to_s,
      "superhuman" => counts.fetch("Superhuman", 0).to_s,
      "total" => total.to_s,
      "non_expected_share" => format("%.6f", total.zero? ? 0.0 : non_expected.fdiv(total)),
      "mean_score" => format("%.3f", mean)
    }
  end
  result
end

def derive_takeoff(monthly, collection_end)
  cumulative = 0
  monthly.map do |row|
    cumulative += Integer(row.fetch("total"), 10)
    period = row.fetch("period")
    if period == collection_end.strftime("%Y-%m") && collection_end.day < Date.new(collection_end.year, collection_end.month, -1).day
      period = "#{period}-through-#{format('%02d', collection_end.day)}"
    end
    {
      "period" => period,
      "new_audited_entries" => row.fetch("total"),
      "cumulative_audited_entries" => cumulative.to_s
    }
  end
end

def data_city_svg(monthly)
  recent = monthly.last(7)
  raise "Data city requires seven monthly rows" unless recent.length == 7

  colors = { "Expected" => "#b8b8b8", "Difficult" => "#2a7ae2", "Superhuman" => "#7b2cbf" }
  highlights = { "Expected" => "#cecece", "Difficult" => "#4c91ea", "Superhuman" => "#9149cc" }
  fields = { "Expected" => "expected", "Difficult" => "difficult", "Superhuman" => "superhuman" }
  tile = 50
  tile_gap = 7
  cluster_gap = 8
  padding = 7
  shadow = 5

  clusters = recent.map do |row|
    total = Integer(row.fetch("total"), 10)
    next if total.zero?

    columns = if total == 1
                1
              elsif total <= 4
                2
              elsif total <= 9
                3
              elsif total <= 16
                4
              else
                [[Math.sqrt(total * 1.25).ceil, 5].max, 8].min
              end
    row_count = (total + columns - 1) / columns
    {
      row: row,
      total: total,
      columns: columns,
      width: columns * tile + (columns - 1) * tile_gap,
      height: row_count * tile + (row_count - 1) * tile_gap
    }
  end.compact
  raise "Data city has no non-empty month" if clusters.empty?

  city_width = clusters.sum { |cluster| cluster.fetch(:width) } + cluster_gap * (clusters.length - 1)
  city_height = clusters.map { |cluster| cluster.fetch(:height) }.max
  width = city_width + 2 * padding + shadow
  height = city_height + 2 * padding + shadow
  ground = padding + city_height
  cursor_x = padding
  block_count = 0
  lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    %(<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 #{width} #{height}" width="#{width}" height="#{height}" fill="none">)
  ]

  clusters.each do |cluster|
    row = cluster.fetch(:row)
    total = cluster.fetch(:total)
    columns = cluster.fetch(:columns)
    centre_x = cursor_x + cluster.fetch(:width).fdiv(2)
    tile_index = 0
    lines << %(  <g data-period="#{xml_escape(row.fetch('period'))}">)
    fields.each do |label, field|
      Integer(row.fetch(field), 10).times do
        grid_row = tile_index / columns
        column = tile_index % columns
        row_count = [columns, total - grid_row * columns].min
        row_width = row_count * tile + [row_count - 1, 0].max * tile_gap
        x = centre_x - row_width.fdiv(2) + column * (tile + tile_gap)
        y = ground - tile - grid_row * (tile + tile_gap)
        lines << format('    <rect x="%g" y="%g" width="%d" height="%d" rx="4" fill="#e6e6e6"/>', x + shadow, y + shadow, tile, tile)
        lines << format('    <rect x="%g" y="%g" width="%d" height="%d" rx="3" fill="%s"/>', x, y, tile, tile, colors.fetch(label))
        lines << format('    <path d="M%g %gH%g" stroke="%s" stroke-width="3" stroke-linecap="round"/>', x + 6, y + 6, x + tile - 6, highlights.fetch(label))
        tile_index += 1
        block_count += 1
      end
    end
    lines << "  </g>"
    cursor_x += cluster.fetch(:width) + cluster_gap
  end
  lines << "</svg>"
  expected = recent.sum { |row| Integer(row.fetch("total"), 10) }
  raise "Data-city block mismatch: #{block_count} != #{expected}" unless block_count == expected

  [lines.join("\n") + "\n", width, height]
end

ledger_path = File.join(PUBLIC_DATA, LEDGER_NAME)
rows = validate_and_normalize(CSV.read(ledger_path, headers: true).map(&:to_h))
log_path = File.join(PUBLIC_DATA, "analysis-log.json")
analysis_log = JSON.parse(File.read(log_path, encoding: "UTF-8"))
raise "Analysis log is empty" if analysis_log.empty?
latest_run = analysis_log.max_by do |run|
  [
    Date.iso8601(run.fetch("collectionEnded")),
    Date.iso8601(run.fetch("recordedAt")),
    run.fetch("id")
  ]
end
collection_end = Date.iso8601(latest_run.fetch("collectionEnded"))
raise "Latest analysis-log entry count does not match ledger" unless latest_run.fetch("entryCount") == rows.length

reference_path = File.join(PUBLIC_DATA, "reference-map.json")
reference_map = JSON.parse(File.read(reference_path, encoding: "UTF-8"))
missing_references = rows.map { |row| row.fetch("id") }.reject { |id| reference_map[id].is_a?(Array) && !reference_map[id].empty? }
extra_references = reference_map.keys - rows.map { |row| row.fetch("id") }
raise "Missing references for: #{missing_references.join(', ')}" unless missing_references.empty?
raise "References remain for removed IDs: #{extra_references.join(', ')}" unless extra_references.empty?

write_csv(ledger_path, rows, OUTPUT_FIELDS)
monthly = derive_monthly(rows, collection_end)
write_csv(File.join(PUBLIC_DATA, MONTHLY_NAME), monthly,
          %w[period expected difficult superhuman total non_expected_share mean_score])
takeoff = derive_takeoff(monthly, collection_end)
write_csv(File.join(PUBLIC_DATA, TAKEOFF_NAME), takeoff,
          %w[period new_audited_entries cumulative_audited_entries])

FileUtils.mkdir_p(PACKAGE_DATA)
SYNCED_NAMES.each do |name|
  FileUtils.cp(File.join(PUBLIC_DATA, name), File.join(PACKAGE_DATA, name))
end

svg, svg_width, svg_height = data_city_svg(monthly)
[PUBLIC_ROOT, PACKAGE_ROOT].each do |root|
  File.write(File.join(root, "data-city.svg"), svg, encoding: "UTF-8")
end

zip_path = File.join(PUBLIC_DATA, ZIP_NAME)
FileUtils.rm_f(zip_path)
ok = system("zip", "-X", "-q", ZIP_NAME, *SYNCED_NAMES, chdir: PUBLIC_DATA)
raise "Could not create #{ZIP_NAME}" unless ok
FileUtils.cp(zip_path, File.join(PACKAGE_DATA, ZIP_NAME))

counts = Hash.new(0)
rows.each { |row| counts[row.fetch("category")] += 1 }
mean = rows.sum { |row| Integer(row.fetch("difficulty_score"), 10) }.fdiv(rows.length)
puts "Validated and regenerated #{rows.length} entries"
puts "Expected=#{counts.fetch('Expected', 0)}, Difficult=#{counts.fetch('Difficult', 0)}, Superhuman=#{counts.fetch('Superhuman', 0)}, mean=#{format('%.2f', mean)}"
puts "Data city dimensions: #{svg_width}x#{svg_height}"
puts "Collection end: #{collection_end.iso8601}"
