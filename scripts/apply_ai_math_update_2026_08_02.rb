#!/usr/bin/env ruby
# frozen_string_literal: true

require "csv"
require "json"

ROOT = File.expand_path("..", __dir__)
DATA = File.join(ROOT, "projects", "ai-math", "data")
LEDGER = File.join(DATA, "difficulty_scored_entries.csv")
REFERENCES = File.join(DATA, "reference-map.json")
LOG = File.join(DATA, "analysis-log.json")
UPDATE_ROWS = File.join(__dir__, "ai_math_update_2026_08_02_entries.json")
UPDATE_REFERENCES = File.join(__dir__, "ai_math_update_2026_08_02_references.json")
REMOVED_IDS = %w[23 32].freeze

rows = CSV.read(LEDGER, headers: true).map(&:to_h)
fields = rows.first.keys
rows.reject! { |row| REMOVED_IDS.include?(row.fetch("id")) }
by_id = rows.to_h { |row| [row.fetch("id"), row] }

by_id.fetch("12").merge!(
  "period" => "2026-04",
  "anchor_claim" => "Stable tame isomorphism, quasi-isomorphism, and derived Morita equivalence are undecidable for semifree noncommutative differential graded algebras in the stated generality."
)
by_id.fetch("2").merge!(
  "provisional" => "0",
  "category" => "Superhuman",
  "description" => "Cycle Double Cover Conjecture. Every finite loopless bridgeless undirected multigraph has a multiset of cycles covering every edge exactly twice. The AI-generated proof now has a public Lean formalization and independent expert expositions by Jim Geelen and Sang-il Oum.",
  "age_rationale" => "The 2026 proof comes 53 years, or 5.3 decades, after Szekeres's 1973 framing. Formal verification and two independent specialist expositions remove the baseline's provisional hold."
)
by_id.fetch("44").merge!(
  "provisional" => "0",
  "category" => "Superhuman",
  "description" => "Jacobian Conjecture. An explicit polynomial map from C^3 to C^3 has constant nonzero Jacobian determinant but is not injective, disproving the unrestricted conjecture in dimension three and hence every higher dimension. Independent exact symbolic checks and subsequent mathematical analyses verify the announced map.",
  "anchor_claim" => "An explicit three-dimensional polynomial map with constant nonzero Jacobian determinant and multiple preimages disproves the unrestricted Jacobian Conjecture in every dimension at least three.",
  "age_rationale" => "The 2026 counterexample comes 87 years, or 8.7 decades, after Keller's 1939 framing. Multiple independent exact checks remove the baseline's provisional hold."
)

update_rows = JSON.parse(File.read(UPDATE_ROWS, encoding: "UTF-8"))
update_rows.each do |row|
  missing = fields - row.keys
  raise "Update entry #{row['id']} is missing fields: #{missing.join(', ')}" unless missing.empty?
  by_id[row.fetch("id")] = row
end

CSV.open(LEDGER, "w", write_headers: true, headers: fields) do |csv|
  by_id.values.each { |row| csv << fields.map { |field| row[field] } }
end

references = JSON.parse(File.read(REFERENCES, encoding: "UTF-8"))
REMOVED_IDS.each { |id| references.delete(id) }
references["2"] = [
  {
    "key" => "OpenAI2026CDC",
    "title" => "A Proof of the Cycle Double Cover Conjecture",
    "url" => "https://cdn.openai.com/pdf/04d1d1e4-bc75-476a-97cf-49055cd98d31/cdc_proof.pdf"
  },
  {
    "key" => "Geelen2026CDC",
    "title" => "OpenAI's proof of the Cycle Double Cover Theorem",
    "url" => "https://doi.org/10.48550/arXiv.2607.15399"
  },
  {
    "key" => "Oum2026CDC",
    "title" => "An exposition of OpenAI's proof of the Cycle Double Cover Conjecture",
    "url" => "https://doi.org/10.48550/arXiv.2607.16356"
  },
  {
    "key" => "OpenAI2026CDCLean",
    "title" => "Lean formalization of the Cycle Double Cover proof",
    "url" => "https://github.com/openai/cdc-lean"
  }
]
references["44"] = [
  {
    "key" => "Alpoge2026JacobianAnnouncement",
    "title" => "Announcement of an explicit three-dimensional counterexample to the Jacobian Conjecture",
    "url" => "https://x.com/__alpoge__/status/2079028340955197566"
  },
  {
    "key" => "Shaska2026GradedKeller",
    "title" => "Graded Keller maps and the Jacobian Conjecture",
    "url" => "https://doi.org/10.48550/arXiv.2607.20210"
  },
  {
    "key" => "Tao2026JacobianDigest",
    "title" => "A digestion of the Jacobian conjecture counterexample",
    "url" => "https://terrytao.wordpress.com/2026/07/21/a-digestion-of-the-jacobian-conjecture-counterexample/"
  },
  {
    "key" => "Knill2026JacobianCheck",
    "title" => "Exact Mathematica verification of the Jacobian counterexample",
    "url" => "https://www.quantumcalculus.org/jacobian-conjecture-solution/"
  }
]
JSON.parse(File.read(UPDATE_REFERENCES, encoding: "UTF-8")).each do |id, sources|
  references[id] = sources
end
File.write(REFERENCES, JSON.pretty_generate(references) + "\n", encoding: "UTF-8")

log = JSON.parse(File.read(LOG, encoding: "UTF-8"))
log.reject! { |run| run["id"] == "2026-08-02-data-refresh" }
entry_count = by_id.length
added_count = update_rows.length
log << {
  "id" => "2026-08-02-data-refresh",
  "collectionEnded" => "2026-08-02",
  "recordedAt" => "2026-08-02",
  "model" => "OpenAI Codex, based on GPT-5",
  "modelStatus" => "recorded",
  "entryCount" => entry_count,
  "summary" => "Fresh source search and methodology rerun through 2 August 2026, including a systematic July arXiv sweep, announcement searches, retrospective gap correction, and evidence-status rechecks.",
  "changes" => [
    "Added #{added_count} newly audited result packages, separating pre-cutoff backfill from post-cutoff discoveries in the private collection record.",
    "Removed IDs 23 and 32 because refreshed novelty evidence showed that they were rediscoveries already established in 1947 and 2024 respectively.",
    "Retained the three Werner-state packages and two Feige-bound packages as independently generated contributions under the package-counting rule; later support or verification alone was not recounted.",
    "Upgraded the Cycle Double Cover and three-dimensional Jacobian entries from provisional Difficult to non-provisional Superhuman after formal or independent exact checks and specialist expositions.",
    "Corrected ID 12's publication month and changed its anchor from decidable to undecidable.",
    "Recomputed every component total, category, historical duration, monthly aggregate, cumulative count, website visual, and downloadable data bundle."
  ]
}
File.write(LOG, JSON.pretty_generate(log) + "\n", encoding: "UTF-8")

puts "Applied 2 August update: #{added_count} additions, #{REMOVED_IDS.length} removals, #{entry_count} retained entries"
