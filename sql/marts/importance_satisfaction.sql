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
--      Satisfaction was asked only of carrier users, so the base is the same
--      for both scores.
--   2. importance and satisfaction are means of the 1-5 grid answers (Q18,
--      Q16) over respondents who answered the item.
--   3. Four attributes pair items of the same name. 'Material' pairs
--      importance_material_quality with satisfaction_panel_material: different
--      survey items, paired as in the Custom SQL it replaces.
--   4. n is the size of the base, the same on every row. n_importance and
--      n_satisfaction count the answers behind each mean; they differ from n
--      where an item was skipped or not asked.
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
  COUNT(*)                                                        AS n,
  COUNT(importance)                                               AS n_importance,
  COUNT(satisfaction)                                             AS n_satisfaction
FROM paired
GROUP BY attribute
;
