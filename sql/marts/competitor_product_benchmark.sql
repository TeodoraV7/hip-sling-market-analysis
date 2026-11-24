-- =============================================================================
-- competitor_product_benchmark
-- Source : nomad-503212.intermediate.int_competitor_benchmark
-- Grain  : 1 row = 1 product (product_key)
--
-- Logic
--   1. Primary listing per product: brand site first, Spanish storefront first,
--      then most reviews. One list price (EUR), specs, safety and shipping
--      come from this listing.
--   2. Reviews are pooled across listings, excluding syndicated ones (no double
--      counting). Rating = review-count-weighted average of rated listings.
--   3. Shoulder/strap complaint flag is TRUE if any listing has it.
--   4. Best-rated accessory = highest-rated across all listings.
-- =============================================================================

CREATE OR REPLACE VIEW `nomad-503212.marts.competitor_product_benchmark` AS

WITH listings AS (
  SELECT
    *,
    -- reviews that count toward the product rating
    NOT COALESCE(is_syndicated_reviews, FALSE)
      AND avg_rating IS NOT NULL
      AND review_count IS NOT NULL                                AS is_rated_listing,
    ROW_NUMBER() OVER (
      PARTITION BY product_key
      ORDER BY source_type = 'brand_site' DESC,
               source_market = 'es' DESC,
               review_count DESC
    )                                                             AS listing_rank
  FROM `nomad-503212.intermediate.int_competitor_benchmark`
  WHERE product_key IS NOT NULL
),

product_reviews AS (
  SELECT
    product_key,
    COUNT(*)                                                      AS n_listings,
    SUM(IF(NOT COALESCE(is_syndicated_reviews, FALSE), review_count, NULL)) AS review_count_total,
    SUM(IF(is_rated_listing, review_count, NULL))                 AS review_count_rated,
    COUNTIF(is_rated_listing)                                     AS n_listings_rated,
    ROUND(SAFE_DIVIDE(SUM(IF(is_rated_listing, review_count * avg_rating, NULL)),
                      SUM(IF(is_rated_listing, review_count, NULL))), 2) AS avg_rating_weighted,
    LOGICAL_OR(has_neg_theme_shoulder_strap)                      AS has_neg_theme_shoulder_strap,
    ARRAY_AGG(IF(best_rated_accessory IS NULL, NULL,
                 STRUCT(best_rated_accessory AS name, best_rated_accessory_rating AS rating))
              IGNORE NULLS ORDER BY best_rated_accessory_rating DESC LIMIT 1)[SAFE_OFFSET(0)] AS best_accessory
  FROM listings
  GROUP BY product_key
)

SELECT
  -- ---------- identity ----------
  p.product_key,
  p.brand,
  p.product_name,

  -- ---------- price (primary listing) ----------
  p.price_eur                                                     AS list_price_eur,

  -- ---------- child spec (primary listing) ----------
  p.weight_min_kg,
  p.weight_max_kg,
  p.age_min_months,
  p.age_max_months,
  p.age_spec_months,
  p.is_independent_sitting_required,

  -- ---------- reviews (all listings) ----------
  r.n_listings,
  r.n_listings_rated,
  r.review_count_total,
  r.review_count_rated,
  r.avg_rating_weighted,
  r.has_neg_theme_shoulder_strap,

  -- ---------- accessories ----------
  p.has_accessories,
  r.best_accessory.name                                           AS best_rated_accessory,
  r.best_accessory.rating                                         AS best_rated_accessory_rating,

  -- ---------- ergonomics / safety (primary listing) ----------
  p.has_ergonomic_claim,
  p.ergonomic_certification,
  p.safety_standards_listed,

  -- ---------- shipping (primary listing) ----------
  p.is_shipping_to_spain,
  p.is_shipping_to_eu,
  p.is_shipping_to_serbia

FROM listings AS p
JOIN product_reviews AS r ON r.product_key = p.product_key
WHERE p.listing_rank = 1
;
