# Findings

**Status: not yet written.**
**Survey closes:** 2026-11-15

Findings are written after collection closes under the stopping rule in
[`02_methodology.md`](02_methodology.md) and the hypotheses in [`01_hypotheses.md`](01_hypotheses.md) have been
evaluated against their pre-registered thresholds.

---

## Planned structure

1. **Executive summary** — the recommendation and the reasoning behind it.
   Written last.
2. **Sample description** — composition, demographics, category participation,
   and what the sample is not.
3. **Hypothesis results** — the [`01_hypotheses.md`](01_hypotheses.md) table with the Result
   column filled, with confidence intervals.
4. **Qualified Intent Rate** — as defined in [`01_hypotheses.md`](01_hypotheses.md), reported
   across the deflator range rather than as a point estimate.
5. **Market comparison** — Spain against Serbia on willingness to pay, category
   participation, and attribute importance.
6. **Triangulation** — survey findings set against the revealed-preference
   sources in [`01_hypotheses.md`](01_hypotheses.md). Where the two disagree, revealed preference
   takes precedence and the disagreement is reported rather than reconciled away.
7. **Recommendation** — against the kill criteria in [`01_hypotheses.md`](01_hypotheses.md). One
   of: proceed to landing-page test, revisit positioning, or stop.
8. **What this study cannot answer** — the stated-preference limit, and what the
   pre-order test is designed to resolve.

---

## Deviations

Departures from [`06_analysis_plan.md`](06_analysis_plan.md), recorded as
required by its section 12.

| Date | Departure | Reason |
|---|---|---|
| 2026-11-25 | Added `marts.survey_respondent_profile`, a respondent-level view with no direct identifiers, for the sample-description dashboard. Looker computes counts and averages from it. Section 11 planned aggregated marts only and no calculation in the dashboard. | Describing the sample (demographics, habits, needs) needs flexible slicing in the dashboard. Hypothesis results and the QIR still come from the notebook marts. |
| 2026-11-26 | Added `marts.target_customers` (opt-in rate and share with WTP of €50 or more, by respondent segment) and `marts.importance_satisfaction` (mean importance and satisfaction of carrier users). Both are aggregated in BigQuery SQL, not in the notebook, and replace Looker Custom SQL. The segment cuts are exploratory (section 9); rates carry no confidence interval. Segments near the centre of the scatter plot are flagged (`is_near_centre`), not excluded: they stay in the mart and the analysis and are hidden only on the scatter plot, for a cleaner visual. | The target-customer and importance-satisfaction dashboard pages need descriptive cuts that the notebook marts do not provide. Versioned views in `sql/marts/` keep Looker reading `marts.*` only. Hypothesis results and the QIR still come from the notebook marts. |

---

## Reporting commitments

- Every proportion carries a confidence interval.
- Hypotheses that fail are reported with the same prominence as those that pass.
- No threshold is revised after the data is inspected. Any unavoidable change is
  recorded in [`01_hypotheses.md`](01_hypotheses.md) with its rationale, and the original
  threshold remains visible.
- Where the sample is too small to support a comparison, that is stated instead
  of the comparison.
