{{ config(
    materialized = "table",
    alias        = "fct_bike_accidents_idf"
) }}

select 
  *
from 
  {{ ref('fct_accidents_ml') }}
where 
  department in ('75','77','78','91','92','93','94','95')
  and vehicle_category_cd in (1,50,80)