{{ config(
    materialized = 'table',
    alias        = 'fct_accident_causes'
) }}


with accidents as (
  select *
  from {{ ref('fct_accidents') }}
),

--------------------------------------------------------------------
-- 1)  FEATURE ENGINEERING
--------------------------------------------------------------------
features as (
  select 
    ------------------------------------------------------------------
    -- Identifiers 
    ------------------------------------------------------------------
    accident_id,
    user_id,
    vehicle_id,

    -- ===================================== TARGET ==================
    severity_cd,
    case when severity_cd in (2,3) then 1 else 0 end                  as is_severe_accident,

    -- ===================================== CYCLIST DEMOGRAPHICS ====
    age,
    age_group

    gender_cd,
    case gender_cd when 1 then 'male' when 2 then 'female' else 'unknown' end as gender,

    trip_purpose_cd,
    case trip_purpose_cd
      when 1 then 'commute'
      when 2 then 'school'
      when 3 then 'shopping'
      when 4 then 'work'
      when 5 then 'leisure'
      when 9 then 'other'
      else 'not_specified'
    end                                              as trip_purpose,

    helmet_flg                                           as has_helmet,

    -- ===================================== VEHICLE TYPE ============
    vehicle_category_cd,

    -- ===================================== TEMPORAL CONTEXT ========
    accident_date,
    accident_year,
    extract(month  from accident_date)                  as month,
    case extract(month from accident_date)
      when 12 then 'winter' when 1 then 'winter' when 2 then 'winter'
      when 3  then 'spring' when 4 then 'spring' when 5 then 'spring'
      when 6  then 'summer' when 7 then 'summer' when 8 then 'summer'
      else 'autumn'
    end                                              as season,

    day_of_week,
    case day_of_week when 1 then 'sun' when 2 then 'mon' when 3 then 'tue' when 4 then 'wed'
                     when 5 then 'thu' when 6 then 'fri' when 7 then 'sat' end as day_of_week_label,
    is_weekend_flg                                        as is_weekend,

    hour,
    minute,
    time_of_day_bucket_cd,
    case time_of_day_bucket_cd when 0 then 'off_peak' when 1 then 'morning_rush'
                               when 2 then 'evening_rush' when 3 then 'night' end as time_period,

    -- One hot encoding
    case when time_of_day_bucket_cd = 3 then 1 else 0 end            as is_night,

    -- ===================================== ENVIRONMENT ============
    light_condition_grp_cd,
    case light_condition_grp_cd
      when 1 then 'daylight'
      when 2 then 'twilight'
      when 3 then 'night_unlit'
      when 4 then 'night_lighting_off'
      when 5 then 'night_lit'
      else 'unknown'
    end                                              as lighting_condition,

    weather_condition_grp_cd,
    case weather_condition_grp_cd
      when 1 then 'clear'
      when 2 then 'light_rain'
      when 3 then 'heavy_rain'
      when 4 then 'snow_hail'
      when 5 then 'fog'
      when 6 then 'strong_wind'
      when 7 then 'glare'
      when 8 then 'overcast'
      when 9 then 'other'
      else 'not_specified'
    end                                              as weather_condition,

    surface_condition_cd,
    case surface_condition_cd
      when 1 then 'normal'
      when 2 then 'wet'
      when 3 then 'puddles'
      when 4 then 'flooded'
      when 5 then 'snow'
      when 6 then 'mud'
      when 7 then 'icy'
      when 8 then 'greasy'
      else 'other'
    end                                              as surface_condition,

    -- ===================================== LOCATION / INFRA =======
    within_urban_cd,
    /* meta‑data: 1 = outside, 2 = inside urban area */
    case within_urban_cd when 2 then 'urban' when 1 then 'rural' else 'unknown' end as area_type,

    intersection_type_cd,
    case intersection_type_cd
      when 1 then 'none'
      when 2 then 'cross'
      when 3 then 't_junction'
      when 4 then 'y_junction'
      when 5 then 'multi_branch'
      when 6 then 'roundabout'
      when 7 then 'square'
      when 8 then 'level_crossing'
      when 9 then 'other'
    end                                              as intersection_type,

    road_category_cd,
    case road_category_cd
      when 1 then 'motorway'
      when 2 then 'national'
      when 3 then 'departmental'
      when 4 then 'communal'
      when 5 then 'off_network'
      when 6 then 'parking'
      when 7 then 'urban_arterial'
      when 9 then 'other'
    end                                              as road_type,

    public_transport_lane_cd,
    case public_transport_lane_cd
      when 1 then 'cycle_path'
      when 2 then 'cycle_lane'
      when 3 then 'reserved_lane'
      else 'none'
    end                                              as cycle_infra_type,
    /* binary flag: 1 = no dedicated bike infra */
    case when public_transport_lane_cd in (1,2) then 0 else 1 end  as no_cycle_infra,

    infrastructure_cd,
    case infrastructure_cd
      when 0 then 'none'
      when 1 then 'tunnel'
      when 2 then 'bridge'
      when 3 then 'ramp'
      when 4 then 'level_crossing'
      when 5 then 'modified_intersection'
      when 6 then 'pedestrian_zone'
      when 7 then 'toll_area'
      when 8 then 'roadworks'
      when 9 then 'other'
      else 'not_specified'
    end                                              as special_infrastructure,

    long_profile_cd,
    case long_profile_cd when 1 then 'level' when 2 then 'uphill' when 3 then 'crest' when 4 then 'bottom' else 'unknown' end as road_gradient,

    planimetry_cd,
    case planimetry_cd when 1 then 'straight' when 2 then 'curve_left' when 3 then 'curve_right' when 4 then 's_bend' else 'unknown' end as road_curvature,

    number_of_lanes,
    case
      when number_of_lanes is null                        then 'unknown'
      when number_of_lanes <= 2                           then 'low'
      when number_of_lanes <= 4                           then 'medium'
      else 'high'
    end                                              as traffic_density,

    speed_limit_kmh,
    case
      when speed_limit_kmh is null                       then 'unknown'
      when speed_limit_kmh <= 30                         then '≤30'
      when speed_limit_kmh <= 50                         then '31‑50'
      when speed_limit_kmh <= 70                         then '51‑70'
      when speed_limit_kmh <= 90                         then '71‑90'
      else '≥91'
    end                                              as speed_zone,

    -- ===================================== COLLISION MECHANICS ====
    collision_group_cd,
    case collision_group_cd
      when 1 then 'head_on'
      when 2 then 'rear_end'
      when 3 then 'side'
      when 4 then 'chain'
      when 5 then 'multiple'
      when 6 then 'other'
      when 7 then 'none'
      else 'unknown'
    end                                              as collision_type,

    impact_point_cd,
    case impact_point_cd
      when 0 then 'none'
      when 1 then 'front'
      when 2 then 'front_right'
      when 3 then 'front_left'
      when 4 then 'rear'
      when 5 then 'rear_right'
      when 6 then 'rear_left'
      when 7 then 'right_side'
      when 8 then 'left_side'
      when 9 then 'multiple'
      else 'unknown'
    end                                              as impact_point,

    manoeuvre_cd,
    case manoeuvre_cd
      when 1  then 'straight'
      when 2  then 'same_dir_same_lane'
      when 11 then 'lane_change_left'
      when 12 then 'lane_change_right'
      when 15 then 'turn_left'
      when 16 then 'turn_right'
      when 17 then 'overtake_left'
      when 18 then 'overtake_right'
      when 19 then 'crossing'
      when 22 then 'door_open'
      else 'other'
    end                                              as cyclist_manoeuvre,

    obstacle_stationary_cd,
    case obstacle_stationary_cd
      when 0  then 'none'
      when 1  then 'parked_vehicle'
      when 2  then 'tree'
      when 6  then 'building_wall'
      when 8  then 'pole'
      when 9  then 'street_furniture'
      when 12 then 'curb'
      else 'other'
    end                                              as fixed_obstacle,

    obstacle_moving_cd,
    case obstacle_moving_cd
      when 0 then 'none'
      when 1 then 'pedestrian'
      when 2 then 'vehicle'
      when 4 then 'rail_vehicle'
      when 5 then 'domestic_animal'
      when 6 then 'wild_animal'
      else 'other'
    end                                              as moving_obstacle,

    -- ===================================== CONTEXTUAL COUNTS ======
    vehicles_in_accident,
    users_in_accident,
    case when vehicles_in_accident = 1 then 'single'
         when vehicles_in_accident = 2 then 'two'
         else 'multi' end                           as accident_complexity,

    -- ===================================== SPATIAL  ===============
    department,
    latitude,
    longitude,

    -- ===================================== DERIVED RISK FLAGS =====
    case when time_of_day_bucket_cd = 3 and light_condition_grp_cd in (3,4) then 1 else 0 end as night_poor_visibility,
    case when weather_condition_grp_cd in (2,3,4,5) and surface_condition_cd in (2,3,4,5,6,7) then 1 else 0 end as adverse_weather_surface,
    case when intersection_type_cd in (2,3,4,5) and manoeuvre_cd in (15,16,19) then 1 else 0 end as intersection_turning_risk,
    case when speed_limit_kmh > 50 and within_urban_cd = 2 then 1 else 0 end       as high_speed_urban

  from accidents
  where accident_year >= 2019
)

select *
from features
order by accident_date desc, accident_id
