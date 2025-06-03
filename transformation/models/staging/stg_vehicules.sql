{{ config(materialized='table') }}

WITH raw AS (
  SELECT
    *,
    SAFE_CAST(REGEXP_EXTRACT(_FILE_NAME, r'(\d{4})\.csv$') AS INT64) AS accident_year
  FROM 
    {{ source('raw_vehicules', 'raw_vehicules_all') }}
)

SELECT
  Num_Acc,

  NULLIF(TRIM(id_vehicule), '-1')                 AS id_vehicule,
  TRIM(num_veh)                                     AS num_veh,

  {{ cast_int('senc',   allow_codes=true) }}         AS senc,
  {{ cast_int('catv',   allow_codes=true) }}         AS catv,
  {{ cast_int('obs',    allow_codes=true) }}         AS obs,
  {{ cast_int('obsm',   allow_codes=true) }}         AS obsm,
  {{ cast_int('choc',   allow_codes=true) }}         AS choc,
  {{ cast_int('manv',   allow_codes=true) }}         AS manv,
  {{ cast_int('motor',  allow_codes=true) }}         AS motor,
  {{ cast_int('occutc', allow_codes=true) }}         AS occutc,

  accident_year
FROM raw