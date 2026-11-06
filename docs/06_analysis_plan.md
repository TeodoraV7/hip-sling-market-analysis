# 06 — Analysis Plan

**Status:** Pre-registered. Committed before the results were opened.
**Date committed:** 2026-09-08
**Survey closes:** 2026-11-15

Related: [`01_hypotheses.md`](01_hypotheses.md) · [`02_methodology.md`](02_methodology.md) · [`04_findings.md`](04_findings.md) · [`05_competitive_pricing.md`](05_competitive_pricing.md)

---

## 1. Purpose

This document fixes the analytical decisions — denominators, thresholds, decision
rules, handling of missing answers — before the response data is inspected. Its
job is to remove the freedom to choose, after the fact, the version of the
analysis that looks best.

Anything not specified here and later performed is exploratory, and is labelled as
such in [`04_findings.md`](04_findings.md).

---

## 2. Who is counted

| Population | Definition | Used for |
|---|---|---|
| All respondents | Every submission; the screener is QIR condition 1, applied in the numerator | QIR |
| Qualified | Has a child aged 1–4 | Most hypotheses |
| Current carrier users | Answered `Yes` or `Sometimes` to carrier use | H1, H2 |

Every reported number states its denominator. Denominators are not switched
between hypotheses without saying so.

Screener failures are excluded from every hypothesis. They stay in the QIR
denominator, where the screener is condition 1, and their effect is visible in the
QIR attrition table (§6).

---

## 3. Waves

| Wave | Composition |
|---|---|
| Wave 1 | Serbia-dominant; partially inspected during collection |
| Wave 2 | Spain-focused |

Threshold decisions are made on the **full sample**, both waves pooled. No single
country decides the outcome: the go / no-go recommendation rests on the pooled
results against the thresholds in §5 and the QIR kill criterion in §6.

Wave 1 was partially inspected before this plan was written. Its responses stay
in the decision sample, and this is disclosed as a limitation in
[`04_findings.md`](04_findings.md).

### If the Spain sub-minimum is not met

The sub-minimum for Spain is set in [`02_methodology.md`](02_methodology.md).
It is a collection rule, not a decision rule. If the achieved Spain sample falls
below it, the sub-minimum itself is **not** revised downward to fit the sample,
and:

- Spanish subgroup results are reported as **underpowered** — directional only.
- The Spain vs. Serbia comparison (§7) is reported as not evaluable.
- The hypotheses in §5 and the QIR kill criterion are unaffected; they are
  evaluated on the full sample.
- The shortfall, and the achieved N, are recorded in the Deviations section of
  [`04_findings.md`](04_findings.md).

---

## 4. How a hypothesis passes

For each hypothesis, the result is a percentage with a 95% confidence interval —
the range the true value plausibly falls in, given the sample size.

> A hypothesis passes only if the **entire interval** sits above its threshold.

At around 100 responses, a single percentage that just clears a threshold is not
meaningfully different from one that just misses it. Requiring the whole interval
to clear is stricter and is honest about how much precision the sample actually
supports.

There are three possible outcomes, not two:

- **Pass** — the interval sits above the threshold
- **Fail** — the interval sits below it
- **Inconclusive** — the interval straddles it

Inconclusive is a real result and is expected for at least some hypotheses. It is
reported as inconclusive, not rounded into a pass.

No p-values are reported. The decision rule is the interval.

---

## 5. Hypotheses

| # | Metric | Denominator | Threshold |
|---|---|---|---|
| H1 | % rating parent comfort ≤ 3 | Current carrier users | > 40% |
| H2 | % rating child comfort ≤ 3 | Current carrier users | > 30% |
| H3 | Rank of parent and child comfort among the 11 importance attributes | Qualified | Both top 5 |
| H4 | % who use or recognise a hip sling carrier | Qualified | > 40% |
| H5 | % willing to try the prototype | Qualified, not current hip sling users | > 50% |
| H6 | % leaving an email address for launch notification | Qualified | > 30% |
| H7 | Median WTP band vs. category entry price | Qualified, WTP answered | Median ≥ entry band |

**H3 is descriptive.** Ranking eleven related attributes does not support a clean
test at this sample size. The mean importance score and the rank order are
reported; if comfort sits close to several competing attributes, the rank is
reported as unstable rather than as a pass.

**H5 excludes current hip sling users.** Q20 is asked only on the non-user branch,
so current users never answered it. They are left out of H5 (§8) rather than
counted as unwilling.

**H6 counts an email address, not a "Yes".** Leaving an address is the only answer
that costs the respondent something (see the note on H6 in
[`01_hypotheses.md`](01_hypotheses.md)), so opt-in means an address was left at Q26.

**H7 uses bands, not numbers.** Willingness to pay was collected in price bands.
Bands are not converted to midpoints — that would invent precision the survey did
not collect. The median band is reported alongside the full distribution; with an
even `n`, the lower of the two middle bands is taken. The
category entry price comes from [`05_competitive_pricing.md`](05_competitive_pricing.md),
at list price.

---

## 6. Primary decision metric — QIR

QIR is defined in [`01_hypotheses.md`](01_hypotheses.md): the share of all
respondents who simultaneously pass the screener, are willing to try (or already
use a hip sling), fall in the qualifying WTP band or above, and leave an email
address for launch notification.

Reported as:

- the percentage, with its 95% interval, against the pre-registered kill threshold.
  The kill fires on the percentage itself (QIR < 10%, as in
  [`01_hypotheses.md`](01_hypotheses.md) §4); the interval is reported beside it
- **deflator sensitivity** at `sample_factor ∈ {0.3, 0.5, 0.7}` — as a range, never
  as one adjusted number
- an **attrition table** showing how many respondents drop out at each of the four
  conditions

The attrition table is required. A low QIR driven by a price ceiling and a low QIR
driven by weak opt-in are different findings with different consequences, and the
single figure hides which one happened.

---

## 7. Spain vs. Serbia

One kill criterion is a sharp split between the two markets. For QIR, WTP band and
opt-in rate, the plan reports each country's percentage, the difference between
them, and the interval around that difference.

These comparisons are **secondary** and do not decide the outcome. The two groups
are unequal in size. A small difference is reported as *not enough
evidence of a split* — not as evidence that the markets are the same.

Where a country sample is too small to support a comparison, the comparison is
reported as unavailable rather than reported with a wide interval and discussed as
if it were informative.

---

## 8. Missing and non-substantive answers

No imputation. Each hypothesis is calculated on the respondents who answered it,
with `n` stated.

| Case | Handling |
|---|---|
| Screener missing or failed | Excluded from every hypothesis; kept in the QIR denominator and shown in the attrition table |
| No answer on a hypothesis variable | Excluded from that hypothesis only |
| `Don't know` on WTP | Excluded from H7; **counted as non-qualifying in QIR** |
| `Don't know` on an attitude question | Kept as its own category; not counted in the numerator |
| Partial submission | Kept if the screener and the relevant question are both answered |
| Duplicate submission | Flagged by timestamp and response fingerprint; earliest kept |

The `Don't know` rule for WTP is deliberately asymmetric. It must not be possible
to raise QIR by quietly dropping the undecided from the denominator.

If more than 15% of respondents skipped a hypothesis variable, that hypothesis is
reported with an explicit caveat.

---

## 9. Exploratory analysis

Planned, but explicitly exploratory — these generate ideas for the next test and do
not pass or fail anything:

- Relationships between the importance attributes
- Whether dissatisfaction with a current carrier tracks with willingness to pay
- Differences by child age within the 1–4 band
- Any subgroup cut not listed in §5 or §7

All appear in a separate, labelled section of [`04_findings.md`](04_findings.md),
reported without causal language.

---

## 10. Open-text coding

Free-text answers are grouped into themes with LLM assistance.

1. A random sample of 30 responses is hand-labelled **first**, before any model runs.
2. The model codes the full set, without access to those labels.
3. Agreement between the two is measured on the overlap.
4. If agreement is poor, the coding instructions are revised and the process
   repeated. The revision is logged.
5. Final themes are reported with counts, and with the agreement level stated.

Responses that cannot be coded are reported as a count, not dropped silently. No
personal data reaches the model — `email_address` is excluded at the SQL layer,
where only the boolean `provided_email` is derived from it, as described in
[`00_data_architecture.md`](00_data_architecture.md).

---

## 11. Outputs

| Layer | Contents |
|---|---|
| Python (Colab) | All calculation — percentages, intervals, tables |
| `marts.*` (BigQuery) | Stable aggregated views, one per reporting surface |
| Looker Studio | Reads `marts.*` only; no calculation in the dashboard |

The dashboard is built **after** the analysis, from the metric list the analysis
produces. Nothing is built against `intermediate.*`.

---

## 12. Deviations

Any departure from this plan is recorded in a **Deviations** section of
[`04_findings.md`](04_findings.md), with the reason and the date.

Sample shortfalls against the quota and recoding forced by unanticipated response
patterns are both expected and legitimate. They are only a problem when they are
not disclosed.
