{{ config(materialized='table') }}

WITH raw AS (
  SELECT
    *,
    SAFE_CAST(REGEXP_EXTRACT(_FILE_NAME, r'(\d{4})\.csv$') AS INT64) AS accident_year
  FROM {{ source('raw_lieux', 'raw_lieux_all') }}
)

SELECT
  Num_Acc,

  -- coded categories (keep sentinel values)
  {{ cast_int('catr', allow_codes=true) }}   AS catr,

  -- route / street name (string) + optional numeric helper
  TRIM(voie)                                 AS voie,
  CAST(REGEXP_EXTRACT(TRIM(voie), r'(\d+)') AS INT64)  AS voie_num,

  TRIM(v2)                                   AS v2,

  -- circulation regime
  {{ cast_int('circ', allow_codes=true) }}   AS circ,
  {{ cast_int('nbv',  allow_codes=true) }}   AS nbv,
  {{ cast_int('vosp', allow_codes=true) }}   AS vosp,

  -- profile and reference points
  {{ cast_int('prof', allow_codes=true) }}   AS prof,
  {{ cast_int('pr',   allow_codes=true) }}   AS pr,
  {{ cast_int('pr1',  allow_codes=true) }}   AS pr1,

  {{ cast_int('plan', allow_codes=true) }}   AS plan,

  -- widths (floats, keep -1)
  {{ cast_float('lartpc', allow_codes=true) }} AS lartpc,
  {{ cast_float('larrout', allow_codes=true) }} AS larrout,

  -- surface / infrastructure / situation
  {{ cast_int('surf',  allow_codes=true) }}  AS surf,
  {{ cast_int('infra', allow_codes=true) }}  AS infra,
  {{ cast_int('situ',  allow_codes=true) }}  AS situ,

  -- speed limit
  {{ cast_int('vma', allow_codes=true) }}    AS vma,

  accident_year
FROM raw