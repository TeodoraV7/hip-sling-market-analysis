# Methodology

Companion to [`01_hypotheses.md`](01_hypotheses.md). That document states what is being tested and
against which thresholds; this one states how the data is produced and what may
and may not be concluded from it.

---

## 1. Research design

The survey is a **kill gate**, not a go gate. Stated-preference instruments
reliably identify markets that will not buy; they do not reliably identify
markets that will. A negative result ends the track. A positive result routes
only to the next and cheaper test — a landing page with a pre-order signal —
rather than to production.

---

## 2. Sampling

**Convenience sample. Not random.** Recruitment runs through the researcher's own
networks: LinkedIn, Reddit, Instagram, WhatsApp/Viber, and direct personal
contact, in English, Spanish, and Serbian.

Consequences, all load-bearing for interpretation:

- **No generalisation to the EU population.** Every proportion reported describes
  this sample only.
- **Self-selection.** People who respond to a survey about carrying toddlers are
  more favourably disposed to the category than the population.
- **Social desirability.** Warm contacts systematically under-report negative
  sentiment toward a project they know is the researcher's own.
- **Network homogeneity.** Respondents reached through one person's network share
  demographic characteristics to an unknown degree.
- **Language.** The instrument is English only, so respondents in non-English
  speaking markets are selected on comfort with English (see below).

Sampling is documented as a limitation rather than corrected for, because no
weighting scheme can repair a frame that was never probabilistic.

### Language

The instrument is English only, across all markets.

This is a deliberate constraint rather than an oversight. A single instrument
keeps every response directly comparable, with no translation equivalence to
establish and no second export to reconcile — and it keeps the study within the
scope one researcher can run properly.

It carries a known cost. A five-minute unpaid survey in a second language, from
an unknown researcher, converts less well than one in the respondent's own
language. Spanish response is therefore expected to be depressed by the
instrument itself, not only by reach. Where Spanish participation falls short,
this is a candidate explanation and is reported as such rather than being read as
weak Spanish demand.

An additional selection effect follows: Spanish respondents are, by construction,
those comfortable completing a survey in English. They are unlikely to be
representative of Spanish parents generally, and the Spanish subgroup is
interpreted accordingly.

---

## 3. Collection and stopping rule

Distribution is organised in waves. Each distribution event produces a short
burst of responses followed by rapid decay, so sample size is a function of the
number of distribution events rather than of elapsed time. Leaving the form open
longer does not materially increase n.

Fixed in advance, to prevent open-ended collection justified after the fact:

> Collection closes when the quota is met, **or** when daily accrual falls below
> one response for five consecutive days following the most recent distribution
> event — whichever occurs first.

### Quota

| | Responses |
|---|---|
| Total target | 120 |
| Total minimum | 100 |
| Spain sub-minimum | 30 |

**The Spanish sub-minimum exists because a total quota alone can be met entirely
from one market.** Recruitment runs through a Serbian-weighted network, so
without a separate floor the Spanish subgroup can quietly disappear without that
ever having been decided.

**What the Spanish sub-minimum does and does not support.** At n ≈ 30 the margin
of error on a proportion is roughly ±18pp. Spanish results are therefore reported
as **directional only**, and the Spain–Serbia comparison in [`01_hypotheses.md`](`01_hypotheses.md) §4
is **not evaluable** at this sample size. If the sub-minimum is not met, that is
recorded as an unmet quota, not reported as a finding.

The sub-minimum is set at a level judged reachable rather than at the level
statistical comparison would require. Setting an unreachable quota and then
quietly lowering it would defeat the purpose of fixing one in advance.

---

## 4. Instrument

Full question text, response options, and branching logic are recorded in
[`03_survey_instrument.md`](03_survey_instrument.md), together with defects identified in the live form and
the changes planned for the next wave.

Single instrument, English only, administered via Google Forms. No incentive
offered.

---

## 5. Data pipeline

```
Google Forms  →  BigQuery (staging)  →  Colab (transform, clean)
                                     →  BigQuery (store)
                                     →  Colab (analysis)
                                     →  BigQuery (aggregated)
                                     →  Looker Studio
```

ELT rather than ETL: raw responses land in staging unmodified and all cleaning
happens downstream in version-controlled notebooks. Every transformation is
reproducible and auditable from the raw table, and no cleaning decision is buried
in an unrecorded manual step.

Transformation and analysis are separated into two notebooks for separation of
concerns, not for reasons of data volume.

### Transformation requirements

- Branch paths produce parallel columns for willingness to pay and launch
  notification; these are coalesced into single fields. Paths are mutually
  exclusive and counts must reconcile to n.
- Multi-select fields arrive comma-separated and are split into indicator
  columns.
- Free-text location is normalised into `city` and `country`.
- WTP bands are mapped to numeric midpoints for aggregation, with the band
  retained as the authoritative value.
- Satisfaction items are restricted to respondents reporting current carrier use.
- Superseded columns left behind by form edits are dropped.

---

## 6. Privacy

Email addresses are collected for launch notification only, with that purpose
stated at the point of collection.

- Raw responses are **not** committed to this repository.
- Only aggregated outputs, containing no personal data, are published.
- Email addresses are held separately from analysis tables and are not joined
  into any published output.
- Free-text fields are reviewed for identifying content before any except is
  published.

---

## 7. Precision

Confidence intervals are reported on all proportions. Subgroups are reported
where relevant but are not used as a basis for conclusions once intervals become
uninformative; at the sample sizes this study can reach, that point arrives
quickly.

**Relative comparisons are more robust than absolute levels.** That one attribute
outranks another is considerably better supported here than any specific
percentage of respondents who would buy. Conclusions lean on the former
throughout.

---

## 8. Central limitation

Everything in this study is **stated** preference. Respondents report what they
believe they would do; the literature is consistent that this overstates what
they actually do, typically by a factor of two to three.

The email opt-in is the only behavioural signal in the instrument — it carries a
small real cost to the respondent — and is weighted accordingly in the qualified
intent metric.

This limitation cannot be resolved by a better survey. It is resolved only by
asking people to act, which is the function of the landing page and pre-order
test that follows.
