-- =============================================================================
-- importance_satisfaction
-- Source : nomad-503212.marts.survey_respondent_profile
-- Grain  : 1 row = 1 carrier attribute (attribute)
-- PII    : none (aggregated)
--
-- What matters in a carrier against how well the current carrier delivers it,
-- for the importance-satisfaction chart of the Looker dashboard. Replaces the
-- Looker Custom SQL of the same name.
--
-- Logic
--   1. Base = current carrier users (Yes or Sometimes) with a child aged 1-4.
--      Both grids were shown to every respondent, non-users included
--      (03_survey_instrument.md section 4), and non-users did answer them.
--      They are left out because satisfaction with a current carrier is only
--      meaningful for those who use one, and both scores then come from the
--      same people. Importance here therefore differs from
--      h3_importance_ranking, which averages all qualified respondents.
--   2. importance and satisfaction are means of the 1-5 grid answers (Q18,
--      Q16) over respondents who answered the item.
--   3. Four attributes pair items of the same name. 'Material' pairs
--      importance_material_quality with satisfaction_panel_material: different
--      survey items, paired as in the Custom SQL it replaces.
--   4. n is the size of the base, the same on every row. Checked on the final
--      data: all 63 carrier users answered the items tested (comfort for the
--      parent, compactness, material), so n is also the number of answers
--      behind each mean.
-- =============================================================================

CREATE OR REPLACE VIEW `nomad-503212.marts.importance_satisfaction` AS

WITH carrier_users AS (
  SELECT
    importance_comfort_parent,    satisfaction_comfort_parent,
    importance_comfort_child,     satisfaction_comfort_child,
    importance_ease_of_use,       satisfaction_ease_of_use,
    importance_compactness,       satisfaction_compactness,
    importance_material_quality,  satisfaction_panel_material
  FROM `nomad-503212.marts.survey_respondent_profile`
  WHERE is_carrier_user
    AND child_age_years BETWEEN 1 AND 4
),

paired AS (
  SELECT attribute, importance, satisfaction
  FROM carrier_users, UNNEST([
    STRUCT('Comfort (parent)' AS attribute,
           importance_comfort_parent AS importance,
           satisfaction_comfort_parent AS satisfaction),
    ('Comfort (child)', importance_comfort_child,    satisfaction_comfort_child),
    ('Ease of use',     importance_ease_of_use,      satisfaction_ease_of_use),
    ('Compactness',     importance_compactness,      satisfaction_compactness),
    ('Material',        importance_material_quality, satisfaction_panel_material)
  ])
)

SELECT
  attribute,
  AVG(importance)                                                 AS importance,
  AVG(satisfaction)                                               AS satisfaction,
  COUNT(*)                                                        AS n
FROM paired
GROUP BY attribute
;
