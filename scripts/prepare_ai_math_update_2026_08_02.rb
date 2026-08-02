#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "json"

ROOT = File.expand_path("..", __dir__)
SCHEMA = CSV.read(
  File.join(ROOT, "projects", "ai-math", "data", "difficulty_scored_entries.csv"),
  headers: true
).headers.freeze

FRAGMENTS = %w[
  backfill
  extra
  late
  aug1
].freeze

manual_entry = {
  "id" => 54,
  "period" => "2026-07",
  "publication_date" => "2026-07-09",
  "prior_target" => 1,
  "advance" => 2,
  "scope" => 1,
  "resistance" => 1,
  "difficulty_score" => 5,
  "category" => "Superhuman",
  "framing_year" => 1976,
  "solution_year" => 2026,
  "age_decades" => 5.0,
  "provisional" => 0,
  "description" => "real sum-product conjecture. seven independently generated proofs disprove the conjecture over the reals, following the first human disproof in 2026. gpt-5.5 pro autonomously generated correct proofs in seven of eight predeclared trials; the author verified them and released the code, intermediate outputs and proofs. counted as one bounded independent proof package, not as the first solution.",
  "anchor_claim" => "There is a constant c>0 and arbitrarily large finite sets A of real numbers for which both the sumset and product set have size at most |A|^(2-c), disproving the real Erdős-Szemerédi sum-product conjecture.",
  "prior_rationale" => "Erdős formulated the real sum-product target in 1976, and Erdős and Szemerédi later published the standard precise conjecture.",
  "advance_rationale" => "Each verified proof gives a complete disproof of the conjectured near-quadratic lower bound, although a human disproof appeared first in 2026.",
  "scope_rationale" => "The construction supplies arbitrarily large real sets and therefore an unbounded family rather than one finite witness.",
  "resistance_rationale" => "Several independent lines of sum-product research pursued the exact real conjecture before 2026; the seven-of-eight model success rate is recorded but does not itself earn this point under the controlled-comparison threshold.",
  "age_rationale" => "The 1976 framing was disproved in 2026 after 50 years or 5.0 decades; this independent non-provisional proof package meets the duration override.",
  "coding_confidence" => "high"
}

manual_references = {
  "54" => [
    {
      "key" => "Huang2026AutonomousSumProduct",
      "title" => "Autonomous disproofs of the sum-product conjecture over R with GPT-5.5 Pro",
      "url" => "https://doi.org/10.48550/arXiv.2607.20525"
    }
  ]
}

entries = [manual_entry]
references = manual_references.dup

FRAGMENTS.each do |name|
  entry_path = "/private/tmp/ai_math_#{name}_entries.json"
  reference_path = "/private/tmp/ai_math_#{name}_references.json"
  raise "Missing update fragment: #{entry_path}" unless File.file?(entry_path)
  raise "Missing reference fragment: #{reference_path}" unless File.file?(reference_path)

  entries.concat(JSON.parse(File.read(entry_path, encoding: "UTF-8")))
  JSON.parse(File.read(reference_path, encoding: "UTF-8")).each do |id, sources|
    raise "Duplicate reference bucket #{id}" if references.key?(id.to_s)
    references[id.to_s] = sources
  end
end

entry_ids = entries.map { |row| row.fetch("id").to_s }
counts = Hash.new(0)
entry_ids.each { |id| counts[id] += 1 }
duplicates = counts.select { |_id, count| count > 1 }.keys
raise "Duplicate update IDs: #{duplicates.join(', ')}" unless duplicates.empty?
raise "Entry/reference ID mismatch" unless entry_ids.sort == references.keys.map(&:to_s).sort

entries.each do |row|
  row["id"] = row.fetch("id").to_s
  row["coding_confidence"] = row.fetch("coding_confidence").to_s.downcase
  if row.fetch("id") == "79"
    row["advance"] = 1
    row["difficulty_score"] = 4
    row["category"] = "Difficult"
    row["advance_rationale"] = "The construction conditionally matches the prior lower bound for every constant k and is unconditional through k=14; the remaining all-k hypothesis prevents a complete-settlement score."
  end

  raise "Entry #{row['id']} schema mismatch" unless row.keys == SCHEMA
  components = %w[prior_target advance scope resistance].map { |field| Integer(row.fetch(field).to_s, 10) }
  raise "Entry #{row['id']} score mismatch" unless components.sum == Integer(row.fetch("difficulty_score").to_s, 10)
  raise "Entry #{row['id']} period mismatch" unless row.fetch("publication_date").start_with?(row.fetch("period"))
end

entries.sort_by! { |row| Integer(row.fetch("id").to_s, 10) }
references = references.sort_by { |id, _sources| Integer(id, 10) }.to_h

File.write(
  File.join(__dir__, "ai_math_update_2026_08_02_entries.json"),
  JSON.pretty_generate(entries) + "\n",
  encoding: "UTF-8"
)
File.write(
  File.join(__dir__, "ai_math_update_2026_08_02_references.json"),
  JSON.pretty_generate(references) + "\n",
  encoding: "UTF-8"
)

puts "Prepared #{entries.length} update entries with #{references.length} reference buckets"
