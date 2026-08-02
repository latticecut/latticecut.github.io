#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"

entries = JSON.parse(File.read(File.join(__dir__, "ai_math_update_2026_08_02_entries.json"), encoding: "UTF-8"))
references = JSON.parse(File.read(File.join(__dir__, "ai_math_update_2026_08_02_references.json"), encoding: "UTF-8"))

included = entries.map do |row|
  {
    "decision" => "include",
    "id" => row.fetch("id").to_s,
    "publication_date" => row.fetch("publication_date"),
    "anchor_claim" => row.fetch("anchor_claim"),
    "category" => row.fetch("category"),
    "score" => row.fetch("difficulty_score"),
    "provisional" => row.fetch("provisional"),
    "sources" => references.fetch(row.fetch("id").to_s).map { |source| source.fetch("url") }
  }
end

removed = [
  {
    "decision" => "remove_baseline",
    "id" => "23",
    "reason" => "Refreshed novelty evidence showed that the claimed outcome was a rediscovery of a result established in 1947."
  },
  {
    "decision" => "remove_baseline",
    "id" => "32",
    "reason" => "Refreshed dependency evidence showed that the stated result already followed from work published in 2024."
  }
]

excluded = [
  {
    "decision" => "exclude",
    "source" => "https://doi.org/10.48550/arXiv.2607.21196",
    "title" => "Case study: solving P-99 with LPTP and an LLM",
    "reason" => "Known programming exercises and formalization/verification of their solutions, not a new frontier mathematical outcome."
  },
  {
    "decision" => "exclude",
    "source" => "https://doi.org/10.48550/arXiv.2607.19769",
    "title" => "The remaining strict off-diagonal cases of Weissler's conjecture",
    "reason" => "The disclosure records generic AI-tool use, while the authors checked and wrote the mathematical arguments; no sufficiently material result-producing AI role was documented."
  },
  {
    "decision" => "exclude",
    "source" => "https://doi.org/10.48550/arXiv.2607.19817",
    "title" => "A proof of Fajtlowicz's graph-energy conjecture",
    "reason" => "AI use was disclosed only for ideation, without evidence that AI materially produced the qualifying mathematical result."
  },
  {
    "decision" => "exclude",
    "source" => "https://doi.org/10.48550/arXiv.2607.24714",
    "title" => "Efficient LLM-Generated Shuttling Compilers for Complex Trapped-Ion Architectures",
    "reason" => "Software implementation and workload benchmarks; no theorem, certified optimum, or public mathematical frontier result meeting the corpus rule."
  },
  {
    "decision" => "exclude",
    "source" => "https://doi.org/10.48550/arXiv.2607.25865",
    "title" => "OmniQEC: discovering practical quantum error-correcting codes by an AI scientist",
    "reason" => "Simulated hardware/noise performance without an exact certified record, bound, or new theorem satisfying the evidence rule."
  },
  {
    "decision" => "exclude",
    "source" => "https://doi.org/10.48550/arXiv.2607.25391",
    "title" => "A smooth projective counterexample to Bondal-Polishchuk's conjecture",
    "reason" => "The disclosed AI role was finding mistakes and a mistaken citation, not producing the counterexample or mathematical result."
  }
]

register = {
  "run_id" => "2026-08-02-data-refresh",
  "cutoff" => "2026-08-02",
  "discovery_summary" => {
    "arxiv_window" => "2026-07-01 through 2026-08-02",
    "arxiv_entries_screened" => 7_880,
    "keyword_union_records" => 307,
    "tracker_snapshot" => "kingy-breakthrough-tracker 2026-08-01.1",
    "included_update_packages" => included.length,
    "removed_baseline_packages" => removed.length,
    "explicit_borderline_exclusions" => excluded.length
  },
  "included" => included,
  "removed" => removed,
  "explicit_exclusions" => excluded,
  "screening_note" => "The preserved 307-record keyword union is the complete candidate-level trace. Records not listed as inclusions or explicit borderline exclusions failed basic scope, dated-source, mathematical-outcome, or material-AI-role gates."
}

path = "/private/tmp/ai_math_update_decision_register_2026_08_02.json"
File.write(path, JSON.pretty_generate(register) + "\n", encoding: "UTF-8")
puts "Wrote #{path}: #{included.length} inclusions, #{removed.length} removals, #{excluded.length} explicit exclusions"
