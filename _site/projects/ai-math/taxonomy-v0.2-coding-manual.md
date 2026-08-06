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

## 2. Minimal and Full profiles

### Minimal

A publishable Minimal record contains:

- stable result ID, canonical claim, record revision and taxonomy version;
- at least one source with its role;
- one primary Mathematics path, or an explicit `unclassified` reason;
- R1 contribution family and R2 outcome;
- P1 human-machine allocation, or explicit `not_reported`;
- every material verification event found during the coding pass, or `none_reported`;
- the four challenge inputs, their rationales and sources, including explicit missingness;
- coding rationale, confidence, coder identifier and assignment date.

Minimal does not mean low quality. It means that optional enrichment has not yet been attempted.

### Full

Full retains everything in Minimal and may add:

- secondary MSC paths and a stable named-problem identity;
- multi-valued R3 argument forms and R4 specialist techniques;
- P2 reasoning representation, P3 architecture family and P4 features;
- stage-specific human-machine events, systems, harness, tools and resource class;
- formal statement correspondence, trust assumptions and reproducibility detail;
- artifacts, bibliographic metadata, caveats and review history.

The profile records completion state, not confidence. A Full record can still contain honest unknowns.

## 3. Decision guides

### 3.1 Primary Mathematics path

1. Read the canonical claim without the title, venue or system description.
2. Ask which mathematical community would recognise the target as its own problem.
3. Choose the most specific supported MSC2020 path.
4. Add other substantive paths as secondary; do not use a secondary path merely because a proof invokes a standard tool from that field.
5. If the evidence does not support a responsible MSC assignment, use `unclassified` and record what evidence is missing.

Named problems are linked entities, not an extra colour branch. Different results about the same problem should point to the same stable problem ID.

### 3.2 R2 outcome

- **Affirmative resolution**: establishes the anchor claim as stated.
- **Negative resolution**: disproves the anchor claim as stated.
- **Exact value or classification**: determines the requested optimum, endpoint or complete classification.
- **Partial progress**: settles a substantive subcase or conditional version without moving a previously quantified frontier.
- **Improved bound or construction**: moves a documented quantitative frontier but does not prove optimality.
- **Formalisation**: the new contribution is formal representation or checking of an already established result.

When a paper supplies both a new upper bound and cites an old lower bound, classify the new contribution separately from the cited result. “Exact” is justified only when the package establishes that the two bounds meet and the evidence roles remain visible.

### 3.3 R3 argument form

R3 is multi-valued. Record every broad form that materially supports the result, such as direct proof, induction or recursion, reduction or characterisation, counterexample, explicit construction, exhaustive finite search, or certificate.

A `displayPrimary` R3 value is optional. Use it only when one form gives an honest short description of the argument. Do not force a primary value for genuinely compound arguments.

### 3.4 R4 specialist technique

Use a stable registry term when one exists. R4 describes a mathematically substantive method, not a topic, model or software product.

For a new term:

1. supply a preferred label, definition, exclusions, aliases and at least one cited use;
2. mark it `provisional` after review;
3. promote it to `stable` after a second distinct use and another review;
4. map later synonyms to the same identifier rather than creating duplicate colours.

### 3.5 P1 human-machine allocation

Reconstruct the stages before choosing a summary:

- target selection and specification;
- search or generation;
- selection and rejection;
- correction or steering;
- formal translation;
- validation;
- exposition.

Apply the following precedence rule to the decisive mathematical stage, not to the project as a whole:

1. Use **source-claimed autonomous** only when a source explicitly reports no substantive human intervention during the named decisive stage and the record preserves a supporting quotation or precise source location. This label takes precedence over **AI-led** when those requirements are met.
2. Otherwise use **AI-led** when the machine performed the decisive mathematical generation or search and humans selected, prompted, curated, edited or validated the output without materially supplying that decisive step.
3. Use **shared human-AI** when human steering, correction or mathematical contribution and machine generation are interdependent at the decisive stage.
4. Use **human-led, AI-assisted** when humans own the principal strategy or proof and the system supplies bounded assistance.
5. Use **unclear or not reported** when the source pack cannot distinguish these cases.

An autonomous claim about formal translation, exposition or validation does not make the discovery stage autonomous. Preserve stage-specific operations and evidence even when the summary label is clear. Autonomy confidence is separate from mathematical correctness confidence.

### 3.6 Statement correspondence

For a formal or computational artifact, record its relationship to the public claim:

- `equivalent`: the checked statement represents the complete anchor claim;
- `stronger`: it entails the anchor claim under the recorded definitions;
- `weaker`: it checks only a weaker statement;
- `partial`: it checks a named component, direction, bound or subcase;
- `translation_uncertain`: correspondence has not been established;
- `not_applicable`: no separate formal/computational statement exists.

State the missing direction or condition explicitly. A kernel check of an upper bound does not formally verify an exact equality whose lower bound is only cited from the literature.

### 3.7 Verification events and assurance summaries

Each event records family, method, date when known, actor, independence, scope, statement correspondence, outcome and evidence. Preserve contradictory, failed and limited-scope events.

The collapsed explorer may derive a conservative summary, for example “Lean checked - upper bound only”. The summary must be reproducible from the events, include a material scope limitation, and never replace the event list.

## 4. Challenge context and Superhuman

The versioned policy computes `D = P + A + S + R`:

- **P, prior target (0/1)**: the exact target or frontier is documented before the AI work;
- **A, advance (0-2)**: from narrow extension through material advance to complete settlement;
- **S, scope (0/1)**: uniform or genuinely general scope;
- **R, demonstrated resistance (0/1)**: documented prior attempts or a qualifying predeclared comparison.

Expected and Difficult are derived from the total. **Superhuman** remains an override and requires all published eligibility fields to be satisfied: a precisely matched prior target, complete settlement of that anchor claim, non-provisional status, a derived interval of at least one decade, source evidence for the framing date and solution date, and no unresolved statement-correspondence caveat that would make the settlement claim materially weaker.

Always publish the component vector, missingness, evidence and policy version with the category. Verification, autonomy, prestige, proof length, compute and mathematical importance do not add points.

## 5. Worked coding examples

### A. Cycle Double Cover Conjecture (record 2)

- **Mathematics:** Combinatorics > Graph theory > Paths and cycles.
- **Result:** affirmative resolution using reduction and construction; both R3 forms are retained.
- **Production:** AI-led, hybrid informal-to-formal, compound multi-agent workflow.
- **Verification:** a public Lean kernel check and independent specialist reconstructions are separate events.
- **Lesson:** the paper's AI system does not determine the mathematical classification.

### B. CRN-computability of zeta(3) (record 41)

- **Mathematics:** Theory of computing > biologically inspired computation, with systems biology secondary.
- **Result:** constructive computability theorem.
- **Production:** shared human-AI work with iterative formalisation.
- **Verification:** Lean checks the end-to-end theorem; author review is a separate, non-independent event.
- **Lesson:** project-level model lists must not be converted into result-specific attribution.

### C. Jacobian counterexample in dimension at least three (record 44)

- **Mathematics:** Algebraic geometry > affine geometry > Jacobian problem.
- **Result:** negative resolution through an explicit counterexample.
- **Production:** AI-led is source-reported; prompt and harness remain `not_reported`.
- **Verification:** exact symbolic checks, an Isabelle formalisation and a separate Lean formalisation remain three events.
- **Lesson:** independent later formalisation strengthens assurance without changing discovery provenance.

### D. Book Ramsey number R(B8,B10) (record 40)

- **Mathematics:** Combinatorics > graph theory > generalized Ramsey theory.
- **Result:** exact value obtained by matching a new upper bound with a known lower bound.
- **Production:** AI-led discovery followed by human editing and separate formalisation.
- **Verification:** Lean covers the new upper bound only; the lower bound is literature-supported.
- **Lesson:** the collapsed assurance summary must expose partial statement correspondence.

### E. Infinite unit-distance counterexample family (record 1)

- **Result:** a negative resolution via a constructed counterexample family.
- **Production:** source-claimed one-shot AI proof.
- **Verification:** internal AI grading, specialist review and a later human-digested proof have different independence and scope.
- **Lesson:** autonomy claims need their own evidence and confidence; a generator's own grade is not independent verification.

### F. No-universal-exponent result (record 26)

- **Result:** negative answer through a counterexample family.
- **Production:** AI-led formal search.
- **Verification:** Lean checks the released target, while human statement review identifies the relationship to the motivating problem.
- **Lesson:** a formally checked theorem can be correct while correspondence to a broader informal formulation remains qualified.

## 6. Quality-control checklist

Before publication, verify that:

- the claim, result ID and source roles are present;
- every controlled label resolves to a stable registry ID;
- a primary MSC describes the claim rather than the venue;
- R2 distinguishes settlement, partial progress and a moved bound;
- P1 follows the stage table and autonomy evidence;
- every material verification event has scope and independence;
- formal/computational events include statement correspondence;
- challenge inputs recompute deterministically under the recorded policy version;
- Superhuman eligibility has positive evidence for every gate;
- unknowns have not been replaced by assumptions;
- profile, confidence, coder and revision date are visible.

## 7. Reliability pilot protocol

Select 20-30 results stratified across mathematical branches, R2 outcomes, informal and formal workflows, autonomy modes, verification families and challenge categories. Two coders work independently from the same source pack and schema version. Report field-level agreement, coding time, missingness and every adjudication; do not hide disagreement in one aggregate statistic.

Where disagreement reflects genuine ambiguity, improve the representation rather than forcing consensus. Definitions are frozen for v0.2 only after the pilot record shows that a new coder can produce a valid Minimal record without private guidance.

### 7.1 Pre-release AI-assisted calibration

Two independent AI-assisted passes have been compared on 24 stratified records as a decision-rule stress test. This is **not** a human inter-coder reliability result, and six records overlap the worked examples above, so the exercise is only partially blind. The full comparison is stored in `taxonomy/pilot/calibration-report-v0.2.md`.

The strongest exact agreement was for R1 contribution family (95.8%), challenge scope (91.7%) and broad MSC (87.5%). The clearest revision triggers were P1 human-machine mode (50.0%), R3 exact set agreement (50.0%, mean Jaccard 0.722), challenge resistance (66.7%) and verification-method sets (66.7%, mean Jaccard 0.750). The P1 precedence rule above is the first resulting clarification. The human pilot must concentrate on P1, the boundary between R2 resolution/construction/formalisation labels, what counts as a material R3 form, resistance evidence, and the distinction between verification event, scope and statement correspondence.

The release status remains `pending_human_intercoder_pilot`. No reliability claim should be published from the AI calibration alone.
