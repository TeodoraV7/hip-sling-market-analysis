-- =============================================================================
-- int_competitor_benchmark
-- Source : nomad-503212.staging.stg_benchmark_competitors  (CSV 2026-11-18)
-- Grain  : 1 row = brand x product x review_source x collected_at
-- PII    : none (public product pages only)
--
-- Transformations
--   1. Types: DATE / NUMERIC / INT64; '' -> NULL
--   2. yes/no -> BOOL (yes = TRUE, no = FALSE, anything else -> NULL);
--      test_report_public kept as status string (not_seen <> unknown)
--   3. Brand alias Firstride -> Wildride; canonical product_key
--   4. price_eur via hardcoded ECB reference rates of 2026-11-18
--   5. Weight (kg) and age (months) parsed from free-text spec
--   6. Review quality flags (AI-summary themes, syndicated reviews)
--   7. Flag: negative themes mention shoulder / strap / neck
-- =============================================================================

CREATE OR REPLACE VIEW `nomad-503212.intermediate.int_competitor_benchmark` AS

WITH src AS (
  -- Normalise everything to trimmed strings first; yes/no flags are mapped
  -- to BOOL explicitly in `typed`.
  SELECT
    NULLIF(TRIM(CAST(brand AS STRING)), '')                         AS brand_raw,
    NULLIF(TRIM(CAST(product_name AS STRING)), '')                  AS product_name,
    NULLIF(TRIM(CAST(product_url AS STRING)), '')                   AS product_url,
    LOWER(NULLIF(TRIM(CAST(review_source AS STRING)), ''))          AS review_source,
    SAFE_CAST(collected_at AS DATE)                                 AS collected_at,
    SAFE_CAST(price_local AS NUMERIC)                               AS price_local,
    UPPER(NULLIF(TRIM(CAST(price_currency AS STRING)), ''))         AS price_currency,
    LOWER(NULLIF(TRIM(CAST(price_is_promo AS STRING)), ''))         AS price_is_promo,
    LOWER(NULLIF(TRIM(CAST(child_weight_range_spec AS STRING)), '')) AS weight_spec,
    LOWER(NULLIF(TRIM(CAST(child_age_range_spec AS STRING)), ''))   AS age_spec,
    SAFE_CAST(review_count AS INT64)                                AS review_count,
    SAFE_CAST(avg_rating AS FLOAT64)                                AS avg_rating,
    SAFE_CAST(reviews_analyzed AS INT64)                            AS reviews_analyzed,
    LOWER(NULLIF(TRIM(CAST(theme_method AS STRING)), ''))           AS theme_method,
    NULLIF(TRIM(CAST(top_positive_themes AS STRING)), '')           AS top_positive_themes,
    NULLIF(TRIM(CAST(top_negative_themes AS STRING)), '')           AS top_negative_themes,
    NULLIF(TRIM(CAST(top_use_cases AS STRING)), '')                 AS top_use_cases,
    LOWER(NULLIF(TRIM(CAST(has_accessories AS STRING)), ''))        AS has_accessories,
    NULLIF(TRIM(CAST(accessories_list AS STRING)), '')              AS accessories_list,
    NULLIF(TRIM(CAST(best_rated_accessory AS STRING)), '')          AS best_rated_accessory,
    SAFE_CAST(best_rated_accessory_rating AS FLOAT64)               AS best_rated_accessory_rating,
    LOWER(NULLIF(TRIM(CAST(ergonomic_claim AS STRING)), ''))        AS ergonomic_claim,
    NULLIF(TRIM(CAST(ergonomic_certification AS STRING)), '')       AS ergonomic_certification,
    NULLIF(TRIM(CAST(safety_page_url AS STRING)), '')               AS safety_page_url,
    NULLIF(TRIM(CAST(safety_standards_listed AS STRING)), '')       AS safety_standards_listed,
    LOWER(NULLIF(TRIM(CAST(test_report_public AS STRING)), ''))     AS test_report_public,
    LOWER(NULLIF(TRIM(CAST(ships_to_spain AS STRING)), ''))         AS ships_to_spain,
    LOWER(NULLIF(TRIM(CAST(ships_to_eu AS STRING)), ''))            AS ships_to_eu,
    LOWER(NULLIF(TRIM(CAST(ships_to_serbia AS STRING)), ''))        AS ships_to_serbia,
    NULLIF(TRIM(CAST(shipping_notes AS STRING)), '')                AS shipping_notes,
    NULLIF(TRIM(CAST(notes AS STRING)), '')                         AS notes
  FROM `nomad-503212.staging.stg_benchmark_competitors`
),

typed AS (
  SELECT
    -- ---------- identity ----------
    CASE WHEN LOWER(brand_raw) IN ('wildride', 'firstride') THEN 'Wildride'
         ELSE brand_raw END                                          AS brand,
    -- One product per brand in this pull; extend the CASE if a brand gets a 2nd product.
    -- Wildride "Soft Toddler Carrier Hip Seat Carrier" (Target) is the same product as
    -- the Wildride Toddler Carrier (confirmed), only listed under a different title.
    CASE LOWER(brand_raw)
      WHEN 'mabe'      THEN 'mabe_monarch_toddler_sling'
      WHEN 'tushbaby'  THEN 'tushbaby_liftoff'
      WHEN 'ergobaby'  THEN 'ergobaby_upsie'
      WHEN 'wildride'  THEN 'wildride_toddler_carrier'
      WHEN 'firstride' THEN 'wildride_toddler_carrier'
    END                                                              AS product_key,
    product_name,
    product_url,
    review_source,
    CASE WHEN STARTS_WITH(review_source, 'brand_site') THEN 'brand_site'
         WHEN review_source IS NOT NULL               THEN 'retailer' END AS source_type,
    REGEXP_EXTRACT(review_source, r'_([a-z]{2})$')                   AS source_market,
    collected_at,

    -- ---------- price ----------
    price_local,
    price_currency,
    -- ECB euro reference rates of 2026-11-18: 1 EUR = 1.0968 USD = 0.8329 GBP.
    -- Hardcoded on purpose (single snapshot); factors below = 1 / rate.
    ROUND(price_local * CASE price_currency
                          WHEN 'EUR' THEN NUMERIC '1'
                          WHEN 'USD' THEN NUMERIC '0.911743'   -- 1 / 1.0968
                          WHEN 'GBP' THEN NUMERIC '1.200624'   -- 1 / 0.8329
                        END, 2)                                  AS price_eur,
    CASE price_is_promo WHEN 'yes' THEN TRUE WHEN 'no' THEN FALSE END AS is_promo_price,

    -- ---------- child spec ----------
    weight_spec,
    CASE
      WHEN REGEXP_CONTAINS(weight_spec, r'\d+(?:\.\d+)?-\d+(?:\.\d+)? kg')
        THEN SAFE_CAST(REGEXP_EXTRACT(weight_spec, r'(\d+(?:\.\d+)?)-\d+(?:\.\d+)? kg') AS FLOAT64)
      WHEN REGEXP_CONTAINS(weight_spec, r'\d+(?:\.\d+)? lb min')
        THEN ROUND(SAFE_CAST(REGEXP_EXTRACT(weight_spec, r'(\d+(?:\.\d+)?) lb min') AS FLOAT64) * 0.45359237, 1)
    END                                                              AS weight_min_kg,
    CASE
      WHEN REGEXP_CONTAINS(weight_spec, r'\d+(?:\.\d+)?-\d+(?:\.\d+)? kg')
        THEN SAFE_CAST(REGEXP_EXTRACT(weight_spec, r'\d+(?:\.\d+)?-(\d+(?:\.\d+)?) kg') AS FLOAT64)
      WHEN REGEXP_CONTAINS(weight_spec, r'max \d+(?:\.\d+)? kg')
        THEN SAFE_CAST(REGEXP_EXTRACT(weight_spec, r'max (\d+(?:\.\d+)?) kg') AS FLOAT64)
    END                                                              AS weight_max_kg,
    age_spec,
    -- Each number takes the first unit after it, so "1-4 years" -> 12-48,
    -- "6 months-4 years" -> 6-48, "18+ months" -> 18. No unit -> NULL.
    SAFE_CAST(REGEXP_EXTRACT(age_spec, r'^(\d+)') AS INT64)
      * CASE REGEXP_EXTRACT(age_spec, r'^\d+[^a-z]*(month|year)')
          WHEN 'year' THEN 12 WHEN 'month' THEN 1 END                AS age_min_months,
    SAFE_CAST(REGEXP_EXTRACT(age_spec, r'-\s*(\d+)\s*(?:month|year)') AS INT64)
      * CASE REGEXP_EXTRACT(age_spec, r'-\s*\d+\s*(month|year)')
          WHEN 'year' THEN 12 WHEN 'month' THEN 1 END                AS age_max_months,
    REGEXP_CONTAINS(age_spec, r'\bsit(?:s|ting)?\b')                 AS is_independent_sitting_required,

    -- ---------- reviews ----------
    review_count,
    avg_rating,
    reviews_analyzed,
    theme_method,
    top_positive_themes,
    top_negative_themes,
    top_use_cases,

    -- ---------- accessories ----------
    CASE has_accessories WHEN 'yes' THEN TRUE WHEN 'no' THEN FALSE END AS has_accessories,
    accessories_list,
    best_rated_accessory,
    best_rated_accessory_rating,

    -- ---------- ergonomics / safety ----------
    CASE ergonomic_claim WHEN 'yes' THEN TRUE WHEN 'no' THEN FALSE END AS has_ergonomic_claim,
    ergonomic_certification,
    safety_page_url,
    safety_standards_listed,
    -- 'not_seen' (looked, not found) differs from 'unknown' (not checked)
    test_report_public                                               AS test_report_public_status,

    -- ---------- shipping ('n/a' = retailer listing, 'unknown' = not checked -> NULL) ----------
    CASE ships_to_spain  WHEN 'yes' THEN TRUE WHEN 'no' THEN FALSE END AS is_shipping_to_spain,
    CASE ships_to_eu     WHEN 'yes' THEN TRUE WHEN 'no' THEN FALSE END AS is_shipping_to_eu,
    CASE ships_to_serbia WHEN 'yes' THEN TRUE WHEN 'no' THEN FALSE END AS is_shipping_to_serbia,
    shipping_notes,
    notes
  FROM src
)

SELECT
  t.*,

  -- age range in months as text: '6-48', '18+'; NULL if no numeric age spec
  CASE
    WHEN t.age_min_months IS NOT NULL AND t.age_max_months IS NOT NULL
      THEN FORMAT('%d-%d', t.age_min_months, t.age_max_months)
    WHEN t.age_min_months IS NOT NULL
      THEN FORMAT('%d+', t.age_min_months)
  END                                                                AS age_spec_months,

  -- review quality flags (NULL when the source field is empty)
  REGEXP_CONTAINS(t.theme_method, r'platform_ai_summary')            AS has_ai_summary_themes,
  -- Retailer listings that re-publish brand-site reviews: exclude from rating
  -- aggregation to avoid double counting (Ergobaby on Target in this pull).
  REGEXP_CONTAINS(LOWER(t.notes), r'syndicated')                     AS is_syndicated_reviews,

  -- differentiator check: do complaints touch shoulder / strap / neck?
  REGEXP_CONTAINS(LOWER(t.top_negative_themes), r'shoulder|strap|neck') AS has_neg_theme_shoulder_strap

FROM typed AS t
;
