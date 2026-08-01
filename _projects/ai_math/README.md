# AI Mathematical Proof Analysis

Materials for a project analysing the use of AI in automated and semi-automated
mathematical proofs, with coverage beginning in mid-2025. The current report
extends the analysis through 21 July 2026.

## Project structure

```text
ai-mathematical-proof-analysis/
├── README.md
├── docs/
│   └── original-bundle-readme.txt
├── website/
│   ├── app/
│   ├── public/
│   └── package.json
├── report/
│   ├── main.tex
│   ├── main.pdf
│   ├── references.bib
│   ├── cumulative_takeoff_jan2025.png
│   └── takeoff_counts_jan2025.csv
└── analyses/
    └── difficulty/
        ├── ledger_entries.csv
        ├── run_hybrid_analysis.py
        ├── difficulty_assessments.csv
        ├── difficulty_method.txt
        ├── difficulty_monthly_breakdown.csv
        ├── difficulty_scored_entries.csv
        ├── figure1_stacked_challenge_counts.png
        └── figure1_stacked_challenge_share.png
```

## Contents

- `report/` contains the latest rendered report, its LaTeX source,
  bibliography, and the data and chart used directly by the source.
- `analyses/difficulty/` contains the operational challenge-classification
  rubric, its source ledger, entry-level rationale fields, reproducible analysis
  script, monthly data, and count/share charts.
- `docs/original-bundle-readme.txt` preserves the manifest supplied in the
  original archive.
- `website/` contains the local interactive Proof Progress dashboard. It uses
  copies of the source CSV files under `website/public/data/` so the original
  analysis files remain unchanged.

## Running the local website

```sh
cd website
npm run dev
```

Then open `http://localhost:3000/` in a browser. The dashboard supports linked
date, text and three-tier challenge filters, sortable evidence columns, and
monthly volume and non-expected-share views. The tiers are Expected,
Difficult, and Superhuman; the last is reserved for settled results with
at least one decade between a precise public framing of the same target and
its solution.

### Re-running the challenge analysis

Every entry receives the base score `D = P + A + S + R` on a 0--5 scale:
prior target (`P`, 0--1), mathematical advance (`A`, 0--2), general scope
(`S`, 0--1), and demonstrated resistance (`R`, 0--1). Resistance requires two
independent pre-solution attempts at the exact target, or at most 20% success
in a predeclared target-specific comparison of at least five runs or systems.
Scores 0--2 are
Expected and 3--5 are Difficult. Superhuman overrides the base label only for
a settled, non-provisional result with `P=1`, `A=2`, and at least 1.0 decade
from precise problem framing to solution.

Install the chart dependency, then regenerate the scored ledger, monthly
summaries, charts, website data, and report table from the repository root:

```sh
python3 -m pip install -r analyses/difficulty/requirements.txt
python3 analyses/difficulty/run_hybrid_analysis.py
```

The script validates all 64 IDs, component arithmetic, provisional gating,
and the decade values derived from the recorded framing and solution years.

### Recording a new analysis run

After refreshing the evidence dataset, append a provenance entry to the public
analysis log. Multiple `--change` arguments may be supplied.

```sh
npm run log:analysis -- \
  --collection-ended 2026-08-31 \
  --model "Model name and version" \
  --entries 70 \
  --summary "Monthly evidence refresh through August 2026." \
  --change "Added six audited entries."
```

The command updates `website/public/data/analysis-log.json`, which is displayed
chronologically in the dashboard's Analysis log section.

## Building the report

Run the LaTeX build from inside `report/` so the relative bibliography and
image paths continue to resolve. The analysis script generates
`data-city.svg`; export that same artwork to vector PDF before compiling the
document. The document uses `biblatex` with Biber.

```sh
cd report
inkscape data-city.svg --export-type=pdf --export-filename=data-city.pdf
latexmk -pdf main.tex
```
