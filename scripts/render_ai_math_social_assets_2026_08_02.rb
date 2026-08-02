#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "date"
require "json"

ROOT = File.expand_path("..", __dir__)
DATA_ROOT = ENV.fetch("AI_MATH_DATA_ROOT", File.join(ROOT, "projects", "ai-math", "data"))
MONTHLY_PATH = File.join(DATA_ROOT, "difficulty_monthly_breakdown.csv")
LEDGER_PATH = File.join(DATA_ROOT, "difficulty_scored_entries.csv")
ANALYSIS_LOG_PATH = File.join(DATA_ROOT, "analysis-log.json")

CATEGORIES = [
  ["Expected", "expected", "#b8b8b8", "#cecece"],
  ["Difficult", "difficult", "#2a7ae2", "#4c91ea"],
  ["Superhuman", "superhuman", "#7b2cbf", "#9149cc"]
].freeze
MONTH_NAMES = %w[JAN FEB MAR APR MAY JUN JUL AUG SEP OCT NOV DEC].freeze

def svg_escape(value)
  value.to_s
       .gsub("&", "&amp;")
       .gsub("<", "&lt;")
       .gsub(">", "&gt;")
       .gsub('"', "&quot;")
end

def integer_field(row, field, context)
  Integer(row.fetch(field), 10)
rescue ArgumentError, KeyError
  raise "#{context} has an invalid #{field.inspect} value"
end

def load_monthly
  rows = CSV.read(MONTHLY_PATH, headers: true).map(&:to_h)
  raise "Monthly breakdown is empty" if rows.empty?

  required = %w[period expected difficult superhuman total]
  missing = required - CSV.open(MONTHLY_PATH, &:readline)
  raise "Monthly breakdown is missing fields: #{missing.join(', ')}" unless missing.empty?

  parsed = rows.map do |row|
    context = "Monthly row #{row['period'].inspect}"
    period_date = Date.strptime("#{row.fetch('period')}-01", "%Y-%m-%d")
    values = {
      "period" => row.fetch("period"),
      "period_date" => period_date,
      "expected" => integer_field(row, "expected", context),
      "difficult" => integer_field(row, "difficult", context),
      "superhuman" => integer_field(row, "superhuman", context),
      "total" => integer_field(row, "total", context)
    }
    category_sum = values["expected"] + values["difficult"] + values["superhuman"]
    raise "#{context} category sum #{category_sum} != total #{values['total']}" unless category_sum == values["total"]
    raise "#{context} contains a negative count" if values.values_at("expected", "difficult", "superhuman", "total").any? { |value| value.negative? }
    values
  end

  sorted = parsed.sort_by { |row| row.fetch("period_date") }
  raise "Monthly breakdown periods are not sorted" unless parsed == sorted
  sorted.each_cons(2) do |first, second|
    unless first.fetch("period_date").next_month == second.fetch("period_date")
      raise "Monthly breakdown skips a calendar month after #{first.fetch('period')}"
    end
  end
  parsed
end

def load_ledger
  rows = CSV.read(LEDGER_PATH, headers: true).map(&:to_h)
  raise "Difficulty ledger is empty" if rows.empty?

  required = %w[id period publication_date category]
  headers = CSV.open(LEDGER_PATH, &:readline)
  missing = required - headers
  raise "Difficulty ledger is missing fields: #{missing.join(', ')}" unless missing.empty?

  ids = rows.map { |row| row.fetch("id") }
  duplicates = ids.group_by { |id| id }.select { |_id, copies| copies.length > 1 }.keys
  raise "Difficulty ledger has duplicate IDs: #{duplicates.join(', ')}" unless duplicates.empty?

  rows.each do |row|
    published = Date.iso8601(row.fetch("publication_date"))
    raise "Ledger entry #{row['id']} has a period/date mismatch" unless published.strftime("%Y-%m") == row.fetch("period")
    unless CATEGORIES.any? { |category| category[0] == row.fetch("category") }
      raise "Ledger entry #{row['id']} has unknown category #{row['category'].inspect}"
    end
  end
  rows
end

def audit_date_for(ledger_count)
  runs = JSON.parse(File.read(ANALYSIS_LOG_PATH, encoding: "UTF-8"))
  matching = runs.select { |run| run["entryCount"].to_i == ledger_count && run["collectionEnded"] }
  raise "Analysis log has no run matching the #{ledger_count}-entry ledger" if matching.empty?

  latest = matching.max_by do |run|
    [Date.iso8601(run.fetch("collectionEnded")), run.fetch("recordedAt", "")]
  end
  Date.iso8601(latest.fetch("collectionEnded"))
end

def validate_monthly_against_ledger(monthly, ledger, audit_date)
  raise "Monthly totals sum to #{monthly.sum { |row| row.fetch('total') }}, not #{ledger.length}" unless monthly.sum { |row| row.fetch("total") } == ledger.length
  raise "Last monthly period does not match the audit date" unless monthly.last.fetch("period") == audit_date.strftime("%Y-%m")

  ledger_counts = Hash.new { |hash, key| hash[key] = Hash.new(0) }
  ledger.each do |row|
    ledger_counts[row.fetch("period")][row.fetch("category")] += 1
  end
  monthly.each do |row|
    CATEGORIES.each do |label, field, _color, _highlight|
      actual = ledger_counts[row.fetch("period")][label]
      expected = row.fetch(field)
      raise "#{row['period']} #{label} count #{expected} != ledger count #{actual}" unless actual == expected
    end
  end
end

def display_date(date)
  "#{date.day} #{date.strftime('%B %Y')}"
end

def month_label(row)
  MONTH_NAMES.fetch(row.fetch("period_date").month - 1)
end

def layout_for(total, tile, gap, slot_width, maximum_height)
  return { columns: 0, rows: 0, width: 0.0, height: 0.0 } if total.zero?

  maximum_columns = ((slot_width + gap).fdiv(tile + gap)).floor
  maximum_rows = ((maximum_height + gap).fdiv(tile + gap)).floor
  return nil if maximum_columns < 1 || maximum_rows < 1 || maximum_columns * maximum_rows < total

  minimum_columns = (total + maximum_rows - 1) / maximum_rows
  ideal_columns = Math.sqrt(total).ceil
  columns = [[ideal_columns, minimum_columns].max, maximum_columns].min
  rows = (total + columns - 1) / columns
  {
    columns: columns,
    rows: rows,
    width: columns * tile + (columns - 1) * gap,
    height: rows * tile + (rows - 1) * gap
  }
end

def city_geometry(rows, slot_width, maximum_height, maximum_tile)
  maximum_tile.downto(4) do |tile|
    gap = [(tile * 0.16).round, 1].max
    layouts = rows.map { |row| layout_for(row.fetch("total"), tile, gap, slot_width, maximum_height) }
    return [tile, gap, layouts] unless layouts.any?(&:nil?)
  end
  raise "Recent monthly counts cannot fit in the requested city area"
end

def append_city(lines, rows, left, baseline, width, maximum_height, maximum_tile, label_y, label_size, compact)
  slot_width = width.fdiv(rows.length)
  tile, gap, layouts = city_geometry(rows, slot_width - (compact ? 5 : 12), maximum_height, maximum_tile)
  shadow = compact ? 1 : [2, (tile * 0.12).round].max
  block_count = 0

  rows.each_with_index do |row, month_index|
    layout = layouts.fetch(month_index)
    centre_x = left + slot_width * month_index + slot_width.fdiv(2)
    total = row.fetch("total")
    lines << format('  <g data-period="%s" data-total="%d">', svg_escape(row.fetch("period")), total)

    if total.zero?
      marker_width = compact ? 10 : 24
      marker_height = compact ? 3 : 7
      lines << format('    <rect x="%.2f" y="%.2f" width="%d" height="%d" rx="%d" fill="#fbfbfb" stroke="#b8b8b8"/>', centre_x - marker_width.fdiv(2), baseline - marker_height, marker_width, marker_height, compact ? 1 : 2)
    else
      tile_index = 0
      CATEGORIES.each do |_label, field, color, highlight|
        row.fetch(field).times do
          grid_row = tile_index / layout.fetch(:columns)
          column = tile_index % layout.fetch(:columns)
          row_count = [layout.fetch(:columns), total - grid_row * layout.fetch(:columns)].min
          row_width = row_count * tile + [row_count - 1, 0].max * gap
          x = centre_x - row_width.fdiv(2) + column * (tile + gap)
          y = baseline - tile - grid_row * (tile + gap)
          radius = compact ? 1.5 : [3, tile * 0.12].max
          line_width = compact ? 0.8 : [1.5, tile * 0.07].max
          inset = compact ? 1.2 : [3, tile * 0.2].min
          lines << format('    <rect x="%.2f" y="%.2f" width="%d" height="%d" rx="%.2f" fill="#e6e6e6"/>', x + shadow, y + shadow, tile, tile, radius)
          lines << format('    <rect x="%.2f" y="%.2f" width="%d" height="%d" rx="%.2f" fill="%s"/>', x, y, tile, tile, radius, color)
          lines << format('    <path d="M%.2f %.2fH%.2f" stroke="%s" stroke-width="%.2f" stroke-linecap="round"/>', x + inset, y + inset, x + tile - inset, highlight, line_width)
          tile_index += 1
          block_count += 1
        end
      end
    end

    label = compact ? "#{month_label(row)} #{total}" : "#{month_label(row)}  ·  #{total}"
    lines << format('    <text x="%.2f" y="%.2f" text-anchor="middle" font-size="%d" font-weight="700" fill="#7d7d7d">%s</text>', centre_x, label_y, label_size, svg_escape(label))
    lines << "  </g>"
  end

  expected_blocks = rows.sum { |row| row.fetch("total") }
  raise "Rendered block count #{block_count} != recent monthly count #{expected_blocks}" unless block_count == expected_blocks
end

def append_legend(lines, counts, items)
  items.each do |item|
    label, _field, color, _highlight = item.fetch(:category)
    x = item.fetch(:x)
    y = item.fetch(:y)
    size = item.fetch(:size)
    font_size = item.fetch(:font_size)
    count = counts.fetch(label)
    lines << format('  <rect x="%.2f" y="%.2f" width="%.2f" height="%.2f" rx="%.2f" fill="%s"/>', x, y, size, size, [2, size * 0.12].max, color)
    lines << format('  <text x="%.2f" y="%.2f" font-size="%.2f" font-weight="600" fill="#454545">%s %d</text>', x + size + item.fetch(:text_gap), y + size * 0.82, font_size, svg_escape(label), count)
  end
end

def render_og(recent, ledger_count, category_counts, audit_date)
  lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1800 945" width="1800" height="945" role="img" aria-labelledby="title description">',
    '  <title id="title">AI and mathematical proof progress</title>',
    format('  <desc id="description">%d audited results through %s, shown as seven recent monthly clusters.</desc>', ledger_count, svg_escape(display_date(audit_date))),
    '  <rect width="1800" height="945" fill="#fbfbfb"/>',
    '  <rect width="1800" height="7" fill="#454545"/>',
    '  <g font-family="Helvetica Neue, Helvetica, Arial, sans-serif">',
    '  <text x="90" y="79" font-size="27" font-weight="400" fill="#454545">SuperLattice</text>',
    format('  <text x="1710" y="78" text-anchor="end" font-size="16" font-weight="700" letter-spacing="0.2" fill="#7d7d7d">DATA CITY · RECENT ACTIVITY · %s</text>', svg_escape(recent.last.fetch("period"))),
    '  <path d="M90 113H1710" stroke="#dddddd" stroke-width="1.5"/>',
    '  <text x="90" y="225" font-size="66" font-weight="400" letter-spacing="-1.5" fill="#454545">AI and mathematical</text>',
    '  <text x="90" y="292" font-size="66" font-weight="400" letter-spacing="-1.5" fill="#454545">proof progress</text>',
    format('  <text x="90" y="466" font-size="124" font-weight="300" letter-spacing="-4" fill="#454545">%d</text>', ledger_count),
    '  <text x="94" y="510" font-size="18" font-weight="700" letter-spacing="0.4" fill="#454545">AUDITED RESULTS</text>',
    format('  <text x="94" y="542" font-size="20" font-weight="400" fill="#7d7d7d">Evidence through %s</text>', svg_escape(display_date(audit_date))),
    '  <text x="730" y="340" font-size="15" font-weight="700" letter-spacing="0.7" fill="#7d7d7d">RECENT MONTHLY CLUSTERS</text>',
    '  <text x="1710" y="340" text-anchor="end" font-size="14" font-weight="700" letter-spacing="0.4" fill="#7d7d7d">ONE BLOCK = ONE AUDITED RESULT</text>',
    '  <rect x="710" y="778" width="1020" height="68" rx="13" fill="#f4f4f4"/>',
    '  <path d="M730 790H1710" stroke="#d8d8d8" stroke-width="1.5"/>'
  ]

  legend_items = CATEGORIES.each_with_index.map do |category, index|
    { category: category, x: 92 + index * 185, y: 605, size: 23, text_gap: 11, font_size: 20 }
  end
  append_legend(lines, category_counts, legend_items)

  lines.concat([
    '  <rect x="90" y="678" width="526" height="112" rx="11" fill="#f3f3f3"/>',
    '  <text x="112" y="716" font-size="16" font-weight="700" fill="#454545">READING THE DATA CITY</text>',
    '  <text x="112" y="750" font-size="17" font-weight="400" fill="#7d7d7d">Each coloured block is one audited result.</text>',
    '  <text x="112" y="775" font-size="17" font-weight="400" fill="#7d7d7d">Clusters cover the latest seven calendar months.</text>'
  ])

  append_city(lines, recent, 730.0, 790.0, 980.0, 390.0, 32, 824.0, 14, false)
  lines << "  </g>"
  lines << "</svg>"
  lines.join("\n") + "\n"
end

def render_thumbnail(recent, ledger_count, category_counts, audit_date)
  lines = [
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400" width="400" height="400" role="img" aria-labelledby="title description">',
    '  <title id="title">AI and mathematical proof progress data city</title>',
    format('  <desc id="description">%d audited results through %s, with seven recent monthly clusters.</desc>', ledger_count, svg_escape(display_date(audit_date))),
    '  <rect width="400" height="400" fill="#fbfbfb"/>',
    '  <rect width="400" height="6" fill="#454545"/>',
    '  <g font-family="Helvetica Neue, Helvetica, Arial, sans-serif">',
    '  <text x="20" y="31" font-size="12" font-weight="700" letter-spacing="0.5" fill="#7d7d7d">AI · MATHEMATICAL PROOF</text>',
    format('  <text x="18" y="123" font-size="96" font-weight="300" letter-spacing="-4" fill="#454545">%d</text>', ledger_count),
    '  <text x="185" y="76" font-size="13" font-weight="700" letter-spacing="0.4" fill="#454545">AUDITED RESULTS</text>',
    format('  <text x="185" y="101" font-size="13" font-weight="400" fill="#7d7d7d">through %s</text>', svg_escape(display_date(audit_date))),
    '  <path d="M20 177H380" stroke="#dddddd" stroke-width="1"/>',
    '  <text x="20" y="204" font-size="10" font-weight="700" letter-spacing="0.5" fill="#7d7d7d">RECENT MONTHLY CLUSTERS</text>',
    '  <text x="380" y="204" text-anchor="end" font-size="9" font-weight="700" fill="#7d7d7d">1 BLOCK = 1 RESULT</text>',
    '  <rect x="15" y="342" width="370" height="43" rx="8" fill="#f4f4f4"/>',
    '  <path d="M20 350H380" stroke="#d8d8d8" stroke-width="1"/>'
  ]

  legend_items = CATEGORIES.each_with_index.map do |category, index|
    { category: category, x: 20 + index * 123, y: 145, size: 11, text_gap: 5, font_size: 10.5 }
  end
  append_legend(lines, category_counts, legend_items)
  append_city(lines, recent, 20.0, 350.0, 360.0, 127.0, 13, 374.0, 8, true)
  lines << "  </g>"
  lines << "</svg>"
  lines.join("\n") + "\n"
end

monthly = load_monthly
ledger = load_ledger
audit_date = audit_date_for(ledger.length)
validate_monthly_against_ledger(monthly, ledger, audit_date)
raise "At least seven calendar months are required for the social assets" if monthly.length < 7

recent = monthly.last(7)
category_counts = CATEGORIES.to_h do |label, _field, _color, _highlight|
  [label, ledger.count { |row| row.fetch("category") == label }]
end

date_slug = audit_date.iso8601
og_path = File.join("/private/tmp", "ai-math-og-#{date_slug}.svg")
thumbnail_path = File.join("/private/tmp", "ai-math-thumbnail-#{date_slug}.svg")
File.write(og_path, render_og(recent, ledger.length, category_counts, audit_date), mode: "w:UTF-8")
File.write(thumbnail_path, render_thumbnail(recent, ledger.length, category_counts, audit_date), mode: "w:UTF-8")

puts "OG_SVG=#{og_path}"
puts "THUMBNAIL_SVG=#{thumbnail_path}"
puts "AUDITED_RESULTS=#{ledger.length}"
puts "AUDIT_DATE=#{audit_date.iso8601}"
puts "RECENT_PERIODS=#{recent.map { |row| row.fetch('period') }.join(',')}"
