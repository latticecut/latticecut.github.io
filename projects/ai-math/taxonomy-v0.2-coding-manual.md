# Mathematics Progress taxonomy v0.2 coding manual

Status: operational draft for the v0.2 reliability pilot
Classification unit: one mathematical result, not one paper, model run or repository

This manual accompanies the machine-readable v0.2 schemas and registries. It is deliberately shorter than the full taxonomy explainer: a coder should be able to produce a valid Minimal record from this document, while the explainer provides the rationale and precedents.

## 1. Non-negotiable rules

1. State one canonical mathematical claim before assigning labels.
2. Classify the mathematics of that claim, not the paper's venue or arXiv category.
3. Keep the three browse facets orthogonal: Mathematics, Result and approach, and Production.
4. Store verification as scoped events. Never replace the events with the unqualified word “verified”.
5. Distinguish `unknown`, `not_reported`, `not_applicable` and `unclassified`. They are not synonyms.
6. Cite evidence for every non-obvious assignment and say when a label is only source-claimed.
7. Treat the challenge indicator as linked analytical metadata. It is not a fourth taxonomy facet and is not a measure of importance.
8. Retain **Superhuman** as the project's highest operational challenge category. Its use records that the stated eligibility rule has been met; it does not by itself establish a general human-performance comparison.
9. Give R1, R2 and R3 separate, axis-specific rationale sentences. A record with repeated rationales is not publishable.
10. Use the exact confidence enum: `high`, `medium_high`, `medium`, `medium_low`, `low`, `unknown`, `not_reported`, `not_applicable`. Do not use `medium-high`.

## 2. Minimal and Full profiles

### Minimal

A publishable Minimal record contains:

- stable result ID, canonical claim, record revision and taxonomy version;
- at least one source with its role;
- one complete M1–M3 Mathematics path, or an explicit `unclassified` reason;
- R1 contribution family, the R2 polarity/completeness pair, multi-valued R3 and R4 or an explicit missing state;
- P1 human-machine allocation with `sourceClaimed`, P2–P4 or explicit missing states, and the three-row generation/checking/write-up stage table;
- every material verification event found during the coding pass, or `none_reported`, with row-level `replayedHere`;
- statement correspondence and event-level `replayedHere` on every verification event;
- the four challenge inputs, their `evidenceState`, rationales and sources, including explicit missingness;
- separate significance (`exercise`, `minor` or `publishable`) or an explicit missing state;
- coding rationale, confidence, coder identifier and assignment date.

Minimal does not mean low quality. It means that optional enrichment has not yet been attempted.

### 2.1 Exact Minimal authoring contract

Use camelCase property names exactly as shown below. Arrays marked “one or more” must not be empty; source IDs cited anywhere in a record must occur in that record's `sources` array.

| Area | Required JSON fields |
|---|---|
| Envelope | `schemaVersion: "0.2.0"`, `profile: "minimal"`, `taxonomyVersion: "0.2.0"`, integer `recordRevision >= 1`, `recordType: "result"`, `resultId` beginning `result-`, and a canonical `claim` of at least ten characters |
| Optional linkage | `sourceIncludedId` identifies the source-included unit; `parentPortfolioId` begins `portfolio-` when the result belongs to a multi-result organizational portfolio, including a split source or a cross-source project portfolio |
| Each source | `sourceId`, `sourceType` (`paper`, `preprint`, `artifact`, `repository`, `announcement`, `dataset`, `review`, `other`), `role`, `title`, an HTTP(S) `url`, and `evidenceRelation` (`primary_source`, `independent_source`, `secondary_source`, `supporting_artifact`); `accessed` is an ISO date when present |
| Mathematics | `facets.mathematics`; either `status: "classified"` with `scheme: "MSC"`, `schemeVersion: "MSC2020"`, exact three-node `primaryPath`, `secondaryPaths`, distinct rationale, source IDs and confidence, or `status: "unclassified"` with reason and confidence |
| R1 | `facets.resultApproach.r1ContributionFamily`; coded assignments contain `status`, `conceptId`, axis-specific `rationale`, one or more `evidenceSourceIds`, and confidence |
| R2 | `facets.resultApproach.r2Outcome`; coded mathematical results contain `status`, `polarity`, `completeness`, axis-specific rationale, one or more source IDs, and confidence; other R1 families use an explicit-state assignment |
| R3 | `facets.resultApproach.r3ArgumentForms`; coded form contains `status`, `primaryConceptId`, `additionalConceptIds`, its own rationale, one or more source IDs, and confidence |
| R4 | `facets.resultApproach.r4SpecialistTechniques`; use a coded controlled set, `provisional_candidates` with candidate definitions and evidence, or an explicit-state assignment |
| Production | `facets.production.p1HumanMachineMode`, `stageTable`, `p2ReasoningRepresentation`, `p3ArchitectureFamily`, and `p4ArchitectureFeatures`; coded P1 additionally requires boolean `sourceClaimed` |
| Verification | `verification.status`, `events`, and row-level boolean `replayedHere`; `none_reported`, `unknown` or `not_applicable` additionally requires a rationale |
| Each event | `eventId` beginning `verification-`, registry `familyId` and `methodId`, `target`, `verifier`, `independence`, `scope`, `outcome`, `statementCorrespondence`, boolean `replayedHere`, `eventDate`, `assumptions`, and one or more source IDs |
| Challenge | `challengeContext.policyVersion: "1.1.0"`, `anchorClaim`, `significance`, four inputs, `framingDate`, `solutionDate`, `provisional`, `superhumanEvidence`, and `derived` |
| Coding | `coding.coder`, ISO `assignmentDate`, confidence, rationale, and `reviewStatus` (`unreviewed`, `second_coder_reviewed`, `adjudicated`, `unknown`, `not_applicable`) |

A coded single assignment has `{status, conceptId, rationale, evidenceSourceIds, confidence}`; a coded set uses `conceptIds`; an explicit-state assignment has `{status, rationale, evidenceSourceIds, confidence}` and no invented concept. Dates use `{status: "coded", value, precision, rationale, evidenceSourceIds}` or an explicit-state form. `derived` contains `score`, `baseCategory`, `category`, computed `elapsedYears`, `superhumanEligible`, and `qualifyingVerificationEventIds`. An incomplete record also contains a derived `completionEnvelope`; run the validator to recompute these fields rather than hand-optimising the outcome.

### Full

Full retains everything in Minimal and may add:

- secondary MSC paths and a stable named-problem identity;
- secondary and external classifications and detailed R4 evidence;
- more granular stage-specific human-machine events, systems, harness, tools and resource class;
- formal trust assumptions and reproducibility detail;
- artifacts, bibliographic metadata, caveats and review history.

The profile records completion state, not confidence. A Full record can still contain honest unknowns.

## 3. Decision guides

### 3.1 Primary Mathematics path

1. Read the canonical claim without the title, venue or system description.
2. Ask which mathematical community would recognise the target as its own problem.
3. Choose the most specific supported MSC2020 path and record all three nodes: M1 (two digits), M2 (three characters) and M3 (five characters).
4. Add other substantive paths as secondary; do not use a secondary path merely because a proof invokes a standard tool from that field.
5. If the evidence does not support a responsible MSC assignment, use `unclassified` and record what evidence is missing.

Named problems are linked entities, not an extra colour branch. Different results about the same problem should point to the same stable problem ID.

### 3.2 R2 outcome

R2 applies to `R1-MATHEMATICAL-RESULT` and has two independent fields:

| Field | Values | Decision |
|---|---|---|
| Polarity | `settled_yes`, `settled_no`, `impossible` | whether the result establishes an affirmative, negative or impossibility direction |
| Completeness | `settled`, `frontier_moved`, `partial` | whether it completely settles the anchor, moves a documented frontier or establishes material partial progress |

Every polarity may pair with every completeness value. An affirmative improved bound is normally `settled_yes`/`frontier_moved`; an affirmative subcase is `settled_yes`/`partial`. Use `settled_yes`/`settled` only when the tracked result package completely answers the anchor, including a matching bound when needed. For formalisation, system/tool, benchmark/evaluation and survey/synthesis R1 records, set the whole R2 assignment to `not_applicable`. Construction and witness information lives in R3 only.

### 3.3 R3 argument form

R3 is multi-valued. Record every broad form that materially supports the result, such as direct proof, induction or recursion, reduction or characterisation, counterexample, explicit construction, exhaustive finite search, or certificate.

The executable record requires one `primaryConceptId` as a short browsing label and preserves every other material form in `additionalConceptIds`. The primary is a display convenience, not an analytical weighting. Give R3 its own rationale; do not copy the claim or the R1/R2 rationale.

### 3.4 R4 specialist technique

Use a stable registry term when one exists. R4 describes a mathematically substantive method, not a topic, model or software product.

For a new term:

1. retain the evidence-grounded label, definition, exclusions, aliases and cited use as a candidate term;
2. locate a second distinct source-backed result use;
3. admit it to browse only after both uses and vocabulary review;
4. map later synonyms to the same identifier rather than creating duplicate colours.

No current R4 code has two controlled uses. Keep the browse axis hidden and preserve candidates in record detail with neutral styling.

### 3.5 P1 human-machine allocation

Complete the Minimal `stageTable` before choosing P1. It has exactly three rows: `generation`, `checking` and `write_up`. Each row records `humanOperations`, `machineOperations`, `reconstructible`, and `evidenceSourceIds`; use an explicit missing state rather than inventing operations. For shared or AI-led, `reconstructible: true` is not sufficient by itself: the generation row must cite evidence and contain concrete machine operations, and shared must also contain concrete human operations.

P1 has only three active modes:

1. Use **AI-led** only when the reconstructible generation row shows that the machine supplied the decisive search, strategy, proof or construction and humans did not materially supply that step.
2. Use **shared** only when the reconstructible generation row shows interdependent substantive human and machine contributions at the decisive stage.
3. Use **human-led** when humans own the principal strategy or proof and AI supplies bounded assistance. This is the conservative coded default when the evidence does not reconstruct a decisive machine-led or shared stage.
4. Use explicit `unknown` or `not_reported` when the evidence does not even support human-led allocation.

Set `sourceClaimed: true` when the coded P1 allocation preserves a matching source attribution rather than an independently reconstructed allocation; it is a qualifier, not a fourth mode. A source claim alone does not establish AI-led: the coded mode still defaults to human-led unless the decisive generation stage is reconstructible. If that conservative code differs from a source's attribution, keep `sourceClaimed: false` and preserve the source claim in migration notes. A claim about checking or write-up does not determine generation.

### 3.6 Statement correspondence

For a formal or computational artifact, record its relationship to the public claim:

- `equivalent`: the checked statement represents the complete anchor claim;
- `stronger`: it entails the anchor claim under the recorded definitions;
- `weaker`: it checks only a weaker statement;
- `partial`: it checks a named component, direction, bound or subcase;
- `translation_uncertain`: correspondence has not been established;
- `not_applicable`: no separate formal/computational statement exists.

State the missing direction or condition explicitly. Every kernel and certificate event must assess correspondence; `not_applicable` is invalid for those methods, while `unknown` remains visible and blocks “formally verified”. A kernel check of an upper bound does not formally verify an exact equality whose lower bound is only cited from the literature.

### 3.7 Verification events and assurance summaries

Each event records family, method, date when known, actor, independence, scope, statement correspondence, outcome, evidence and `replayedHere`. The verification object also records row-level `replayedHere`, which is true exactly when at least one event was executed during this coding pass. A source-reported run is not a replay here. Preserve contradictory, failed and limited-scope events.

The collapsed explorer may derive a conservative summary, for example “Lean checked - upper bound only”. The summary must be reproducible from listed event IDs, include a material scope limitation, and never replace the event list. “Formally verified” requires a contributing passed kernel event with `scope: complete_claim` and correspondence `equivalent` or `stronger`.

## 4. Challenge context and Superhuman

The versioned policy computes `D = P + A + S + R` only when all four inputs are numeric:

- **P, prior target (0/1)**: the exact target or frontier is documented before the AI work;
- **A, advance (0-2)**: from narrow extension through material advance to complete settlement;
- **S, scope (0/1)**: uniform or genuinely general scope;
- **R, demonstrated resistance (0/1)**: documented prior attempts or a qualifying predeclared comparison.

Each component requires `evidenceState`: `observed` or `inferred` for a numeric value, otherwise the same explicit state in both `value` and `evidenceState` (`unknown`, `not_reported` or `not_applicable`). Never convert a failed evidence search into 0. If any input is nonnumeric, `baseCategory` and `category` are `incomplete`; no Expected, Difficult or Superhuman category is derived.

Expected covers complete scores 0–2 and Difficult covers complete scores 3–5. Under policy 1.1.0, **Superhuman** has one mathematical-history gate plus a minimal passed-event evidence floor:

1. all P/A/S/R inputs are numeric;
2. `priorTarget=1`;
3. `advance=2`;
4. `resistance=1`;
5. R2 completeness is `settled`;
6. the claim is explicitly non-provisional;
7. at least 10.0 computed elapsed years separate documented precise framing and solution; and
8. `verification.status` is `events_recorded` with at least one event whose `outcome` is `passed`.

The passed event is an evidence floor, not a claim of strong or independent verification. Statement correspondence, the separate prior-attempt count, verification method, independence, scope and replay, and second-coder review remain evidence-backed assurance fields displayed beside the category. Their strength does not otherwise change Superhuman eligibility. The `superhumanEvidence` field name is retained for record compatibility, but its correspondence and attempt-count children are assurance detail rather than additional category gates; `R=1` already supplies the policy's documented-resistance judgment.

Duration remains the computed `elapsedYears` value; it is not a capability claim. Record significance separately as evidence-backed `exercise`, `minor` or `publishable`, or an explicit missing state.

Always publish the component vector, missingness, evidence and policy version with the category. Verification, autonomy, prestige, proof length, compute and mathematical importance do not add points.

### 4.1 Completion envelope for incomplete records

The authoritative category remains `incomplete` whenever any P/A/S/R input is nonnumeric. Do not replace it with a guessed Expected, Difficult or Superhuman label. Policy 1.1.0 instead derives a versioned `completionEnvelope` that asks a narrower counterfactual question: which final categories could result if every `unknown` or `not_reported` component were later resolved to any value in its declared numeric domain?

Enumerate the complete Cartesian product of those domains while holding every recorded nonmissing input, R2 assignment, date, provisional value and verification event fixed. Record the missing input names, numeric score range, possible base categories and possible final categories. Use `resolution: completion_invariant` and populate `completionInvariantCategory` only when every enumerated completion has the same final category. Otherwise use `resolution: ambiguous` and set `completionInvariantCategory` to null. If any input is `not_applicable`, use `resolution: structurally_incomplete`, a null score range, empty category sets and a null invariant category.

This envelope is neither imputation nor a probability or confidence estimate. “Completion-invariant Difficult” means only that every policy-allowed numeric completion would be Difficult; the published record remains incomplete until the missing evidence is coded. In the current snapshot, 103 incomplete rows are invariant Difficult, while 76 can be Expected or Difficult, 22 can be Difficult or Superhuman, and two can reach any of the three categories. No current incomplete row is invariant Expected or invariant Superhuman.

## 5. Worked coding examples

### A. Cycle Double Cover Conjecture (record 2)

- **Mathematics:** Combinatorics > Graph theory > Paths and cycles.
- **Result:** `settled_yes`/`settled`, using reduction and construction; both R3 forms are retained.
- **Production:** the source-layer attribution is AI-led, but the published P1 code is conservatively human-led because the decisive generation stage is not reconstructible; the attribution remains in migration notes.
- **Verification:** a public Lean kernel check and independent specialist reconstructions are separate events.
- **Lesson:** the paper's AI system does not determine the mathematical classification.

### B. CRN-computability of zeta(3) (record 41)

- **Mathematics:** Theory of computing > biologically inspired computation, with systems biology secondary.
- **Result:** constructive computability theorem.
- **Production:** the source-layer attribution is shared human-AI work, but the published P1 code is conservatively human-led because the decisive generation stage is not reconstructible.
- **Verification:** Lean checks the end-to-end theorem; author review is a separate, non-independent event.
- **Lesson:** project-level model lists must not be converted into result-specific attribution.

### C. Jacobian counterexample in dimension at least three (record 44)

- **Mathematics:** Algebraic geometry > affine geometry > Jacobian problem.
- **Result:** negative resolution through an explicit counterexample.
- **Production:** AI-led is source-reported, but the published P1 code is conservatively human-led with that attribution retained in migration notes; the prompt, harness and decisive-stage allocation remain `not_reported`.
- **Verification:** exact symbolic checks, an Isabelle formalisation and a separate Lean formalisation remain three events.
- **Lesson:** independent later formalisation strengthens assurance without changing discovery provenance.

### D. Book Ramsey number R(B8,B10) (record 40)

- **Mathematics:** Combinatorics > graph theory > generalized Ramsey theory.
- **Result:** exact value obtained by matching a new upper bound with a known lower bound.
- **Production:** the source reports AI-led discovery followed by human editing and separate formalisation; the published P1 code remains human-led because the decisive generation stage is not reconstructible.
- **Verification:** Lean covers the new upper bound only; the lower bound is literature-supported.
- **Lesson:** the collapsed assurance summary must expose partial statement correspondence.

### E. Infinite unit-distance counterexample family (record 1)

- **Result:** a negative resolution via a constructed counterexample family.
- **Production:** the source reports a one-shot AI-led attribution, but the published P1 code is human-led with `sourceClaimed: false`; the conflicting attribution is retained in migration notes until the decisive stage can be reconstructed.
- **Verification:** internal AI grading, specialist review and a later human-digested proof have different independence and scope.
- **Lesson:** autonomy claims need their own evidence and confidence; a generator's own grade is not independent verification.

### F. No-universal-exponent result (record 26)

- **Result:** negative answer through a counterexample family.
- **Production:** the source reports AI-led formal search, but the published P1 code is conservatively human-led because the decisive generation stage is not reconstructible.
- **Verification:** Lean checks the released target, while human statement review identifies the relationship to the motivating problem.
- **Lesson:** a formally checked theorem can be correct while correspondence to a broader informal formulation remains qualified.

## 6. Quality-control checklist

Before publication, verify that:

- the claim, result ID and source roles are present;
- every controlled label resolves to a stable registry ID;
- a primary MSC describes the claim rather than the venue;
- R2 codes polarity and completeness independently, with construction only in R3;
- P1 follows the stage table and autonomy evidence;
- every material verification event has scope and independence;
- formal/computational events include statement correspondence;
- row and event `replayedHere` values state what this coding pass actually executed;
- challenge inputs recompute deterministically under the recorded policy version;
- every incomplete record retains `category: incomplete` and has an exactly recomputed completion envelope rather than a projected or imputed category;
- Superhuman eligibility has positive evidence for every mathematical-history gate and the minimal passed-event floor;
- unknowns have not been replaced by assumptions;
- profile, confidence, coder and revision date are visible.

## 7. Reliability pilot protocol

Select 20-30 results stratified across mathematical branches, R2 polarity and completeness, informal and formal workflows, P1 modes, verification families and challenge categories. Two coders work independently from identical complete source excerpts and one schema version. Report field-level agreement, coding time, missingness and every adjudication; do not hide disagreement in one aggregate statistic.

Where disagreement reflects genuine ambiguity, improve the representation rather than forcing consensus. Definitions are frozen for v0.2 only after the pilot record shows that a new coder can produce a valid Minimal record without private guidance.

### 7.1 Pre-release diagnostic status

The existing two-pass AI-assisted comparison is retained only as an internal decision-rule stress test. It is not publishable reliability evidence and its figures must not appear as reliability results. The release status remains `pending_human_intercoder_pilot`.

The two-human pilot must concentrate on P1 allocation and source-claimed status, the R2 settlement/frontier/partial boundaries, material R3 forms, resistance, and statement correspondence. Its R2 boundary set is IDs 35, 97, 113 and 263 (improved-bound/A=2), plus 42, 55, 65, 173, 189, 208, 219, 243 and 259 (affirmative/A=1). It must also review the 38 records whose primary MSC begins `68` for venue leakage. Freeze v0.2 only after 20–30 records have been independently coded from identical complete source excerpts, disagreements adjudicated, and resulting rules incorporated.

## 8. Canonical values appendix

Use only the active IDs below for new records. Deprecated IDs are migration inputs, not authoring values.

### 8.1 Result and approach

| Axis | Active IDs or values |
|---|---|
| R1 contribution family | `R1-MATHEMATICAL-RESULT`, `R1-FORMALISATION`, `R1-SYSTEM-OR-TOOL`, `R1-BENCHMARK-OR-EVALUATION`, `R1-SURVEY-OR-SYNTHESIS` |
| R2 polarity | `settled_yes`, `settled_no`, `impossible` |
| R2 completeness | `settled`, `frontier_moved`, `partial` |
| R3 argument form | `R3-DIRECT-PROOF`, `R3-PROOF-BY-CONTRADICTION`, `R3-COUNTEREXAMPLE`, `R3-CONSTRUCTED-EXISTENCE`, `R3-NONCONSTRUCTIVE-EXISTENCE`, `R3-REDUCTION-OR-CHARACTERISATION`, `R3-INDUCTION-OR-RECURSION`, `R3-PROBABILISTIC-EXISTENCE`, `R3-EXHAUSTIVE-FINITE-SEARCH`, `R3-CERTIFICATE-BACKED-COMPUTATION`, `R3-FORMAL-PROOF-SYNTHESIS`, `R3-EXPERIMENTAL-EVIDENCE-ONLY` |

R4 is hidden from browse until a code has two distinct source-backed result uses. The current record-detail IDs are `R4-DISCHARGING`, `R4-FLAG-ALGEBRAS`, `R4-PRESCRIBED-COMPLETION`, `R4-GENERIC-FORMAL-FIBRE-CONTROL`, `R4-POLYNOMIAL-METHOD`, `R4-SAT-ENCODING`, `R4-LINEAR-PROGRAMMING-DUAL-CERTIFICATE` and `R4-TRANSFINITE-RECURSION`. If evidence does not resolve to one of these definitions, use `provisional_candidates` or an explicit state; do not mint an ID in a result record.

### 8.2 Production

| Axis | Active IDs |
|---|---|
| P1 | `P1-HUMAN-LED-AI-ASSISTED`, `P1-SHARED-HUMAN-AI`, `P1-AI-LED` |
| P2 | `P2-INFORMAL-NATURAL-LANGUAGE`, `P2-EXECUTABLE-COMPUTATION-OR-PROGRAM-SEARCH`, `P2-FORMAL-THEOREM-PROVING`, `P2-HYBRID-INFORMAL-TO-FORMAL`, `P2-HYBRID-COMPUTATION-TO-FORMAL-CERTIFICATE`, `P2-MIXED-OR-NOT-REPORTED` |
| P3 | `P3-DIRECT-MODEL-INTERACTION`, `P3-ITERATIVE-SINGLE-AGENT`, `P3-MULTI-AGENT`, `P3-PROGRAM-OR-EVOLUTIONARY-SEARCH`, `P3-NEURAL-SYMBOLIC`, `P3-COMPOUND-PIPELINE` |
| P4 | `P4-RETRIEVAL-AUGMENTED`, `P4-GENERATOR-CRITIC`, `P4-GENERATOR-VERIFIER`, `P4-PLANNING-AND-TASK-DECOMPOSITION`, `P4-PERSISTENT-MEMORY`, `P4-PARALLEL-CANDIDATE-SEARCH`, `P4-HUMAN-IN-THE-LOOP` |

### 8.3 Verification families and methods

The `familyId` must match the method's family exactly.

| Family | Valid methods |
|---|---|
| `VF-INTERNAL` | `VM-INTERNAL-MODEL-SELF-CHECK`, `VM-INTERNAL-DIFFERENT-MODEL-CHECK` |
| `VF-HUMAN` | `VM-HUMAN-EXPERT-MATHEMATICAL-REVIEW` |
| `VF-COMPUTATIONAL` | `VM-COMPUTATIONAL-DETERMINISTIC-TESTS`, `VM-COMPUTATIONAL-NUMERICAL-OR-CAS-CHECK`, `VM-COMPUTATIONAL-EXHAUSTIVE-FINITE-SEARCH` |
| `VF-CERTIFICATE` | `VM-CERTIFICATE-SEPARATELY-CHECKED` |
| `VF-FORMAL` | `VM-FORMAL-PROOF-ASSISTANT-KERNEL-CHECK`, `VM-FORMAL-STATEMENT-CORRESPONDENCE-REVIEW` |
| `VF-EXTERNAL` | `VM-EXTERNAL-INDEPENDENT-REPLAY`, `VM-EXTERNAL-INDEPENDENT-REPLICATION` |
| `VF-PUBLICATION` | `VM-PUBLICATION-PEER-REVIEW-OR-PUBLICATION` |

The complete event enums are:

- verification status: `events_recorded`, `none_reported`, `unknown`, `not_applicable`;
- independence: `same_system`, `different_system_same_team`, `human_author_team`, `independent_party`, `unknown`, `not_reported`, `not_applicable`;
- scope: `complete_claim`, `formal_statement`, `partial_claim`, `specified_components`, `tested_cases`, `artifact_only`, `unknown`, `not_reported`, `not_applicable`;
- outcome: `passed`, `failed`, `mixed`, `inconclusive`, `unknown`, `not_reported`, `not_applicable`;
- statement relation: `equivalent`, `stronger`, `weaker`, `partial`, `translation_uncertain`, `not_applicable`, `unknown`, `not_reported`;
- event date: an ISO `YYYY-MM-DD` date or `unknown`, `not_reported`, `not_applicable`;
- optional assurance label: `reported_only`, `expert_checked`, `mechanically_checked`, `formally_verified`, `independently_reproduced`, `inconclusive`.

An assurance summary is allowed only when `status` is `events_recorded`. Its `eventIds` must resolve to listed events. The `formally_verified` label additionally requires a contributing passed proof-assistant kernel event whose scope is `complete_claim` and whose statement relation is `equivalent` or `stronger`.

## 9. Validator-passing Minimal example

This deliberately ordinary example uses honest missing states. It is complete as a Minimal record and passes both the JSON schema and the cross-field validator. Replace every example value and rationale with source-specific evidence; do not treat a syntactically valid placeholder as a completed coding decision.

<!-- BEGIN VALIDATED MINIMAL JSON -->
```json
{
  "schemaVersion": "0.2.0",
  "profile": "minimal",
  "taxonomyVersion": "0.2.0",
  "recordRevision": 1,
  "recordType": "result",
  "resultId": "result-manual-example",
  "sourceIncludedId": "manual-example",
  "claim": "Every graph in the stated class contains a cycle with the documented property.",
  "sources": [
    {
      "sourceId": "source-primary",
      "sourceType": "paper",
      "role": "Primary statement, proof and production account",
      "title": "Example graph theorem",
      "url": "https://example.org/example-graph-theorem",
      "accessed": "2026-08-22",
      "evidenceRelation": "primary_source"
    }
  ],
  "facets": {
    "mathematics": {
      "status": "classified",
      "scheme": "MSC",
      "schemeVersion": "MSC2020",
      "primaryPath": [
        {"code": "05", "label": "Combinatorics"},
        {"code": "05C", "label": "Graph theory"},
        {"code": "05C38", "label": "Paths and cycles"}
      ],
      "secondaryPaths": [],
      "rationale": "The claim is a theorem about cycles in a class of graphs.",
      "evidenceSourceIds": ["source-primary"],
      "confidence": "high"
    },
    "resultApproach": {
      "r1ContributionFamily": {
        "status": "coded",
        "conceptId": "R1-MATHEMATICAL-RESULT",
        "rationale": "The primary contribution is a new mathematical theorem.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "high"
      },
      "r2Outcome": {
        "status": "coded",
        "polarity": "settled_yes",
        "completeness": "partial",
        "rationale": "The theorem proves an affirmative subcase but does not settle the broader anchor.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "medium_high"
      },
      "r3ArgumentForms": {
        "status": "coded",
        "primaryConceptId": "R3-DIRECT-PROOF",
        "additionalConceptIds": [],
        "rationale": "The proof derives the required cycle directly from the stated graph conditions.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "high"
      },
      "r4SpecialistTechniques": {
        "status": "not_reported",
        "rationale": "The source does not identify a controlled specialist technique.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "medium"
      }
    },
    "production": {
      "p1HumanMachineMode": {
        "status": "coded",
        "conceptId": "P1-HUMAN-LED-AI-ASSISTED",
        "sourceClaimed": false,
        "rationale": "The reconstructible account assigns the proof strategy to the human author and only bounded checking to AI.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "medium_high"
      },
      "stageTable": [
        {
          "stage": "generation",
          "humanOperations": ["Selected the target and supplied the proof strategy"],
          "machineOperations": "not_applicable",
          "reconstructible": true,
          "evidenceSourceIds": ["source-primary"]
        },
        {
          "stage": "checking",
          "humanOperations": ["Checked every proof step"],
          "machineOperations": ["Tested small examples"],
          "reconstructible": true,
          "evidenceSourceIds": ["source-primary"]
        },
        {
          "stage": "write_up",
          "humanOperations": ["Prepared the final exposition"],
          "machineOperations": "not_reported",
          "reconstructible": true,
          "evidenceSourceIds": ["source-primary"]
        }
      ],
      "p2ReasoningRepresentation": {
        "status": "coded",
        "conceptId": "P2-INFORMAL-NATURAL-LANGUAGE",
        "rationale": "The substantive proof is presented in ordinary mathematical prose.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "high"
      },
      "p3ArchitectureFamily": {
        "status": "coded",
        "conceptId": "P3-DIRECT-MODEL-INTERACTION",
        "rationale": "The reported AI use consists of bounded direct interactions without an iterative controller.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "medium"
      },
      "p4ArchitectureFeatures": {
        "status": "not_reported",
        "rationale": "No architecture feature is reported for the bounded interaction.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "medium"
      }
    }
  },
  "verification": {
    "status": "none_reported",
    "events": [],
    "replayedHere": false,
    "rationale": "The coding pass found no reported verification event and executed no artifact."
  },
  "challengeContext": {
    "policyVersion": "1.1.0",
    "anchorClaim": "The broader graph statement to which this subcase contributes.",
    "significance": {
      "status": "not_reported",
      "rationale": "The source does not support a significance assignment.",
      "evidenceSourceIds": [],
      "confidence": "not_reported"
    },
    "inputs": {
      "priorTarget": {
        "value": "not_reported",
        "evidenceState": "not_reported",
        "rationale": "A precise predating target was not documented in the reviewed source.",
        "evidenceSourceIds": [],
        "confidence": "not_reported"
      },
      "advance": {
        "value": 1,
        "evidenceState": "observed",
        "rationale": "The theorem establishes a documented affirmative subcase.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "medium_high"
      },
      "scope": {
        "value": 0,
        "evidenceState": "observed",
        "rationale": "The result is restricted to the stated graph subclass.",
        "evidenceSourceIds": ["source-primary"],
        "confidence": "high"
      },
      "resistance": {
        "value": "not_reported",
        "evidenceState": "not_reported",
        "rationale": "No qualifying prior attempts or comparison are documented.",
        "evidenceSourceIds": [],
        "confidence": "not_reported"
      }
    },
    "framingDate": {
      "status": "not_reported",
      "rationale": "No precise framing date is documented.",
      "evidenceSourceIds": []
    },
    "solutionDate": {
      "status": "coded",
      "value": "2026",
      "precision": "year",
      "rationale": "The source dates the result to 2026.",
      "evidenceSourceIds": ["source-primary"]
    },
    "provisional": "not_reported",
    "superhumanEvidence": {
      "exactTargetCorrespondence": {
        "value": "not_reported",
        "rationale": "The reviewed source does not report a correspondence assessment against a precise predating anchor.",
        "evidenceSourceIds": []
      },
      "substantivePriorAttempts": {
        "value": "not_reported",
        "rationale": "The reviewed source does not document qualifying prior attempts.",
        "evidenceSourceIds": []
      }
    },
    "derived": {
      "score": "not_reported",
      "baseCategory": "incomplete",
      "category": "incomplete",
      "elapsedYears": "not_reported",
      "superhumanEligible": false,
      "qualifyingVerificationEventIds": [],
      "completionEnvelope": {
        "policyVersion": "1.1.0",
        "ruleVersion": "1.0.0",
        "missingInputs": ["priorTarget", "resistance"],
        "scoreRange": {"minimum": 1, "maximum": 3},
        "possibleBaseCategories": ["Expected", "Difficult"],
        "possibleFinalCategories": ["Expected", "Difficult"],
        "resolution": "ambiguous",
        "completionInvariantCategory": null
      }
    }
  },
  "coding": {
    "coder": "example-coder",
    "assignmentDate": "2026-08-22",
    "confidence": "medium",
    "rationale": "The record separates supported assignments from explicit missing evidence.",
    "reviewStatus": "unreviewed"
  }
}
```
<!-- END VALIDATED MINIMAL JSON -->
