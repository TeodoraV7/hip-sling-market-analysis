-- =============================================================================
-- target_customers
-- Source : nomad-503212.marts.survey_respondent_profile
-- Grain  : 1 row = 1 respondent segment (segment)
-- PII    : none. Aggregated; segments with fewer than 10 respondents are not
--          published.
--
-- Who the product is for: opt-in rate and willingness to pay of each
-- respondent segment, for the target-customer page of the Looker dashboard.
-- Replaces the Looker Custom SQL of the same name.
--
-- Logic
--   1. Base = respondents with a child aged 1-4, the qualified population of
--      06_analysis_plan.md section 2. The base is applied here, so the
--      dashboard does not repeat it. The segment 'All respondents' is this
--      whole base (not every submission): the benchmark each segment is read
--      against.
--   2. Segments are defined once, in the UNNEST list below, and overlap: a
--      respondent counts in every segment they belong to, so `n` does not
--      sum to the base. To add a segment, add one line to the list.
--   3. opt_in_rate = share who opted in to launch notification (is_opted_in).
--      wtp50_rate  = share whose WTP band is 50 or more (50-80, 80-110,
--      110-140), among respondents who answered the WTP question. A missing
--      band stays NULL and is left out of this rate (no imputation, as in
--      06_analysis_plan.md section 8), so `n` can be larger than the number of
--      answers behind wtp50_rate. This is not the QIR qualifying band
--      (80-110 or higher).
--   4. Segments with fewer than 10 respondents are dropped, the same floor as
--      MIN_COUNTRY_N in survey_analysis.ipynb.
--   5. is_near_centre flags segments within 0.05 of the centre of the scatter
--      plot (opt-in rate 0.64, WTP50 rate 0.58) on both axes. It is a flag, not
--      an exclusion: these segments are part of the analysis and stay in the
--      view, so tables and other charts still show them. The dashboard filters
--      on is_near_centre = FALSE on the scatter plot only, for a cleaner
--      visual. The centre is a fixed value: the survey is a one-time
--      collection, with no further responses or changes.
-- =============================================================================

CREATE OR REPLACE VIEW `nomad-503212.marts.target_customers` AS

WITH base AS (
  SELECT
    IF(is_opted_in, 1, 0)                                         AS opted_in,
    CASE
      WHEN wtp_band IS NULL THEN NULL
      WHEN wtp_band IN ('50-80', '80-110', '110-140') THEN 1
      ELSE 0
    END                                                           AS wtp_50_plus,
    family_activities_travel,
    family_activities_weekend_trips,
    family_activities_caffes_restaurats,
    family_activities_family_or_social_events,
    family_activities_sport_activities,
    family_activities_shopping,
    transport_type_public_transport,
    transport_type_car,
    transport_type_walking,
    area_type,
    outdoor_time_per_day_hrs,
    num_children,
    child_age_years,
    is_carrier_user,
    is_direct_competitor_user,
    respondent_age
  FROM `nomad-503212.marts.survey_respondent_profile`
  WHERE child_age_years BETWEEN 1 AND 4
),

segmented AS (
  SELECT segment, opted_in, wtp_50_plus
  FROM base, UNNEST([
    STRUCT('All respondents' AS segment, TRUE AS in_segment),
    -- family activities (multi-select dummies)
    ('Travel',               family_activities_travel = 1),
    ('Weekend trips',        family_activities_weekend_trips = 1),
    ('Cafés/restaurants',    family_activities_caffes_restaurats = 1),
    ('Family/social events', family_activities_family_or_social_events = 1),
    ('Sport',                family_activities_sport_activities = 1),
    ('Shopping',             family_activities_shopping = 1),
    -- transport (multi-select dummies)
    ('Public transport',     transport_type_public_transport = 1),
    ('Car',                  transport_type_car = 1),
    ('Walking',              transport_type_walking = 1),
    -- where they live
    ('Urban area',           area_type = 'Urban area'),
    ('City center',          area_type = 'City center'),
    ('Suburban',             area_type = 'Suburban area'),
    -- time outdoors per day
    ('Outdoors 1-2h',        outdoor_time_per_day_hrs = '1-2'),
    ('Outdoors 2-3h',        outdoor_time_per_day_hrs = '2-3'),
    ('Outdoors 3-4h',        outdoor_time_per_day_hrs = '3-4'),
    -- household
    ('One child',            num_children = 1),
    ('Two children',         num_children = 2),
    ('Child 1-2y',           child_age_years <= 2),
    ('Child 3-4y',           child_age_years >= 3),
    -- carrier use
    ('Carrier user',         is_carrier_user),
    ('Non-user',             NOT is_carrier_user),
    ('Competitor user',      is_direct_competitor_user),
    -- parent age
    ('Parent 26-30',         respondent_age = '26-30'),
    ('Parent 31-35',         respondent_age = '31-35'),
    ('Parent 35-40',         respondent_age = '35-40')
  ])
  WHERE in_segment
),

by_segment AS (
  SELECT
    segment,
    COUNT(*)                                                      AS n,
    AVG(opted_in)                                                 AS opt_in_rate,
    AVG(wtp_50_plus)                                              AS wtp50_rate
  FROM segmented
  GROUP BY segment
  HAVING COUNT(*) >= 10
)

SELECT
  *,
  ABS(opt_in_rate - 0.64) < 0.05
    AND ABS(wtp50_rate - 0.58) < 0.05                             AS is_near_centre
FROM by_segment
;
