#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"

# First public release of the result package represented by each ledger entry.
# For arXiv-backed entries this is the v1 submission date from the arXiv API.
# Non-arXiv exceptions use the dated primary announcement or work itself.
PUBLICATION_DATES = {
  "25--1" => "2025-04-01",
  "25--2" => "2025-05-14",
  "25--3" => "2025-08-11",
  "25--4" => "2025-08-16",
  "25--5" => "2025-09-03",
  "25--6" => "2025-09-17",
  "25--7" => "2025-09-22",
  "25--8" => "2025-09-22",
  "25--9" => "2025-09-22",
  "25--10" => "2025-09-25",
  "25--11" => "2025-10-22",
  "25--12" => "2025-10-27",
  "25--13" => "2025-11-20",
  "25--14" => "2025-11-20",
  "25--15" => "2025-11-20",
  "25--16" => "2025-11-20",
  "25--17" => "2025-11-20",
  "25--18" => "2025-11-28",
  "25--19" => "2025-12-10",
  "25--20" => "2025-12-16",
  "1" => "2026-05-20",
  "2" => "2026-07-09",
  "3" => "2026-04-04",
  "4" => "2026-05-24",
  "5" => "2026-05-24",
  "6" => "2026-05-24",
  "7" => "2026-05-24",
  "8" => "2026-05-24",
  "9" => "2026-05-24",
  "10" => "2026-05-24",
  "11" => "2026-05-20",
  "12" => "2026-04-28",
  "13" => "2026-03-31",
  "14" => "2026-03-31",
  "15" => "2026-03-31",
  "16" => "2026-04-08",
  "17" => "2026-04-08",
  "18" => "2026-04-08",
  "19" => "2026-04-08",
  "20" => "2026-04-08",
  "21" => "2026-02-03",
  "22" => "2026-02-03",
  "23" => "2026-02-04",
  "24" => "2026-02-04",
  "25" => "2026-05-21",
  "26" => "2026-05-21",
  "27" => "2026-05-21",
  "28" => "2026-05-21",
  "29" => "2026-05-21",
  "30" => "2026-05-21",
  "31" => "2026-05-21",
  "32" => "2026-05-21",
  "33" => "2026-05-21",
  "34" => "2026-05-21",
  "35" => "2026-05-21",
  "36" => "2026-05-21",
  "37" => "2026-05-21",
  "38" => "2026-05-21",
  "39" => "2026-05-21",
  "40" => "2026-06-04",
  "41" => "2026-07-15",
  "42" => "2026-03-16",
  "43" => "2026-03-05",
  "44" => "2026-07-20"
}.freeze

paths = ARGV
abort "Pass at least one difficulty_scored_entries.csv path" if paths.empty?

paths.each do |path|
  table = CSV.table(path, converters: nil)
  ids = table.map { |row| row[:id].to_s }
  missing = ids.reject { |id| PUBLICATION_DATES.key?(id) }
  extra = PUBLICATION_DATES.keys - ids
  abort "#{path}: missing dates for #{missing.join(', ')}" unless missing.empty?
  abort "#{path}: date map has unknown IDs #{extra.join(', ')}" unless extra.empty?

  output_headers = table.headers
  output_headers.insert(output_headers.index(:period) + 1, :publication_date) unless output_headers.include?(:publication_date)

  CSV.open(path, "w", write_headers: true, headers: output_headers) do |csv|
    table.each do |row|
      values = output_headers.map do |header|
        header == :publication_date ? PUBLICATION_DATES.fetch(row[:id].to_s) : row[header]
      end
      csv << values
    end
  end
end
