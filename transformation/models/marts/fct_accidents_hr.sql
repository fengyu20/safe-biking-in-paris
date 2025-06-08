{{ config(
    materialized = 'table',
    alias        = 'fct_accidents_hr'
) }}

with base as (
  select *
  from {{ ref('fct_accidents') }}
)

select
  -- --------------------------------------------------------------------
  -- ORIGINAL IDENTIFIERS
  -- --------------------------------------------------------------------
  user_id,
  accident_id,
  vehicle_id,

  -- --------------------------------------------------------------------
  -- USER‑FRIENDLY CATEGORICAL LABELS (all mappings straight from meta‑data)
  -- --------------------------------------------------------------------
  /* ---------------------------------------------------- User role */
  user_role_cd,
  case user_role_cd
    when 1 then 'Driver'
    when 2 then 'Passenger'
    else 'Other'
  end                                             as user_role_label,

  /* ---------------------------------------------------- Injury severity */
  severity_cd,
  case severity_cd
    when 1 then 'Unharmed'
    when 2 then 'Fatality'
    when 3 then 'Hospitalized injury'
    when 4 then 'Minor injury'
    else 'Unknown'
  end                                             as severity_label,

  /* ---------------------------------------------------- Sex */
  gender_cd,
  case gender_cd
    when 1 then 'Male'
    when 2 then 'Female'
    else 'Unknown'
  end                                             as gender_label,

  -- --------------------------------------------------------------------
  -- AGE & TRIP PURPOSE
  -- --------------------------------------------------------------------
  birth_year,
  age,
  case
    when age is null or age < 0 or age > 110 then 'Invalid'
    when age < 13                           then 'Child'
    when age between 13 and 17         then 'Youth'
    when age between 18 and 34         then 'Young adult'
    when age between 35 and 49         then 'Mid adult'
    when age between 50 and 64         then 'Older adult'
    else                               'Senior'
  end                                             as age_group_label,

  case
    when age is null or age < 0 or age > 110 then -1
    when age < 13                           then 0
    when age between 13 and 17              then 1
    when age between 18 and 34              then 2
    when age between 35 and 49              then 3
    when age between 50 and 64              then 4
    else                                        5
  end as age_group_cd,

  trip_purpose_cd,
  case trip_purpose_cd
    when 1 then 'Home–work'
    when 2 then 'Home–school'
    when 3 then 'Shopping'
    when 4 then 'Professional use'
    when 5 then 'Leisure'
    when 9 then 'Other'
    else 'Not specified'
  end                                             as trip_purpose_label,

  -- --------------------------------------------------------------------
  -- SAFETY EQUIPMENT FLAGS (already 0/1 in base model)
  -- --------------------------------------------------------------------
  helmet_flg as has_helmet,
  case
    when helmet_flg = 1 then 'Wearing helmet'
    else 'No helmet'
  end                                             as helmet_label,
  seatbelt_flg,
  child_rst_flg,

  -- --------------------------------------------------------------------
  -- TEMPORAL ATTRIBUTES
  -- --------------------------------------------------------------------
  accident_date,
  day_of_week,
  case day_of_week
    when 1 then 'Sunday'
    when 2 then 'Monday'
    when 3 then 'Tuesday'
    when 4 then 'Wednesday'
    when 5 then 'Thursday'
    when 6 then 'Friday'
    when 7 then 'Saturday'
    else 'Unknown'
  end                                             as day_of_week_label,
  is_weekend_flg            as is_weekend,

  month,
  hour,
  minute,
  time_of_day_bucket_cd,
  case time_of_day_bucket_cd
    when 0 then 'Off‑peak'
    when 1 then 'Morning peak'
    when 2 then 'Evening peak'
    when 3 then 'Night'
    else 'Unknown'
  end                                             as time_of_day_label,

  -- --------------------------------------------------------------------
  -- LIGHT & WEATHER CONDITIONS
  -- --------------------------------------------------------------------
  light_condition_grp_cd,
  case light_condition_grp_cd
    when 1 then 'Full daylight'
    when 2 then 'Twilight / dawn'
    when 3 then 'Night – no lighting'
    when 4 then 'Night – lighting off'
    when 5 then 'Night – lighting on'
    else 'Unknown'
  end                                             as light_condition_label,

  weather_condition_grp_cd,
  case weather_condition_grp_cd
    when -1 then 'Not specified'
    when 0  then 'Not specified'      -- occasionally present in historical dumps
    when 1  then 'Normal'
    when 2  then 'Light rain'
    when 3  then 'Heavy rain'
    when 4  then 'Snow or hail'
    when 5  then 'Fog or smoke'
    when 6  then 'Strong wind / storm'
    when 7  then 'Glare'
    when 8  then 'Overcast'
    when 9  then 'Other'
    else 'Unknown'
  end                                             as weather_condition_label,

  case 
    when weather_condition_grp_cd in (2,3)             then 'Rain'
    when weather_condition_grp_cd in (4,5,6)           then 'Adverse'
    when weather_condition_grp_cd = 1                  then 'Clear'
    else                                                   'Other / Unknown'
  end                                                 as weather_condition_group,

  -- --------------------------------------------------------------------
  -- COLLISION PATTERN & LOCATION
  -- --------------------------------------------------------------------
  collision_group_cd,
  case collision_group_cd
    when -1 then 'Not specified'
    when 1 then 'Two vehicles – head‑on'
    when 2 then 'Two vehicles – rear‑end'
    when 3 then 'Two vehicles – side'
    when 4 then '≥3 vehicles – chain'
    when 5 then '≥3 vehicles – multiple'
    when 6 then 'Other collision'
    when 7 then 'No collision'
    else 'Unknown'
  end                                             as collision_type_label,

  case 
    when collision_group_cd in (1,2,3) then 'Two‑vehicle'
    when collision_group_cd in (4,5)   then 'Multi‑vehicle'
    when collision_group_cd = 6        then 'Other collision'
    when collision_group_cd = 7        then 'No collision'
    else                                   'Unknown'
  end                                             as collision_type_group,

  within_urban_cd,
  case within_urban_cd              -- ⚠ meta‑data: 1 = OUTSIDE, 2 = WITHIN
    when 1 then 'Outside urban area'
    when 2 then 'Within urban area'
    else 'Unknown'
  end                                             as urban_area_label,

  intersection_type_cd,
  case intersection_type_cd
    when 1 then 'Not at intersection'
    when 2 then 'Cross (X)'
    when 3 then 'T‑intersection'
    when 4 then 'Y‑intersection'
    when 5 then '> 4 branches'
    when 6 then 'Roundabout'
    when 7 then 'Square'
    when 8 then 'Level crossing'
    when 9 then 'Other'
    else 'Unknown'
  end                                             as intersection_type_label,

  -- --------------------------------------------------------------------
  -- DEPARTMENT (show human‑friendly names only for the 2A/2B Corsican edge‑case)
  -- --------------------------------------------------------------------
  department,
  case department
    when '2A' then 'Corse‑du‑Sud (2A)'
    when '2B' then 'Haute‑Corse (2B)'
    else department
  end                                             as department_label,

  -- --------------------------------------------------------------------
  -- ROAD & SURFACE
  -- --------------------------------------------------------------------
  road_category_cd,
  case road_category_cd
    when 1 then 'Motorway'
    when 2 then 'National road'
    when 3 then 'Departmental road'
    when 4 then 'Communal road'
    when 5 then 'Outside public network'
    when 6 then 'Public parking area'
    when 7 then 'Metropolitan urban road'
    when 9 then 'Other'
    else 'Unknown'
  end                                             as road_category_label,

  surface_condition_cd,
  case surface_condition_cd
    when -1 then 'Not specified'
    when 1  then 'Dry / Normal'
    when 2  then 'Wet'
    when 3  then 'Puddles'
    when 4  then 'Flooded'
    when 5  then 'Snow‑covered'
    when 6  then 'Mud'
    when 7  then 'Icy'
    when 8  then 'Greasy / Oily'
    when 9  then 'Other'
    else 'Unknown'
  end                                             as surface_condition_label,

  case 
    when surface_condition_cd = 1                    then 'Normal'
    when surface_condition_cd in (2,3,4)             then 'Water / Wet'
    when surface_condition_cd in (5,7)               then 'Snow / Ice'
    when surface_condition_cd in (6,8,9)             then 'Other hazard'
    else                                                 'Unknown'
  end                                             as surface_condition_group,

  -- --------------------------------------------------------------------
  -- VEHICLE CATEGORIES
  -- --------------------------------------------------------------------
  vehicle_category_cd,

  case vehicle_category_cd
    when 0  then 'Indeterminable'
    when 1  then 'Bicycle'
    when 2  then 'Moped < 50 cm³'
    when 3  then 'Light quadricycle'
    when 7  then 'Passenger car'
    when 10 then 'Light goods vehicle'
    when 13 then 'Medium goods vehicle'
    when 14 then 'Heavy goods vehicle'
    when 15 then 'HGV + trailer'
    when 20 then 'Special machinery'
    when 21 then 'Agricultural tractor'
    when 30 then 'Scooter < 50 cm³'
    when 31 then 'Motorcycle 50‑125 cm³'
    when 32 then 'Scooter 50‑125 cm³'
    when 33 then 'Motorcycle > 125 cm³'
    when 34 then 'Scooter > 125 cm³'
    when 35 then 'Light quad ≤ 50 cm³'
    when 36 then 'Heavy quad > 50 cm³'
    when 37 then 'City bus'
    when 38 then 'Coach'
    when 39 then 'Train'
    when 40 then 'Tramway'
    when 41 then 'Three‑wheeler ≤ 50 cm³'
    when 42 then 'Three‑wheeler 50‑125 cm³'
    when 43 then 'Three‑wheeler > 125 cm³'
    when 50 then 'E‑personal transport (motorized)'
    when 60 then 'E‑personal transport (non‑motorized)'
    when 80 then 'E‑bicycle'
    when 99 then 'Other vehicle'
    else 'Other / Unknown'
  end                                             as vehicle_category_label,


  -- --------------------------------------------------------------------
  -- IMPACT, ENGINE TYPE, ROAD INFRA‑DETAILS
  -- --------------------------------------------------------------------
  impact_point_cd,
  case impact_point_cd
    when -1 then 'Not specified'
    when 0  then 'None'
    when 1  then 'Front'
    when 2  then 'Front‑right'
    when 3  then 'Front‑left'
    when 4  then 'Rear'
    when 5  then 'Rear‑right'
    when 6  then 'Rear‑left'
    when 7  then 'Right side'
    when 8  then 'Left side'
    when 9  then 'Multiple / Rollover'
    else 'Unknown'
  end                                             as impact_point_label,

  motor_type_cd,
  case motor_type_cd
    when -1 then 'Not specified'
    when 0  then 'Unknown'
    when 1  then 'Hydrocarbon fuel'
    when 2  then 'Electric hybrid'
    when 3  then 'Electric'
    when 4  then 'Hydrogen'
    when 5  then 'Human'
    when 6  then 'Other'
    else 'Unknown'
  end                                             as motor_type_label,

  infrastructure_cd,
  case infrastructure_cd
    when -1 then 'Not specified'
    when 0  then 'None'
    when 1  then 'Underground tunnel'
    when 2  then 'Bridge / overpass'
    when 3  then 'Slip road / ramp'
    when 4  then 'Level crossing'
    when 5  then 'Modified intersection'
    when 6  then 'Pedestrian zone'
    when 7  then 'Toll area'
    when 8  then 'Roadworks'
    when 9  then 'Other'
    else 'Unknown'
  end                                             as infrastructure_label,

  long_profile_cd,
  case long_profile_cd
    when -1 then 'Not specified'
    when 1  then 'Level'
    when 2  then 'Uphill'
    when 3  then 'Hillcrest'
    when 4  then 'Hillbottom'
    else 'Unknown'
  end                                             as long_profile_label,

  planimetry_cd,
  case planimetry_cd
    when -1 then 'Not specified'
    when 1  then 'Straight'
    when 2  then 'Curve left'
    when 3  then 'Curve right'
    when 4  then 'S‑bend'
    else 'Unknown'
  end                                             as planimetry_label,


  travel_direction_cd,
  obstacle_stationary_cd,
  obstacle_moving_cd,
  manoeuvre_cd,
  circulation_type_cd,
  number_of_lanes,
  public_transport_lane_cd,

  latitude,
  longitude,
  geom,
  accident_year,
  speed_limit_kmh,
  vehicles_in_accident,
  users_in_accident

from base
