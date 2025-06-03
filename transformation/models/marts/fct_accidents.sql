{{ config(
    materialized = 'table',
    alias        = 'fct_accidents'
) }}


{# ------------------------------------------------------------------------
# 1) ACCIDENTS + LOCATIONS  (1 row per accident)
# --------------------------------------------------------------------- #}
with accidents_geo as (

  select
    /* ------------------------------------------------ Accident identifiers */
    c.num_acc                                                     as accident_id,

    /* ------------------------------------------------- Calendar / timing */
    c.an                                                          as accident_year,
    c.jour                                                        as day,
    c.mois                                                        as month,
    date(c.an, c.mois, c.jour)                                    as accident_date,
    /*   BigQuery: 1 = Sunday … 7 = Saturday                                              */
    extract(dayofweek from date(c.an,c.mois,c.jour))              as day_of_week,
    if(extract(dayofweek from date(c.an,c.mois,c.jour)) in (1,7), 1, 0) as is_weekend_flg,

    /* hh:mm stored as STRING(4) → TIME, then buckets                              */
    c.hrmn                                                       as time_of_day,
    extract(hour   from c.hrmn)                                  as hour,
    extract(minute from c.hrmn)                                  as minute,
    case
      when extract(hour from c.hrmn) between  6 and  9 then 1  -- morning peak
      when extract(hour from c.hrmn) between 17 and 20 then 2  -- evening peak
      when extract(hour from c.hrmn) >= 22 or extract(hour from c.hrmn) < 5 then 3 -- night
      else                                                       0  -- off‑peak
    end                                                          as time_of_day_bucket_cd,

    /* ----------------------------------------------------- Light conditions */
    /* lum  1 – Full daylight | 2 – Twilight / dawn | 3 – Night, no lighting   */
    /*      4 – Night, lighting OFF       | 5 – Night, lighting ON             */
    c.lum                                                        as light_condition,

    /* -------------------------------------------------- Weather conditions */
    /* atm  -1 – Not specified | 1 – Normal | 2 – Light rain | 3 – Heavy rain  */
    /*      4 – Snow / hail | 5 – Fog / smoke | 6 – Strong wind / storm        */
    /*      7 – Glare | 8 – Overcast | 9 – Other                               */
    c.atm                                                        as weather_condition,

    /* -------------------------------------------------- Collision pattern */
    /* col  -1 – Not specified | 1 – Two veh. head‑on | 2 – Two veh. rear‑end  */
    /*      3 – Two veh. side | 4 – ≥3 veh. chain | 5 – ≥3 veh. multiple       */
    /*      6 – Other collision | 7 – No collision                             */
    c.col                                                        as collision_type,

    /* ------------------------------------------------------- Geo / address */
    c.dep                                                        as department,         -- INSEE dep code
    c.com                                                        as municipality_code,  -- INSEE commune code

    /* agg  1 – Outside urban area | 2 – Within urban area                      */
    cast(c.agg as int64)                                         as within_urban,

    /* int  1 – Not at intersection | 2 – X | 3 – T | 4 – Y | 5 – >4 branches  */
    /*      6 – Roundabout | 7 – Square | 8 – Level crossing | 9 – Other       */
    c.intersection                                               as intersection_type,

    c.adr                                                        as address,
    c.latitude                                                   as latitude,
    c.longitude                                                  as longitude,
    c.geo                                                        as geom,

    /* ---------------------------------------------------- Road geometry */
    /* catr 1 – Motorway | 2 – National | 3 – Departmental | 4 – Communal      */
    /*      5 – Outside public network | 6 – Public parking | 7 – Urban roads  */
    l.catr                                                       as road_category_cd,
    l.voie                                                       as main_road_number,   -- "voie" in meta‑data
    l.v2                                                         as secondary_road_suffix, -- suffix ("bis", "ter", …)

    /* circ  -1 – Not spec | 1 – One‑way | 2 – Two‑way | 3 – Separated carriageways | 4 – Variable‑use */
    l.circ                                                       as circulation_type_cd,

    l.nbv                                                        as number_of_lanes,
    l.vosp                                                       as public_transport_lane_cd,

    /* prof  -1 – Not spec | 1 – Level | 2 – Uphill | 3 – Crest | 4 – Bottom  */
    l.prof                                                       as long_profile_cd,

    l.pr                                                         as reference_pr,
    l.pr1                                                        as reference_pr1,

    /* plan  -1 – Not spec | 1 – Straight | 2 – Curve left | 3 – Curve right | 4 – S‑bend */
    l.plan                                                       as planimetry_cd,

    l.lartpc                                                     as median_width_m,
    l.larrout                                                    as roadway_width_m,

    /* surf  -1 – Not specified 1 – Normal 2 – Wet 3 – Puddles 4 – Flooded 5 – Snow-covered 6 – Mud 7 – Icy 8 – Greasy or oily 9 – Other */
    l.surf                                                       as surface_condition_cd,

    /* infra  -1 – Not spec | 0 – None | 1 – Tunnel | 2 – Bridge | …           */
    l.infra                                                      as infrastructure_cd,

    /* situ  -1 – Not spec | 0 – None | 1 – On carriageway | …                 */
    l.situ                                                       as situation_cd,

    l.vma                                                        as speed_limit_kmh

  from {{ ref('stg_caract') }} c
  join {{ ref('stg_lieux')  }} l using (num_acc)
),

{# ------------------------------------------------------------------------
# 2) VEHICLES  (1 row per vehicle)
# --------------------------------------------------------------------- #}
vehicles as (

  select
    num_acc                    as accident_id,
    id_vehicule                as vehicle_id,
    num_veh                    as vehicle_number,

    /* catv — see exhaustive list in meta‑data                              */
    catv                       as vehicle_category_cd,

    /* senc  -1 – Not spec | 0 – Unknown | 1 – Increasing PK | 2 – Decreasing PK | 3 – No marker */
    senc                       as travel_direction_cd,

    obs                        as obstacle_stationary_cd,
    obsm                       as obstacle_moving_cd,
    choc                       as impact_point_cd,
    manv                       as manoeuvre_cd,

    /* motor  -1 – Not spec | 0 – Unknown | 1 – Hydrocarbon | 2 – Hybrid | 3 – Electric | 4 – Hydrogen | 5 – Human | 6 – Other */
    motor                      as motor_type_cd,

    /* occutc – only filled for buses / coaches (public transport)           */
    occutc                     as occupant_count

  from {{ ref('stg_vehicules') }}
),

{# ------------------------------------------------------------------------
# 3) USERS  (drivers & passengers only)
# --------------------------------------------------------------------- #}
users as (

  select
    num_acc                    as accident_id,
    id_vehicule                as vehicle_id,
    id_usager                  as user_id,
    num_veh                    as vehicle_number,

    /* catu 1 – Driver | 2 – Passenger                                       */
    catu                       as user_role_cd,

    /* grav 1 – Unharmed | 2 – Fatality | 3 – Hospitalised | 4 – Minor       */
    grav                       as severity_cd,

    /* sexe 1 – Male | 2 – Female                                            */
    sexe                       as gender_cd,

    an_nais                    as birth_year,
    trajet                     as trip_purpose_cd,

    /* ----------------------- Safety equipment flags (post‑2019 coding) */
    if(secu1 in (2) or secu2 in (2) or secu3 in (2), 1, 0)  as helmet_flg,
    if(secu1 in (1) or secu2 in (1) or secu3 in (1), 1, 0)  as seatbelt_flg,
    if(secu1 in (3) or secu2 in (3) or secu3 in (3), 1, 0)  as child_rst_flg,

    secu1, secu2, secu3,

    /* Pedestrian‑specific fields retained for completeness                   */
    locp                       as pedestrian_location_cd,
    actp                       as pedestrian_action_cd,
    etatp                      as pedestrian_state_cd,

    place                      as seat_position_cd

  from {{ ref('stg_usagers') }}
  where catu in (1, 2)      -- exclude pedestrians (catu = 3)
),

{# ------------------------------------------------------------------------
# 4) Accident‑level counts (helpers)                                         #}
accident_vehicle_counts as (
  select accident_id, count(distinct vehicle_id) as vehicles_in_accident
  from vehicles group by 1
),
accident_user_counts as (
  select accident_id, count(distinct user_id) as users_in_accident
  from users group by 1
)

{# ------------------------------------------------------------------------
# 5) FINAL SELECT  (one line per user × vehicle × accident)                 #}
select
  /* ------------------------------ Identifiers */
  u.user_id,
  u.accident_id,
  u.vehicle_id,

  /* ------------------------------ User dimensions */
  u.user_role_cd,
  u.severity_cd,
  u.gender_cd,
  u.birth_year,
  case
    when u.birth_year is null                                     then null
    when u.birth_year between 1901 and a.accident_year            and (a.accident_year - u.birth_year) <= 120
      then cast(a.accident_year - u.birth_year as int64)
    else null
  end                                                             as age,
  case
    when u.birth_year is null                                     then null
    when u.birth_year between 1901 and a.accident_year            and (a.accident_year - u.birth_year) <= 120 then
      case
        when (a.accident_year - u.birth_year) < 18                then 0  -- 0‑17
        when (a.accident_year - u.birth_year) < 35                then 1  -- 18‑34
        when (a.accident_year - u.birth_year) < 65                then 2  -- 35‑64
        else                                                          3  -- 65+
      end
    else null
  end                                                             as age_band_cd,
  u.trip_purpose_cd,
  u.helmet_flg,
  u.seatbelt_flg,
  u.child_rst_flg,
  u.secu1, u.secu2, u.secu3,
  u.pedestrian_location_cd,
  u.pedestrian_action_cd,
  u.pedestrian_state_cd,
  u.seat_position_cd,

  /* ------------------------------ Vehicle dimensions */
  v.vehicle_number,
  v.vehicle_category_cd,
  v.travel_direction_cd,
  v.obstacle_stationary_cd,
  v.obstacle_moving_cd,
  v.impact_point_cd,
  v.manoeuvre_cd,
  v.motor_type_cd,
  v.occupant_count,

  /* ------------------------------ Accident / road dimensions */
  a.accident_year,
  a.accident_date,
  a.day_of_week,
  a.is_weekend_flg,
  a.hour,
  a.minute,
  a.time_of_day_bucket_cd,
  a.light_condition                         as light_condition_grp_cd,
  a.weather_condition                       as weather_condition_grp_cd,
  a.collision_type                          as collision_group_cd,
  a.within_urban                            as within_urban_cd,
  a.intersection_type                       as intersection_type_cd,
  a.department,
  a.municipality_code,
  a.road_category_cd,
  a.circulation_type_cd,
  a.number_of_lanes,
  a.public_transport_lane_cd,
  a.long_profile_cd,
  a.planimetry_cd,
  a.median_width_m,
  a.roadway_width_m,
  a.surface_condition_cd,
  a.infrastructure_cd,
  a.situation_cd,
  a.speed_limit_kmh,
  a.latitude,
  a.longitude,

  /* ------------------------------ Aggregate controls */
  avc.vehicles_in_accident,
  auc.users_in_accident

from users u
left join vehicles                v  using (accident_id, vehicle_id)
left join accidents_geo           a  using (accident_id)
left join accident_vehicle_counts avc using (accident_id)
left join accident_user_counts    auc using (accident_id)
