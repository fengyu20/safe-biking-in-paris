{{ config(materialized='table') }}

WITH raw AS (
  SELECT
    *,
    COALESCE(
      SAFE_CAST(REGEXP_EXTRACT(_FILE_NAME, r'(\d{4})\.csv$') AS INT64),
      SAFE_CAST(an AS INT64)
    ) AS accident_year
  FROM {{ source('raw_caract', 'raw_caract_all') }}
)

SELECT
  Num_Acc,

  -- calendar
  {{ cast_int('jour') }}                 AS jour,
  {{ cast_int('mois') }}                 AS mois,
  SAFE_CAST(TRIM(an) AS INT64)           AS an,

  -- time of crash  + keep raw
  CASE 
    WHEN TRIM(hrmn) = '' OR TRIM(hrmn) IS NULL OR TRIM(hrmn) = '-1' THEN NULL
    ELSE SAFE.PARSE_TIME('%H:%M', TRIM(hrmn))
  END                                    AS hrmn,
  TRIM(hrmn)                             AS hrmn_raw,

  -- coded fields (sentinels kept)
  {{ cast_int('lum', allow_codes=true) }}        AS lum,
  dep,
  com,
  {{ cast_int('agg', allow_codes=true) }}        AS agg,
  {{ cast_int('int', allow_codes=true) }}        AS intersection,
  {{ cast_int('atm', allow_codes=true) }}        AS atm,
  {{ cast_int('col', allow_codes=true) }}        AS col,

  -- address
  adr,

  -- geolocation  + keep raw
  {{ cast_float('lat',  allow_codes=true) }}     AS latitude,
  {{ cast_float('long', allow_codes=true) }}     AS longitude,
  ST_GEOGPOINT(
    {{ cast_float('long', allow_codes=true) }},
    {{ cast_float('lat',  allow_codes=true) }}
  ) AS geo,
  TRIM(lat)    AS lat_raw,
  TRIM(`long`) AS long_raw,

  accident_year
FROM raw