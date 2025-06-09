{{ config(
    materialized = "table",
    alias        = "fct_accidents_ml"
) }}

with selected as (

  select
    severity_cd,

    -- Demographics 
    age,
    coalesce(age_group_cd, -1) as age_group_cd,
    coalesce(gender_cd, -1) as gender_cd,
    coalesce(trip_purpose_cd, -1) as trip_purpose_cd,

    -- Accident context
    coalesce(has_helmet, -1) as has_helmet,
    coalesce(vehicle_category_cd, -1) as vehicle_category_cd,
    coalesce(light_condition_grp_cd, -1) as light_condition_grp_cd,
    coalesce(weather_condition_grp_cd, -1) as weather_condition_grp_cd,
    coalesce(surface_condition_cd, -1) as surface_condition_cd,
    coalesce(within_urban_cd, -1) as within_urban_cd,
    coalesce(intersection_type_cd, -1) as intersection_type_cd,
    coalesce(road_category_cd, -1) as road_category_cd,
    coalesce(public_transport_lane_cd, -1) as public_transport_lane_cd,
    coalesce(infrastructure_cd, -1) as infrastructure_cd,
    coalesce(long_profile_cd, -1) as long_profile_cd,
    coalesce(planimetry_cd, -1) as planimetry_cd,
    coalesce(number_of_lanes, -1) as number_of_lanes_cd,
    speed_limit_kmh,  
    
    -- Group collision types
    coalesce(collision_group_cd, -1) as collision_group_cd,
    
    -- Group impact points
    coalesce(impact_point_cd, -1) as impact_point_cd,
    
    -- Group manoeuvres
    coalesce(manoeuvre_cd, -1) as manoeuvre_cd,
    
    -- Simplified obstacle categories
    coalesce(obstacle_stationary_cd, -1) as obstacle_stationary_cd,
    
    coalesce(obstacle_moving_cd, -1) as obstacle_moving_cd,

    -- Temporal context
    accident_year,
    
    month,
    sin(2 * 3.141592653589793 * month / 12) as month_sin,
    cos(2 * 3.141592653589793 * month / 12) as month_cos,
    
    day_of_week,
    sin(2 * 3.141592653589793 * day_of_week / 7) as dow_sin,
    cos(2 * 3.141592653589793 * day_of_week / 7) as dow_cos,

    is_weekend,
    hour,
    sin(2 * 3.141592653589793 * hour / 24) as hour_sin,
    cos(2 * 3.141592653589793 * hour / 24) as hour_cos,
    
    coalesce(time_of_day_bucket_cd, -1) as time_of_day_bucket_cd,

    -- Spatial context
    department,
    latitude,
    longitude,

    -- Combined risk features
    case 
      when age_group_cd=1 AND has_helmet=0 then 1
      else 0
    end as youth_no_helmet

  from {{ ref('fct_accidents_hr') }}

)

select *
from selected
order by accident_year desc