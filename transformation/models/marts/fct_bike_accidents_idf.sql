{{ config(
    materialized = "table",
    alias        = "fct_bike_accidents_idf"
) }}

#-------------------------------------------------------------------------
# 0 Departments for Île-de-France (INSEE codes as strings)
#-------------------------------------------------------------------------
{% set idf_departments = [
    '75','77','78','91','92','93','94','95'
] %}

#-------------------------------------------------------------------------
# 1 Build bike-only subset (vehicle_category_cd IN (1, 80))
#-------------------------------------------------------------------------
with selected as (

  select
    *
  from {{ ref('fct_accident_causes') }}
  where 
    department in ({{ "'" + idf_departments | join("', '") + "'" }})
    and vehicle_category_cd in (1, 80)   -- 1 = bicycle, 80 = e-bicycle

)

select *
from selected
order by accident_date desc, accident_id