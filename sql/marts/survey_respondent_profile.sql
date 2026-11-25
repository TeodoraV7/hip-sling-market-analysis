-- =============================================================================
-- survey_respondent_profile
-- Source : nomad-503212.intermediate.int_clean_survey_responses
-- Grain  : 1 row = 1 respondent (duplicate submissions removed)
-- PII    : none. Email never reaches intermediate. The free-text carrier
--          brand/model is not exposed; only the extracted brand is.
--
-- Built for the Looker dashboard on habits, needs and demographics:
--   - all answers; satisfaction and importance scores typed as INT64
--   - multi-select dummies (family_activities_*, transport_type_*,
--     switch_reasons_*) passed through as 0/1: SUM in Looker = respondents
--   - *_order columns to sort bands in charts (Looker sorts text A-Z)
--   - the segment flags survey_analysis.ipynb uses (target child age, carrier
--     user, hip sling user, willing to try, opt-in), so dashboard filters give
--     the same numbers as the analysis marts
--   - satisfaction is meaningful only for carrier users: filter on
--     is_carrier_user when charting satisfaction_*
--   - carrier_brand: brand extracted from the free-text answer (Q14) by
--     keyword; unrecognised text -> 'Other', no answer / "none" -> NULL
-- =============================================================================

CREATE OR REPLACE VIEW `nomad-503212.marts.survey_respondent_profile` AS

WITH fingerprinted AS (
  SELECT
    t.*,
    -- every answer except submission metadata
    TO_JSON_STRING((
      SELECT AS STRUCT * EXCEPT (timestamp, respondent_id, updated_at)
      FROM UNNEST([t])
    ))                                                            AS answer_fingerprint
  FROM `nomad-503212.intermediate.int_clean_survey_responses` AS t
),

deduped AS (
  -- Identical answers on every question count as one submission; the earliest
  -- is kept (same rule as survey_analysis.ipynb).
  SELECT * EXCEPT (answer_fingerprint)
  FROM fingerprinted
  WHERE TRUE
  QUALIFY ROW_NUMBER() OVER (
    PARTITION BY answer_fingerprint
    ORDER BY timestamp, respondent_id
  ) = 1
),

with_brand_text AS (
  SELECT
    *,
    LOWER(NULLIF(TRIM(CAST(carrier_brand_model AS STRING)), ''))   AS brand_text
  FROM deduped
),

typed AS (
  SELECT
    * EXCEPT (carrier_brand_model, brand_text, state, updated_at)
      REPLACE (
        SAFE_CAST(SAFE_CAST(satisfaction_overall             AS FLOAT64) AS INT64) AS satisfaction_overall,
        SAFE_CAST(SAFE_CAST(satisfaction_panel_material      AS FLOAT64) AS INT64) AS satisfaction_panel_material,
        SAFE_CAST(SAFE_CAST(satisfaction_other_materials     AS FLOAT64) AS INT64) AS satisfaction_other_materials,
        SAFE_CAST(SAFE_CAST(satisfaction_comfort_parent      AS FLOAT64) AS INT64) AS satisfaction_comfort_parent,
        SAFE_CAST(SAFE_CAST(satisfaction_comfort_child       AS FLOAT64) AS INT64) AS satisfaction_comfort_child,
        SAFE_CAST(SAFE_CAST(satisfaction_durability          AS FLOAT64) AS INT64) AS satisfaction_durability,
        SAFE_CAST(SAFE_CAST(satisfaction_ease_of_use         AS FLOAT64) AS INT64) AS satisfaction_ease_of_use,
        SAFE_CAST(SAFE_CAST(satisfaction_compactness         AS FLOAT64) AS INT64) AS satisfaction_compactness,
        SAFE_CAST(SAFE_CAST(importance_breathability         AS FLOAT64) AS INT64) AS importance_breathability,
        SAFE_CAST(SAFE_CAST(importance_ease_of_use           AS FLOAT64) AS INT64) AS importance_ease_of_use,
        SAFE_CAST(SAFE_CAST(importance_comfort_parent        AS FLOAT64) AS INT64) AS importance_comfort_parent,
        SAFE_CAST(SAFE_CAST(importance_comfort_child         AS FLOAT64) AS INT64) AS importance_comfort_child,
        SAFE_CAST(SAFE_CAST(importance_compactness           AS FLOAT64) AS INT64) AS importance_compactness,
        SAFE_CAST(SAFE_CAST(importance_price                 AS FLOAT64) AS INT64) AS importance_price,
        SAFE_CAST(SAFE_CAST(importance_safety_certifications AS FLOAT64) AS INT64) AS importance_safety_certifications,
        SAFE_CAST(SAFE_CAST(importance_warranty              AS FLOAT64) AS INT64) AS importance_warranty,
        SAFE_CAST(SAFE_CAST(importance_brand_reputation      AS FLOAT64) AS INT64) AS importance_brand_reputation,
        SAFE_CAST(SAFE_CAST(importance_design                AS FLOAT64) AS INT64) AS importance_design,
        SAFE_CAST(SAFE_CAST(importance_material_quality      AS FLOAT64) AS INT64) AS importance_material_quality
      ),
    state                                                         AS country,
    SAFE_CAST(SAFE_CAST(child_age AS FLOAT64) AS INT64)           AS child_age_years,
    -- only the bands offered in Q21/Q24; anything else -> NULL
    IF(CAST(wtp_eur AS STRING) IN ('<50', '50-80', '80-110', '110-140'),
       CAST(wtp_eur AS STRING), NULL)                             AS wtp_band,

    -- ---------- carrier brand from free text (Q14) ----------
    -- direct competitors first, so "Ergobaby and Tula" -> Ergobaby
    CASE
      WHEN REGEXP_CONTAINS(brand_text, r'ergo\s*baby|\bergo\b')   THEN 'Ergobaby'
      WHEN REGEXP_CONTAINS(brand_text, r'wild\s*ride|first\s*ride') THEN 'Wildride'
      WHEN REGEXP_CONTAINS(brand_text, r'\bmabe\b')               THEN 'Mabe'
      WHEN REGEXP_CONTAINS(brand_text, r'tush\s*baby')            THEN 'Tushbaby'
      WHEN REGEXP_CONTAINS(brand_text, r'bj(o|ö|ø)rn')            THEN 'BabyBjorn'
      WHEN REGEXP_CONTAINS(brand_text, r'\bboba\b')               THEN 'Boba'
      WHEN REGEXP_CONTAINS(brand_text, r'\btula\b')               THEN 'Tula'
      WHEN REGEXP_CONTAINS(brand_text, r'manduca')                THEN 'Manduca'
      WHEN REGEXP_CONTAINS(brand_text, r'lille\s*baby')           THEN 'Lillebaby'
      WHEN REGEXP_CONTAINS(brand_text, r'stokke')                 THEN 'Stokke'
      WHEN REGEXP_CONTAINS(brand_text, r'chicco')                 THEN 'Chicco'
      WHEN REGEXP_CONTAINS(brand_text, r'infantino')              THEN 'Infantino'
      WHEN REGEXP_CONTAINS(brand_text, r'cybex')                  THEN 'Cybex'
      WHEN REGEXP_CONTAINS(brand_text, r'\bbeco\b')               THEN 'Beco'
      WHEN REGEXP_CONTAINS(brand_text, r'momcozy')                THEN 'Momcozy'
      WHEN REGEXP_CONTAINS(brand_text, r'kikka\s*boo')            THEN 'Kikka Boo'
      WHEN REGEXP_CONTAINS(brand_text, r'decathlon|newfeel')      THEN 'Decathlon'
      WHEN REGEXP_CONTAINS(brand_text, r'emei\s*baby')            THEN 'Emeibaby'
      WHEN REGEXP_CONTAINS(brand_text, r'buzzidil')               THEN 'Buzzidil'
      WHEN REGEXP_CONTAINS(brand_text, r'didymos')                THEN 'Didymos'
      WHEN REGEXP_CONTAINS(brand_text, r'\bmoby\b')               THEN 'Moby'
      -- no answer, "none", "-", "don't use/know" -> NULL
      WHEN brand_text IS NULL
        OR REGEXP_CONTAINS(brand_text,
             r'^(no|none|nothing|n/?a|-+|\.+|/|ne|nema|ninguna?o?|no uso|i don.?t.*|don.?t.*)\.?$')
        THEN NULL
      ELSE 'Other'
    END                                                           AS carrier_brand,
    -- mentions any of the four benchmarked competitors
    COALESCE(REGEXP_CONTAINS(brand_text,
      r'ergo\s*baby|\bergo\b|wild\s*ride|first\s*ride|\bmabe\b|tush\s*baby'), FALSE)
                                                                  AS is_direct_competitor_user
  FROM with_brand_text
)

SELECT
  *,
  -- ---------- sort keys for bands ----------
  CASE respondent_age
    WHEN '<20' THEN 1 WHEN '21-25' THEN 2 WHEN '26-30' THEN 3 WHEN '31-35' THEN 4
    WHEN '35-40' THEN 5 WHEN '40-45' THEN 6 WHEN '>45' THEN 7 END   AS respondent_age_order,
  CASE child_weight_kg
    WHEN '6-10' THEN 1 WHEN '11-15' THEN 2 WHEN '16-20' THEN 3
    WHEN 'Other' THEN 4 END                                       AS child_weight_order,
  CASE outdoor_frequency
    WHEN 'Every day' THEN 1 WHEN 'A few times a week' THEN 2
    WHEN 'A few times a month' THEN 3 WHEN 'Only on vacations' THEN 4
    WHEN 'Almost never' THEN 5 END                                AS outdoor_frequency_order,
  CASE outdoor_time_per_day_hrs
    WHEN '<1' THEN 1 WHEN '1-2' THEN 2 WHEN '2-3' THEN 3
    WHEN '3-4' THEN 4 WHEN '>4' THEN 5 END                        AS outdoor_time_order,
  CASE carrier_usage_frequency
    WHEN 'Every day' THEN 1 WHEN 'A few times a week' THEN 2
    WHEN 'A few times a month' THEN 3 WHEN 'Only for special events' THEN 4
    WHEN 'Never' THEN 5 END                                       AS carrier_usage_frequency_order,
  CASE wtp_band
    WHEN '<50' THEN 1 WHEN '50-80' THEN 2 WHEN '80-110' THEN 3
    WHEN '110-140' THEN 4 END                                     AS wtp_band_order,

  -- ---------- segment flags (as in survey_analysis.ipynb) ----------
  COALESCE(child_age_years BETWEEN 1 AND 4, FALSE)                AS is_target_child_age,
  COALESCE(uses_carrier_current IN ('Yes', 'Sometimes'), FALSE)   AS is_carrier_user,
  COALESCE(uses_hip_sling_current IN ('Yes', 'Sometimes'), FALSE) AS is_hip_sling_user,
  COALESCE(would_try_hip_sling = 'Yes', FALSE)                    AS is_willing_to_try,
  COALESCE(interested_in_launch = 'Yes', FALSE)                   AS is_opted_in
FROM typed
;
