{{ config(materialized='table') }}

WITH raw AS (
  SELECT
    *,
    SAFE_CAST(REGEXP_EXTRACT(_FILE_NAME, r'(\d{4})\.csv$') AS INT64) AS accident_year
  FROM {{ source('raw_usagers', 'raw_usagers_all') }}
)

SELECT
  Num_Acc,

  NULLIF(TRIM(id_usager), '-1')                 AS id_usager,
  NULLIF(TRIM(id_vehicule), '-1')                 AS id_vehicule,

  TRIM(num_veh)                                   AS num_veh,

  {{ cast_int('place', allow_codes=true) }}        AS place,
  {{ cast_int('catu',  allow_codes=true) }}        AS catu,
  {{ cast_int('grav',  allow_codes=true) }}        AS grav,
  {{ cast_int('sexe',  allow_codes=true) }}        AS sexe,

  {{ cast_int('an_nais') }}                        AS an_nais,
  {{ cast_int('trajet', allow_codes=true) }}       AS trajet,

  -- safety devices
  {{ cast_int('secu1', allow_codes=true) }}        AS secu1,
  {{ cast_int('secu2', allow_codes=true) }}        AS secu2,
  {{ cast_int('secu3', allow_codes=true) }}        AS secu3,

  -- pedestrian only
  {{ cast_int('locp',  allow_codes=true) }}        AS locp,
  {{ cast_int('actp',  allow_codes=true) }}        AS actp,
  {{ cast_int('etatp', allow_codes=true) }}        AS etatp,

  accident_year
FROM raw