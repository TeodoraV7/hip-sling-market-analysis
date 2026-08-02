# Survey Instrument

Complete record of the questionnaire as administered, so that every figure in the
analysis can be traced to the exact wording that produced it.

**Platform:** Google Forms · **Language:** English (single instrument)
**Live from:** 2026-07-22

---

## 1. Introduction shown to respondents

> This questionnaire is for parents with children aged 1–4 years. It takes less
> than 5 minutes to complete. Your answers will help us design a lightweight,
> breathable, and comfortable hip carrier for your child.

No incentive offered. Required questions marked with an asterisk.

---

## 2. Questions

### Section 1 — Basic information

| Q | Question | Type | Options |
|---|---|---|---|
| 1 | In which city and country are you based? | Free text * | — |
| 2 | How old are you? | Single * | <20 / 21-25 / 26-30 / 31-35 / 35-40 / 40-45 / >45 |
| 3 | What is your gender | Single * | Female / Male / Other |
| 4 | How many children do you have? | Single * | 1 / 2 / 3 / >3 |
| 5 | Your child's age | Single * | 1 / 2 / 3 / 4 / 5 |
| 6 | Your child weight (kg) | Single * | 6-10 / 11-15 / 16-20 / Other |

Q5 and Q6 instruct respondents with more than one child to answer for the
youngest child above age 1.

### Section 2 — Family lifestyle

| Q | Question | Type | Options |
|---|---|---|---|
| 7 | In what area does your family live? | Single * | City center / Urban area / Suburban area / Village / Other |
| 8 | How often do you spend time outdoors with your child? | Single * | Every day / A few times a week / A few times a month / Only on vacations / Almost never |
| 9 | What types of activities do you do most often as a family? | Multi, max 3 * | Daily walks / parks · Weekend trips · Travel · Family or social events · Sport activities · Cafés / restaurants · Shopping · Other |
| 10 | What type of transport do you use most frequently? | Multi, max 3 * | Car · Public transport · Motor · Bicycle / Scooter · Walking · Other |
| 11 | How much time do you spend outside with your child on a typical day? | Single * | <1 hour / 1-2 / 2-3 / 3-4 / >4 hours |

### Section 3 — Current carrier

| Q | Question | Type | Options |
|---|---|---|---|
| 12 | Do you currently use a baby carrier? | Single * | Yes / No / Sometimes |
| 13 | What type of baby carrier do you use? | Multi * | Ergonomic carrier - inward facing · Backpack carrier - forward facing · Wrap · Ring sling · Hip sling · Hip seat · Mei tai · Other |
| 14 | If you use a carrier, what is the brand and model? | Free text * | — |
| 15 | How would you rate your satisfaction with your current carrier? | Scale 1–5 * | 1 = not at all satisfied, 5 = very satisfied |
| 16 | How satisfied are you with your current carrier in terms of… | Grid 1–5 * | Panel material · Other materials (zips, straps etc.) · How comfortable it is for you · How comfortable it is for your child · Durability / build quality · Ease of putting on/taking off · Compactness / portability |
| 17 | How often do you use a baby carrier? | Single * | Every day / A few times a week / A few times a month / Only for special events / Never |
| 18 | What matters to you in a carrier? | Grid 1–5 * | Breathability & comfort in warm weather · Ease of use · Comfort for you (back, shoulders) · Comfort for your child (knees, hips) · Compactness / portability · Price · Safety certifications · Warranty · Brand reputation · Design & aesthetics · Material quality |

Q16 supplies the metrics for H1 and H2; Q18 supplies the metric for H3.

### Section 4 — Branch point

| Q | Question | Type | Routing |
|---|---|---|---|
| 19 | Do you currently use hip sling carrier? | Single * | Yes → Q23 · No → Q20 · Sometimes → Q23 |

Q19 supplies the metric for H4.

### Section 5a — Non-users of hip slings

A photograph of the prototype is shown before Q20.

| Q | Question | Type | Options |
|---|---|---|---|
| 20 | Would you be willing to try a hip sling carrier that looks like the one in the picture? | Single * | Yes / No |
| 21 | How much would you be willing to pay for this hip sling carrier? (in euros) | Single * | <50 / 50-80 / 80-110 / 110-140 |
| 22 | Would you be interested in being the first to know when this carrier launches? | Single * | Yes → Q26 · No → end |

### Section 5b — Existing hip sling users

The same photograph is shown before Q23.

| Q | Question | Type | Options |
|---|---|---|---|
| 23 | What would make you switch to a new hip sling carrier like the one on the picture? | Multi, max 5 * | Better price · Better material quality · Better comfort for me · Better comfort for my child · More breathable material · More compact / easier to pack · More attractive design · Brand I can trust · Safety certifications (EU certified) · Warranty · Nothing — I'm happy with my current one · Other |
| 24 | How much would you be willing to pay for this hip sling carrier? (in euros) | Single * | <50 / 50-80 / 80-110 / 110-140 |
| 25 | Would you be interested in being the first to know when this carrier launches? | Single * | Yes → Q26 · No → end |

### Section 6 — Opt-in

| Q | Question | Type |
|---|---|---|
| 26 | Your email address | Free text, optional |

Stated purpose: launch updates only. Supplies the metric for H6.

---

## 3. Branching

```
Q19  Do you currently use hip sling carrier?
 ├─ No         → 5a  (Q20 try → Q21 WTP → Q22 notify)
 ├─ Yes        → 5b  (Q23 switch drivers → Q24 WTP → Q25 notify)
 └─ Sometimes  → 5b
```

Paths are mutually exclusive. Willingness to pay and launch notification are
therefore captured in parallel columns and coalesced in transformation.

---

## 4. Instrument characteristics

Recorded so that each is accounted for in transformation and reflected in how the
results are read. Each entry states the characteristic and how it is handled.

**Q12 does not gate the satisfaction block.** The section header indicates that
non-users will skip ahead, but all respondents are routed through Q13–Q18.
*Handled:* the satisfaction denominator is filtered to respondents reporting
current carrier use. H1 and H2 are defined on the filtered denominator for this
reason.

**Willingness to pay is unanchored.** Q21 and Q24 are asked without price
context, competitor reference, or material specification. Unanchored WTP is known
to skew low. *Handled:* the resulting figures are read as a lower bound rather
than as an estimate.

**One WTP band spans the category entry price.** The band `50-80` contains the
entry price recorded in [`05_competitive_pricing.md`](05_competitive_pricing.md),
so respondents selecting it cannot be separated into those who would and would
not pay it. *Handled:* the qualifying threshold is set at the next band up, which
is unambiguous. Conservative by construction.

**Willingness to try is binary.** Q20 offers Yes/No rather than a graded scale,
which compresses respondents into the affirmative and discriminates less than a
scale would. *Handled:* the qualified intent metric leans on willingness to pay
and on the email opt-in, and the rate is deflated across a range rather than
reported as a point estimate.

**Location is free text.** Q1 returns country in varied spellings, languages, and
capitalisations. *Handled:* normalised into `city` and `country` in
transformation, with the original retained as `location_raw`.

**Parent age bands share boundaries.** Q2 options overlap at 35 and 40, so a
respondent at a boundary may have selected either. *Handled:* affects demographic
description only; no hypothesis depends on it, and it is noted where the
distribution is reported.

**The form was edited during collection.** Google Forms retains columns from
superseded versions, which appear as empty columns in the export. *Handled:*
dropped in transformation. No responses were affected. The form is not edited
further while live.

---

## 5. Handling in transformation

There is no second wave and no revised version of this survey — these
characteristics are addressed downstream, in cleaning and in how results are
reported, rather than by changing the questionnaire.

| Characteristic | Handled by |
|---|---|
| Q12 does not gate the satisfaction block | Filter satisfaction denominator to `carrier_use in ('Yes','Sometimes')` |
| Location is free text | Normalise into `city` and `country`; retain `location_raw` |
| WTP band spans the entry price | Set the qualifying threshold at the next band up |
| WTP is unanchored | Read as a lower bound; state this wherever WTP is reported |
| Willingness to try is binary | Deflate qualified intent across a range; weight the email opt-in |
| Age bands overlap | Note at the boundary when reporting the distribution |
| Superseded columns in the export | Drop; verify no responses are lost |
| Branch paths produce parallel columns | Coalesce into `wtp_band` and `notify_opt_in`; reconcile counts to n |

What cannot be recovered in transformation is stated as a limitation rather than
worked around: an unanchored WTP question cannot be re-anchored after the fact,
and a binary intent item cannot be given gradations it never had. Both are
carried into [`04_findings.md`](04_findings.md) as constraints on what the study
concludes.
