# Hypotheses & Decision Criteria (Pre-Registration)

> Thresholds below are fixed before any analysis is written. Git history is the
> record of when each was set.
>
> Survey opened: 2026-07-22
> Collection closes: per stopping rule, `02_methodology.md` §3

---

## 1. Context

Market validation for a premium hip sling carrier for children aged 1–4, sold
online across the EU. Primary near-term markets: Spain and Serbia. Category
benchmark: Wildride. Intended differentiator: shoulder ergonomics and materials.

The survey is a **kill gate**, not a go gate. It can credibly say stop; it cannot
on its own say proceed. A positive result routes to the next and cheaper test — a
landing page with a pre-order signal — not to production.

**Competitive risk.** The intended differentiator is not unoccupied: Ergobaby's
Upsie is positioned on a cushioned adjustable shoulder strap. Differentiation
must be established against it, not against Wildride alone.

---

## 2. Hypotheses

| # | Hypothesis | Metric | Threshold | Result |
|---|---|---|---|---|
| H1 | A comfort problem exists for the parent | % of current carrier users rating parent comfort ≤ 3 | > 40% | _pending_ |
| H2 | A comfort problem exists for the child | % of current carrier users rating child comfort ≤ 3 | > 30% | _pending_ |
| H3 | Comfort is a purchase driver, not a nice-to-have | Rank of parent and child comfort among the eleven importance attributes | Both top 5 | _pending_ |
| H4 | The category is used and understood | % who use or recognise a hip sling carrier | > 40% | _pending_ |
| H5 | The concept attracts interest | % willing to try the prototype | > 50% | _pending_ |
| H6 | Interest survives a small cost | % opting in to launch notification | > 30% | _pending_ |
| H7 | Price headroom exists at the premium end | Median stated WTP vs. category entry price (`05_competitive_pricing.md`) | Median ≥ entry price | _pending_ |

**Note on H1 and H2.** The denominator is restricted to respondents reporting
current carrier use. Need is measured as *dissatisfaction*, not as *stated
importance*: importance items tend to sit near the ceiling and discriminate
poorly.

**Note on H4.** Low category awareness does not falsify demand, but it raises CAC:
the funnel must educate before it can sell. A result below threshold reframes the
go-to-market problem rather than killing the product.

**Note on H6.** Leaving an email address carries a small real cost, which makes it
the only behavioural signal in the instrument and the closest available proxy for
revealed preference. H5 without H6 is interest without commitment.

---

## 3. Primary Decision Metric — Qualified Intent Rate (QIR)

Each signal is inflated in isolation. The intersection is the honest number.

QIR = % of all respondents who simultaneously satisfy:

1. Child aged 1–4 (screener)
2. Willing to try, **or** already a hip sling user
3. Stated WTP band ≥ `80-110`
4. Opted in to launch notification

**On the WTP threshold.** The band `50-80` contains the category entry price, so
a respondent selecting it cannot be distinguished between those who would and
would not pay it. The next band up is unambiguous. Conservative by construction,
and anchored to `05_competitive_pricing.md` rather than to the response
distribution.

**Deflator.** Willingness to try is binary, which inflates the affirmative rate
further than a graded scale would. QIR is therefore reported deflated across a
range rather than as a point estimate:

    adjusted = QIR * sample_factor,   sample_factor in {0.3, 0.5, 0.7}

---

## 4. Kill Criteria

Any one of the following ends the current track — no landing page, no pre-order
test, revisit positioning first:

- [ ] QIR < 10%
- [ ] Median WTP (net of VAT) below the **contribution floor** (§5). If the
      product cannot cover production and fulfilment before a single euro of
      acquisition spend, no acquisition test is warranted.
- [ ] Price ranks above **both** parent comfort and child comfort in the
      importance ranking
      → competing on the wrong axis
- [ ] Median WTP band differs by one full band or more between Spain and Serbia.
      Evaluated only if both markets reach quota; otherwise recorded as not
      evaluable.
      → forces a single-market choice; the dual-market plan does not hold

**Post-test criterion**, once the landing page has produced a measured CAC:

- [ ] Median WTP below the **full floor**, including CAC (§5)

This cannot be evaluated before the test and is deliberately excluded from the
pre-test gate.

---

## 5. Unit Economics Floor

WTP is uninterpretable without a floor. Computed bottom-up, independently of
survey results.

**Status: not yet estimable. Deliberately left open.** No component is filled
with a placeholder, because a placeholder would later be adjusted to fit the
result.

**Basis.** The floor is computed **net of VAT**; stated WTP is a **gross**
consumer price. Comparison requires converting WTP to net at the applicable rate
per market. Skipping this overstates headroom by roughly a fifth.

**Batch size is a parameter.** Certification amortises per unit, so the floor is
computed at 200 / 300 / 500 units and reported as a range.

| Component | Source | Status |
|---|---|---|
| COGS (materials + sewing) | quotes, 2–3 manufacturers, per batch tier | pending |
| Certification, amortised over first batch | testing laboratory quote — applicable standard not yet confirmed (EN 13209-2 vs. CEN/TR 16512 for slings) | pending |
| Customs duty + import VAT, if produced outside the EU | tariff classification + rate | pending |
| Shipping + packaging (ES, RS) | carrier rate calculators, actual dimensions | pending |
| Returns reserve | assumption, 10–15% | assumption, flagged |
| Payment processing | published EU gateway rates | pending |
| **Contribution floor, net of VAT (excl. CAC)** | | **pending** |
| CAC | landing-page ad test | not estimable before test |
| **Full floor, net of VAT (incl. CAC)** | | **pending** |

The contribution floor is the only figure available before the landing-page test,
and therefore the only one the pre-test kill gate may use.

**Neither floor is the target price.** Both are break-even points and contain no
margin. `<TARGET_PRICE>` sits above the full floor and is set separately.

**Commitment.** The floors and `<TARGET_PRICE>` will be fixed in a separate,
timestamped commit **before** H7 is evaluated. Setting the target after
inspecting the WTP distribution would make H7 true by construction.

---

## 6. Known Limitations

Full treatment in `02_methodology.md`. Summarised here because they constrain how
the thresholds above may be read:

- **Convenience sample.** Not random. Results describe the sample, not the EU
  population.
- **Self-selection.** Respondents to a carrier survey are pre-disposed
  favourably.
- **Social desirability.** Warm contacts under-report negative sentiment.
- **Stated vs. revealed preference.** The central weakness of survey-based
  validation, and the specific reason a pre-order test follows.

**Relative comparisons** (one attribute outranking another) are substantially
more robust than **absolute levels** (% who would buy). Conclusions lean on the
former.

---

## 7. Triangulation

Cross-checked against revealed-preference sources before any recommendation:

- Wildride reviews (own site, Amazon, Trustpilot) — pain points, observed rather
  than stated
- Ergobaby Upsie reviews — whether a cushioned adjustable shoulder strap is
  reported to solve the problem, or is a marketing claim only
- Google Keyword Planner — search volume ES vs. RS, including the "carry assist"
  category term; feeds the CAC estimate
- Google Trends — category trajectory
- Meta Ads Library — active advertisers, creative angles, campaign longevity

---

## 8. Amendments

Any change after this document is first committed is recorded here with a
rationale, not made silently in place.

| Date | Change | Rationale |
|---|---|---|
| | | |
