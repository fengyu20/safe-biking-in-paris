{{ config(
    materialized = "table",
    alias        = "fct_micromobility_accidents_idf"
) }}

#-------------------------------------------------------------------------
# 0 Departments for Île-de-France
#-------------------------------------------------------------------------
{% set idf_departments = [
    '75','77','78','91','92','93','94','95'
] %}

#-------------------------------------------------------------------------
# 1 Micromobility code set
#   •  1 = Bicycle
#   • 30 = Scooter < 50 cm³
#   • 32 = Scooter 50-125 cm³
#   • 34 = Scooter > 125 cm³
#   • 50 = E-personal transport (motorized)
#   • 60 = E-personal transport (non-motorized)
#   • 80 = E-bicycle
#-------------------------------------------------------------------------
{% set micro_codes = (1, 30, 32, 34, 50, 60, 80) %}

with selected as (

  select
    *,
    
    -- Micromobility-specific derived columns for analysis
    case 
      when vehicle_category_cd = 1 then 'bicycle'
      when vehicle_category_cd = 30 then 'scooter_small'
      when vehicle_category_cd = 32 then 'scooter_medium' 
      when vehicle_category_cd = 34 then 'scooter_large'
      when vehicle_category_cd = 50 then 'e_transport_motor'
      when vehicle_category_cd = 60 then 'e_transport_nonmotor'
      when vehicle_category_cd = 80 then 'e_bicycle'
      else 'other'
    end as vehicle_type,
    
    case 
      when vehicle_category_cd in (50, 60, 80) then 1 else 0 
    end as is_electric,
    
    case 
      when vehicle_category_cd in (30, 32, 34) then 1 else 0 
    end as is_motorized_scooter,
    
    case 
      when vehicle_category_cd = 1 then 1 else 0 
    end as is_traditional_bike
    
  from {{ ref('fct_accident_causes') }}
  where 
    department in ({{ "'" + idf_departments | join("', '") + "'" }})
    and vehicle_category_cd in {{ micro_codes }}
    and is_severe_accident is not null -- targe column should not be null

)

select *
from selected
order by accident_date desc, accident_id