# Data Architecture

Shared infrastructure and conventions for every phase of the project. Where the
phase documents state what is being measured and why, this one states where the
data lives, how it moves, and what rules apply to it regardless of source.

**Status.** Phase 1 is live. Later phases are recorded as planned; the
architecture is fixed in advance so that each source can be added without
redesigning the pipeline around it.

---

## 1. Stack

| Layer | Tool | Rationale |
|---|---|---|
| Collection | Google Forms, GA4 | Native BigQuery paths; no custom ingestion to maintain |
| Storage | BigQuery | Single warehouse for every source, so phases can be joined |
| Transformation | Google Colab (Python) | Notebooks are version-controlled and reviewable |
| Visualisation | Looker Studio | Connects natively to BigQuery |
| Version control | GitHub | Public repository; the analysis is itself a deliverable |

Every component runs within its free tier. This is a constraint on the design,
not an afterthought: no scheduled orchestration, no managed transformation
service, no paid connectors.

---

## 2. Sources

| Source | Ingestion | Phase | Status |
|---|---|---|---|
| Survey (Google Forms) | Forms → BigQuery | 1 | live |
| Website analytics (GA4) | Native BigQuery export | 2 | planned |
| A/B test | GA4 events | 3 | planned |
| Email campaign (Brevo) | Export or API | 4 | planned |

Sources are added to the same warehouse rather than analysed in isolation, so
that later phases can be linked to earlier ones — survey respondents who opted in
against subsequent email engagement, for example.

---

## 3. Pattern

```
source  →  staging  →  clean  →  aggregated  →  Looker Studio
              ▲          ▲           ▲
            raw,      Colab       Colab
          unmodified  transform   analysis
```

**ELT, not ETL.** Raw records land in staging unmodified. All cleaning happens
downstream in version-controlled notebooks.

The consequence that matters: every transformation is reproducible and auditable
from the raw table. No cleaning decision is buried in a manual step that cannot
be traced later, and a change in cleaning logic is a re-run rather than a
re-collection.

**Layers**

| Layer | Contents | Written by |
|---|---|---|
| `staging` | Raw records as received. Never edited in place. | Ingestion |
| `clean` | Typed, renamed, deduplicated, normalised. One row per record. | Transform notebook |
| `aggregated` | Metric tables shaped for reporting. No personal data. | Analysis notebook |

Looker Studio connects to `aggregated` only. Dashboards do not query raw or clean
tables, so a dashboard cannot expose a field that was never meant to be
published.

---

## 4. Notebooks

Two notebooks per source, separated by concern rather than by data volume:

| Notebook | Reads | Writes | Responsibility |
|---|---|---|---|
| `NN_transform.ipynb` | `staging` | `clean` | Typing, renaming, deduplication, normalisation |
| `NN_analysis.ipynb` | `clean` | `aggregated` | Metrics, aggregation, hypothesis evaluation |

The separation means cleaning logic can be re-run without re-running analysis,
and analysis can be revised without touching cleaning. It also keeps the
diff on any change readable.

Notebooks live in `notebooks/` and are committed. Outputs are cleared before
committing where they would otherwise embed row-level data in the repository.

---

## 5. Conventions

**Datasets** are named by layer: `staging`, `clean`, `aggregated`.

**Tables** are named `{source}_{grain}` — for example `survey_responses`,
`ga4_sessions`, `email_events`. Grain is stated in the name so that a join
against the wrong level is visible before it is executed.

**Columns** are `snake_case`. Booleans read as predicates (`is_`, `has_`).
Timestamps end in `_at`. Free-text fields carry a `_raw` suffix where a
normalised counterpart exists alongside them.

**Source-of-truth values are retained.** Where a value is derived for
convenience — a numeric midpoint from a band, for instance — the original is kept
in the table beside it. The derived column is for aggregation; the original is
what the analysis is accountable to.

---

## 6. Privacy

These rules apply to every source, not only to the survey. They matter more, not
less, as GA4 and email data enter the warehouse.

- **Raw records are never committed.** `data/raw/` is git-ignored.
- **Only aggregated outputs are published**, and only where they contain no
  personal data.
- **Personal data is isolated.** Email addresses and any other identifiers are
  held in separate tables and are not joined into anything published.
- **Purpose limitation.** Email addresses were collected for launch
  notification, with that purpose stated at collection. They are not used for
  anything else.
- **Free-text fields are reviewed** for identifying content before any excerpt is
  published.
- **Analytics data is not re-identified.** GA4 data is used in aggregate; no
  attempt is made to link a session to an individual respondent.

---

## 7. Phase documents

| Phase | Document |
|---|---|
| 1 — Survey | [`01_hypotheses.md`](01_hypotheses.md), [`02_methodology.md`](02_methodology.md), [`03_survey_instrument.md`](03_survey_instrument.md), [`04_findings.md`](04_findings.md) |
| Reference | [`05_competitive_pricing.md`](05_competitive_pricing.md) |
| 2 — Website analytics | planned |
| 3 — A/B test | planned |
| 4 — Email campaign | planned |

Each phase adds its own methodology and findings documents. This document is
amended only when the architecture itself changes.
