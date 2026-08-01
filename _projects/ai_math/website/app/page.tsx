"use client";

import { useEffect, useMemo, useState } from "react";

type Entry = {
  id: string;
  period: string;
  prior_target: string;
  advance: string;
  scope: string;
  resistance: string;
  difficulty_score: string;
  category: ChallengeTier;
  framing_year: string;
  solution_year: string;
  age_decades: string;
  provisional: string;
  description: string;
  anchor_claim: string;
  prior_rationale: string;
  advance_rationale: string;
  scope_rationale: string;
  resistance_rationale: string;
  age_rationale: string;
  coding_confidence: string;
};

type Month = {
  period: string;
  expected: string;
  difficult: string;
  superhuman: string;
  total: string;
  non_expected_share: string;
  mean_score: string;
};

type Takeoff = {
  period: string;
  new_audited_entries: string;
  cumulative_audited_entries: string;
};

type SortKey = "period" | "difficulty_score" | "anchor_claim";

type Citation = {
  key: string;
  title: string;
  url: string;
};

type ReferenceMap = Record<string, Citation[]>;

type AnalysisRun = {
  id: string;
  collectionEnded: string;
  recordedAt: string;
  model: string;
  modelStatus: "recorded" | "unknown";
  entryCount: number;
  summary: string;
  changes: string[];
};

type ChallengeTier = "Expected" | "Difficult" | "Superhuman";

function parseCsv<T>(text: string): T[] {
  const rows: string[][] = [];
  let row: string[] = [];
  let field = "";
  let quoted = false;
  for (let i = 0; i < text.length; i++) {
    const char = text[i];
    if (char === '"' && quoted && text[i + 1] === '"') {
      field += '"';
      i++;
    } else if (char === '"') quoted = !quoted;
    else if (char === "," && !quoted) {
      row.push(field);
      field = "";
    } else if ((char === "\n" || char === "\r") && !quoted) {
      if (char === "\r" && text[i + 1] === "\n") i++;
      row.push(field);
      if (row.some(Boolean)) rows.push(row);
      row = [];
      field = "";
    } else field += char;
  }
  if (field || row.length) {
    row.push(field);
    rows.push(row);
  }
  const [headers, ...values] = rows;
  return values.map((valuesRow) =>
    Object.fromEntries(headers.map((header, index) => [header, valuesRow[index] ?? ""]))
  ) as T[];
}

function monthLabel(period: string) {
  const clean = period.slice(0, 7);
  const [year, month] = clean.split("-").map(Number);
  return new Intl.DateTimeFormat("en", { month: "short", year: "2-digit" }).format(
    new Date(year, month - 1, 1)
  );
}

function fullDate(value: string) {
  return new Intl.DateTimeFormat("en-GB", {
    day: "numeric",
    month: "long",
    year: "numeric",
    timeZone: "UTC",
  }).format(new Date(`${value}T00:00:00Z`));
}

export default function Home() {
  const [entries, setEntries] = useState<Entry[]>([]);
  const [months, setMonths] = useState<Month[]>([]);
  const [takeoff, setTakeoff] = useState<Takeoff[]>([]);
  const [references, setReferences] = useState<ReferenceMap>({});
  const [analysisLog, setAnalysisLog] = useState<AnalysisRun[]>([]);
  const [loading, setLoading] = useState(true);
  const [query, setQuery] = useState("");
  const [challenge, setChallenge] = useState("all");
  const [from, setFrom] = useState("2025-01");
  const [to, setTo] = useState("2026-07");
  const [sortKey, setSortKey] = useState<SortKey>("period");
  const [sortDirection, setSortDirection] = useState<"asc" | "desc">("desc");
  const [chartMode, setChartMode] = useState<"volume" | "share">("volume");

  useEffect(() => {
    Promise.all([
      fetch("/data/difficulty_scored_entries.csv").then((r) => r.text()),
      fetch("/data/difficulty_monthly_breakdown.csv").then((r) => r.text()),
      fetch("/data/takeoff_counts_jan2025.csv").then((r) => r.text()),
      fetch("/data/reference-map.json").then((r) => r.json() as Promise<ReferenceMap>),
      fetch("/data/analysis-log.json").then((r) => r.json() as Promise<AnalysisRun[]>),
    ]).then(([entryCsv, monthCsv, takeoffCsv, referenceMap, log]) => {
      setEntries(parseCsv<Entry>(entryCsv));
      setMonths(parseCsv<Month>(monthCsv));
      setTakeoff(parseCsv<Takeoff>(takeoffCsv));
      setReferences(referenceMap);
      setAnalysisLog(log);
      setLoading(false);
    });
  }, []);

  const filtered = useMemo(() => {
    const needle = query.toLowerCase().trim();
    return entries
      .filter((entry) => entry.period >= from && entry.period <= to)
      .filter((entry) => challenge === "all" || entry.category === challenge)
      .filter((entry) => !needle || entry.anchor_claim.toLowerCase().includes(needle))
      .sort((a, b) => {
        const left = sortKey === "difficulty_score" ? Number(a[sortKey]) : a[sortKey].toLowerCase();
        const right = sortKey === "difficulty_score" ? Number(b[sortKey]) : b[sortKey].toLowerCase();
        const comparison = left < right ? -1 : left > right ? 1 : 0;
        return sortDirection === "asc" ? comparison : -comparison;
      });
  }, [entries, from, to, challenge, query, sortKey, sortDirection]);

  const visibleMonths = months.filter((month) => month.period >= from && month.period <= to);
  const expectedCount = filtered.filter((entry) => entry.category === "Expected").length;
  const difficultCount = filtered.filter((entry) => entry.category === "Difficult").length;
  const superhumanCount = filtered.filter((entry) => entry.category === "Superhuman").length;
  const avgScore = filtered.length
    ? filtered.reduce((sum, entry) => sum + Number(entry.difficulty_score), 0) / filtered.length
    : 0;
  const latestCumulative = Number(takeoff.at(-1)?.cumulative_audited_entries ?? 0);
  const maxTotal = Math.max(
    1,
    ...visibleMonths.map((month) => filtered.filter((entry) => entry.period === month.period).length)
  );
  const peakMonth = visibleMonths
    .map((month) => ({
      period: month.period,
      count: filtered.filter((entry) => entry.period === month.period).length,
    }))
    .reduce(
      (best, current) => current.count > best.count ? current : best,
      { period: "", count: 0 }
    );

  function changeSort(next: SortKey) {
    if (next === sortKey) setSortDirection((current) => (current === "asc" ? "desc" : "asc"));
    else {
      setSortKey(next);
      setSortDirection(next === "anchor_claim" ? "asc" : "desc");
    }
  }

  function resetFilters() {
    setQuery("");
    setChallenge("all");
    setFrom("2025-01");
    setTo("2026-07");
  }

  return (
    <main>
      <header className="topbar">
        <a className="brand" href="https://latticecut.github.io/" aria-label="SuperLattice home">
          SuperLattice <span lang="zh">非常格子</span>
        </a>
        <nav aria-label="Page sections">
          <a href="https://latticecut.github.io/about/">About</a>
          <a href="https://latticecut.github.io/publications/">Publications</a>
        </nav>
      </header>

      <section className="hero" id="top">
        <div className="heroLead">
          <div className="heroText">
            <div className="eyebrow">Research project · Evidence through 21 July 2026</div>
            <h1>AI and mathematical proof progress</h1>
            <p className="heroCopy">
              An exploratory record of audited AI contributions to automated and semi-automated mathematical
              proofs, constructions, bounds and counterexamples. Use the controls below to examine how the
              evidence has developed since early 2025.
            </p>
            <div className="heroMeta">
              <a href="#progress">Explore the data ↓</a>
              <a href="/report/ai-mathematical-proof-analysis.pdf" target="_blank">Read the full report ↗</a>
            </div>
          </div>
          <figure className="heroPortrait">
            {/* This is a deterministic vector rendering of the real result blocks. */}
            {/* eslint-disable-next-line @next/next/no-img-element */}
            <img
              src="/data-city.svg"
              width="929"
              height="297"
              loading="eager"
              fetchPriority="high"
              alt="A block city of recent audited AI mathematical proof results, coloured by challenge category"
            />
          </figure>
        </div>
        <aside className="provenanceNotice" aria-label="AI analysis disclaimer">
          <strong>AI analysis disclaimer</strong>
          <p>
            This is an AI-assisted analysis, not an expert-reviewed census. The current evidence
            collection was last run through <strong>21 July 2026</strong> and contains 64 audited
            entries. The supplied source bundle does not record which model produced that baseline
            collection. This dashboard and the hybrid-scoring rerun were prepared with
            <strong> OpenAI Codex, based on GPT-5</strong>. Treat the classifications as reproducible
            proxies and check substantive claims against the linked works.
          </p>
        </aside>
      </section>

      <section className="dashboard" id="progress">
        <div className="sectionHeading">
          <div>
            <span className="sectionNumber">01</span>
            <h2>Progress at a glance</h2>
          </div>
          <p>Adjust the controls to update the chart, summary cards and evidence table together.</p>
        </div>

        <div className="filterPanel" aria-label="Dataset filters">
          <label className="searchField">
            <span>Search evidence</span>
            <input value={query} onChange={(e) => setQuery(e.target.value)} placeholder="Try ‘Lean’, ‘Erdős’ or ‘counterexample’" />
          </label>
          <label><span>From</span><input type="month" value={from} min="2025-01" max={to} onChange={(e) => setFrom(e.target.value)} /></label>
          <label><span>To</span><input type="month" value={to} min={from} max="2026-07" onChange={(e) => setTo(e.target.value)} /></label>
          <label><span>Challenge</span><select value={challenge} onChange={(e) => setChallenge(e.target.value)}><option value="all">All entries</option><option value="Expected">Expected</option><option value="Difficult">Difficult</option><option value="Superhuman">Superhuman</option></select></label>
          <button className="resetButton" onClick={resetFilters}>Reset</button>
        </div>

        <div className="metricGrid" aria-live="polite">
          <article><span>Matching entries</span><strong>{loading ? "—" : filtered.length}</strong><small>of {latestCumulative} audited</small></article>
          <article><span>Expected</span><strong>{loading ? "—" : expectedCount}</strong><small>hybrid score 0–2</small></article>
          <article><span>Difficult</span><strong>{loading ? "—" : difficultCount}</strong><small>hybrid score 3–5</small></article>
          <article><span>Superhuman</span><strong>{loading ? "—" : superhumanCount}</strong><small>settled after at least one decade</small></article>
          <article><span>Mean challenge score</span><strong>{loading ? "—" : avgScore.toFixed(1)}</strong><small>on the 0–5 P+A+S+R scale</small></article>
          <article className="accentMetric"><span>Peak month</span><strong>{loading || !peakMonth.period ? "—" : monthLabel(peakMonth.period)}</strong><small>{loading ? "calculating" : `${peakMonth.count} matching result${peakMonth.count === 1 ? "" : "s"}`}</small></article>
        </div>

        <article className="chartCard">
          <div className="chartHeader">
            <div><span className="kicker">Monthly series</span><h3>Audited activity over time</h3></div>
            <div className="segmented" aria-label="Chart metric">
              <button className={chartMode === "volume" ? "active" : ""} onClick={() => setChartMode("volume")}>Volume</button>
              <button className={chartMode === "share" ? "active" : ""} onClick={() => setChartMode("share")}>Difficult+ share</button>
            </div>
          </div>
          <div className="legend"><span className="dot expected" /> Expected <span className="dot difficult" /> Difficult <span className="dot superhuman" /> Superhuman</div>
          <div className="barChart" role="img" aria-label="Monthly audited AI mathematics entries">
            {visibleMonths.map((month) => {
              const monthEntries = filtered.filter((entry) => entry.period === month.period);
              const total = monthEntries.length;
              const superhuman = monthEntries.filter((entry) => entry.category === "Superhuman").length;
              const difficult = monthEntries.filter((entry) => entry.category === "Difficult").length;
              const expected = monthEntries.filter((entry) => entry.category === "Expected").length;
              const nonExpected = difficult + superhuman;
              const nonExpectedShare = total ? nonExpected / total * 100 : 0;
              const height = chartMode === "volume" ? total / maxTotal * 100 : nonExpectedShare;
              const denominator = chartMode === "volume" ? total : nonExpected;
              const expectedRatio = chartMode === "volume" && denominator ? expected / denominator * 100 : 0;
              const difficultRatio = denominator ? difficult / denominator * 100 : 0;
              const superhumanRatio = denominator ? superhuman / denominator * 100 : 0;
              return <div className="barColumn" key={month.period} title={`${monthLabel(month.period)}: ${expected} expected, ${difficult} difficult, ${superhuman} superhuman`}>
                <span className="barValue">{chartMode === "volume" ? total : `${Math.round(nonExpectedShare)}%`}</span>
                <div className="barTrack">
                  <div className="barStack" style={{ height: `${height}%` }}>
                    <i className="barSuperhuman" style={{ height: `${superhumanRatio}%` }} />
                    <i className="barDifficult" style={{ height: `${difficultRatio}%` }} />
                    {chartMode === "volume" && <i className="barExpected" style={{ height: `${expectedRatio}%` }} />}
                  </div>
                </div>
                <span className="barLabel">{monthLabel(month.period)}</span>
                <span className="srOnly">{expected} expected, {difficult} difficult and {superhuman} superhuman</span>
              </div>;
            })}
          </div>
          <p className="chartNote">Zero months are retained so the acceleration in activity is not overstated. Hover a bar for its exact values.</p>
        </article>
      </section>

      <section className="evidenceSection" id="evidence">
        <div className="sectionHeading light">
          <div><span className="sectionNumber">02</span><h2>Explore the evidence</h2></div>
          <p>{filtered.length} results match your current filters. Select a column heading to sort.</p>
        </div>
        <div className="tableWrap">
          <table>
            <thead><tr>
              <th><button onClick={() => changeSort("period")}>Date {sortKey === "period" ? (sortDirection === "asc" ? "↑" : "↓") : ""}</button></th>
              <th><button onClick={() => changeSort("anchor_claim")}>Contribution {sortKey === "anchor_claim" ? (sortDirection === "asc" ? "↑" : "↓") : ""}</button></th>
              <th><button onClick={() => changeSort("difficulty_score")}>Score {sortKey === "difficulty_score" ? (sortDirection === "asc" ? "↑" : "↓") : ""}</button></th>
              <th>Classification</th>
            </tr></thead>
            <tbody>
              {filtered.map((entry) => <tr key={entry.id}>
                <td data-label="Date">{monthLabel(entry.period)}</td>
                <td data-label="Contribution">
                  <p>{entry.anchor_claim}</p>
                  <div className="citationLinks" aria-label={`Cited works for entry ${entry.id}`}>
                    <span>Source{references[entry.id]?.length === 1 ? "" : "s"}:</span>
                    {references[entry.id]?.map((citation) => (
                      <a key={citation.key} href={citation.url} target="_blank" rel="noreferrer" title={citation.title}>
                        {citation.title} ↗
                      </a>
                    ))}
                  </div>
                  <small>ID {entry.id}</small>
                </td>
                <td data-label="Score">
                  <span className={`score score${entry.difficulty_score}`}>{entry.difficulty_score}</span>
                  <small className="scoreBreakdown">P{entry.prior_target} · A{entry.advance} · S{entry.scope} · R{entry.resistance}</small>
                </td>
                <td data-label="Classification">
                  <span className={`badge ${entry.category.toLowerCase()}`}>{entry.category}</span>
                  {entry.provisional === "1" && <span className="badge provisional">Provisional</span>}
                  {entry.category === "Superhuman" && <small className="tierBasis">{entry.age_decades} decades from framing to solution ({entry.framing_year}–{entry.solution_year})</small>}
                  <details className="scoreDetails">
                    <summary>Why this score</summary>
                    <p><strong>Anchor:</strong> {entry.anchor_claim}</p>
                    <p><strong>P{entry.prior_target}:</strong> {entry.prior_rationale}</p>
                    <p><strong>A{entry.advance}:</strong> {entry.advance_rationale}</p>
                    <p><strong>S{entry.scope}:</strong> {entry.scope_rationale}</p>
                    <p><strong>R{entry.resistance}:</strong> {entry.resistance_rationale}</p>
                    {entry.age_rationale && <p><strong>History:</strong> {entry.age_rationale}</p>}
                  </details>
                </td>
              </tr>)}
            </tbody>
          </table>
          {!loading && filtered.length === 0 && <div className="emptyState"><strong>No matching evidence</strong><span>Try a wider date range or clear the search.</span><button onClick={resetFilters}>Reset filters</button></div>}
        </div>
      </section>

      <section className="methodSection" id="method">
        <div className="sectionHeading"><div><span className="sectionNumber">03</span><h2>How to read this analysis</h2></div></div>
        <div className="methodGrid">
          <article><span className="methodIndex">A</span><h3>What counts?</h3><p>Each row is one supplied public result package, not necessarily one unique problem. This rerun holds the 64-row baseline fixed; the score rationales flag later novelty corrections rather than silently changing the corpus.</p></article>
          <article><span className="methodIndex">B</span><h3>What is the score?</h3><p><strong>D = P + A + S + R</strong>, from 0 to 5. P records a documented prior target; A scores the advance from 0 to 2; S records uniform or general scope; and R requires two independent exact-target attempts or at most 20% success in a predeclared target-specific comparison of at least five runs or systems.</p></article>
          <article><span className="methodIndex">C</span><h3>How are the tiers assigned?</h3><p><strong>Expected</strong> has a score of 0–2. <strong>Difficult</strong> has a score of 3–5. Verification, AI autonomy, prestige, proof length and compute do not add points. Provisional status is shown separately and blocks the Superhuman override.</p></article>
          <article><span className="methodIndex">D</span><h3>What does “superhuman” mean here?</h3><p>It overrides the base tier only when P=1, A=2, the claim is non-provisional, and at least one decade separates precise framing from solution. A=2 is the operational settlement test; the duration is derived from the recorded years. The label describes result history, not novelty or general system capability.</p></article>
        </div>
        <div className="usageNote"><strong>Suggested workflow</strong><span>Start with the date range → compare volume and challenge share → search a topic → sort the evidence by score → consult the report for sources and full context.</span></div>
      </section>

      <section className="logSection" id="analysis-log">
        <div className="sectionHeading">
          <div><span className="sectionNumber">04</span><h2>Analysis log</h2></div>
          <p>Each future data-collection run is added here to preserve its date, model, coverage and material changes.</p>
        </div>
        <div className="runLog">
          {analysisLog.map((run) => (
            <article className="runEntry" key={run.id}>
              <div className="runDate">
                <span>Collected through</span>
                <strong>{fullDate(run.collectionEnded)}</strong>
                <small>Logged {fullDate(run.recordedAt)}</small>
              </div>
              <div className="runDetails">
                <div className="runMeta">
                  <span>{run.entryCount} entries</span>
                  <span className={run.modelStatus === "unknown" ? "modelUnknown" : ""}>
                    Model: {run.model}
                  </span>
                </div>
                <p>{run.summary}</p>
                {run.changes.length > 0 && <ul>{run.changes.map((change) => <li key={change}>{change}</li>)}</ul>}
              </div>
            </article>
          ))}
          {!loading && analysisLog.length === 0 && <p className="emptyLog">No analysis runs have been recorded.</p>}
        </div>
      </section>

      <footer><div><strong>SuperLattice 非常格子</strong><p>Collected writings and research on AI, science and strategy.</p></div><div><a href="https://github.com/latticecut">GitHub</a><br/><a href="/report/ai-mathematical-proof-analysis.pdf">Download report</a></div><a href="#top">Back to top ↑</a></footer>
    </main>
  );
}
