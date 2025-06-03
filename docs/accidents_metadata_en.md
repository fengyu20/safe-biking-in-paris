
## Section CHARACTERISTICS

* **Num\_Acc**
  Accident identifier number.

* **jour**
  Day of the accident.

* **mois**
  Month of the accident.

* **an**
  Year of the accident.

* **hrmn**
  Hour and minute of the accident.

* **lum**
  Light: lighting conditions in which the accident occurred:
  1 – Full daylight
  2 – Twilight or dawn
  3 – Night without public lighting
  4 – Night with public lighting off
  5 – Night with public lighting on

* **dep**
  Department: INSEE code (National Institute of Statistics and Economic Studies) of the department
  (2A – Corse-du-Sud; 2B – Haute-Corse).

* **com**
  Commune: INSEE code of the commune, composed of the department code followed by three digits.

* **agg**
  Location:
  1 – Outside urban area
  2 – Within urban area

* **int**
  Intersection type:
  1 – Not at an intersection
  2 – Cross intersection (X)
  3 – T-intersection
  4 – Y-intersection
  5 – Intersection with more than four branches
  6 – Roundabout
  7 – Square
  8 – Level crossing
  9 – Other intersection

* **atm**
  Atmospheric conditions:
  -1 – Not specified
  1 – Normal
  2 – Light rain
  3 – Heavy rain
  4 – Snow or hail
  5 – Fog or smoke
  6 – Strong wind or storm
  7 – Glare
  8 – Overcast
  9 – Other

* **col**
  Type of collision:
  -1 – Not specified
  1 – Two vehicles – head-on
  2 – Two vehicles – rear-end
  3 – Two vehicles – side
  4 – Three or more vehicles – chain collision
  5 – Three or more vehicles – multiple collisions
  6 – Other collision
  7 – No collision

* **adr**
  Postal address: recorded for accidents occurring within urban areas.

* **lat**
  Latitude.

* **long**
  Longitude.

---

## Section LOCATIONS

* **Num\_Acc**
  Accident identifier (same as in the CHARACTERISTICS file).

* **catr**
  Road category:
  1 – Motorway
  2 – National road
  3 – Departmental road
  4 – Communal road
  5 – Outside the public network
  6 – Public parking area
  7 – Metropolitan urban roads
  9 – Other

* **voie**
  Road number.

* **V1**
  Numeric index of the road number (e.g. for “2 bis”, “3 ter”, etc.).

* **V2**
  Alphanumeric suffix of the road number.

* **circ**
  Traffic regime:
  -1 – Not specified
  1 – One-way
  2 – Two-way
  3 – Separated carriageways
  4 – Variable-use lanes

* **nbv**
  Total number of traffic lanes.

* **vosp**
  Reserved way indicator (regardless of whether the accident occurred on it):
  -1 – Not specified
  0 – Not applicable
  1 – Cycle path
  2 – Cycle lane
  3 – Reserved lane

* **prof**
  Longitudinal profile of the road at the accident location:
  -1 – Not specified
  1 – Level
  2 – Uphill
  3 – Hillcrest
  4 – Hillbottom

* **pr**
  Reference point number (up-stream marker). A value of -1 means not specified.

* **pr1**
  Distance in meters from the reference point (from the up-stream marker). A value of -1 means not specified.

* **plan**
  Horizontal alignment:
  -1 – Not specified
  1 – Straight section
  2 – Curve to the left
  3 – Curve to the right
  4 – S-bend

* **lartpc**
  Width of the central median (in meters), if present.

* **larrout**
  Width of the roadway available to vehicles (in meters), excluding emergency lanes, medians and parking spaces.

* **surf**
  Road surface condition:
  -1 – Not specified
  1 – Normal
  2 – Wet
  3 – Puddles
  4 – Flooded
  5 – Snow-covered
  6 – Mud
  7 – Icy
  8 – Greasy or oily
  9 – Other

* **infra**
  Infrastructure / development:
  -1 – Not specified
  0 – None
  1 – Underground tunnel
  2 – Bridge or overpass
  3 – Slip road or ramp
  4 – Level crossing (railway)
  5 – Modified intersection
  6 – Pedestrian zone
  7 – Toll area
  8 – Roadworks
  9 – Other

* **situ**
  Accident location relative to carriageway:
  -1 – Not specified
  0 – None
  1 – On carriageway
  2 – On emergency lane
  3 – On shoulder
  4 – On sidewalk
  5 – On cycle path
  6 – On other special lane
  8 – Other

* **vma**
  Posted speed limit at the location and time of the accident.

---

## Section VEHICLES

* **Num\_Acc**
  Accident identifier (same as in the CHARACTERISTICS file).

* **id\_vehicule**
  Unique numeric identifier for each vehicle (assigned to all occupants and to pedestrians struck by that vehicle).

* **Num\_Veh**
  Vehicle identifier (alphanumeric).

* **senc**
  Direction of travel:
  -1 – Not specified
  0 – Unknown
  1 – Increasing PK, PR or address number
  2 – Decreasing PK, PR or address number
  3 – No reference marker

* **catv**
  Vehicle category:
  00 – Indeterminable
  01 – Bicycle
  02 – Moped < 50 cm³
  03 – Light quadricycle (formerly “voiturette or motorized tricycle”)
  04 – (unused since 2006)
  05 – (unused since 2006)
  06 – (unused since 2006)
  07 – Passenger car alone
  08 – (unused since 2006)
  09 – (unused since 2006)
  10 – Light goods vehicle (1.5 T ≤ GVW ≤ 3.5 T) alone
  11 – (unused since 2006)
  12 – (unused since 2006)
  13 – Medium goods vehicle (3.5 T < GVW ≤ 7.5 T) alone
  14 – Heavy goods vehicle (GVW > 7.5 T) alone
  15 – Heavy goods vehicle + trailer
  16 – Tractor unit alone
  17 – Tractor unit + semi-trailer
  18 – (unused since 2006)
  19 – (unused since 2006)
  20 – Special machinery
  21 – Agricultural tractor
  30 – Scooter < 50 cm³
  31 – Motorcycle > 50 cm³ and ≤ 125 cm³
  32 – Scooter > 50 cm³ and ≤ 125 cm³
  33 – Motorcycle > 125 cm³
  34 – Scooter > 125 cm³
  35 – Light quad ≤ 50 cm³ (non-enclosed)
  36 – Heavy quad > 50 cm³ (non-enclosed)
  37 – City bus
  38 – Coach
  39 – Train
  40 – Tramway
  41 – Three-wheeled vehicle ≤ 50 cm³
  42 – Three-wheeled vehicle > 50 cm³ and ≤ 125 cm³
  43 – Three-wheeled vehicle > 125 cm³
  50 – Electrically assisted personal transport (motorized)
  60 – Electrically assisted personal transport (non-motorized)
  80 – Electrically assisted bicycle
  99 – Other vehicle

* **obs**
  Fixed obstacle struck:
  -1 – Not specified
  0 – Not applicable
  1 – Parked vehicle
  2 – Tree
  3 – Metal guardrail
  4 – Concrete barrier
  5 – Other barrier
  6 – Building, wall, bridge pier
  7 – Signpost or emergency call box
  8 – Pole
  9 – Street furniture
  10 – Parapet
  11 – Island or refuge
  12 – Curb
  13 – Ditch, embankment, rock face
  14 – Other fixed obstacle on roadway
  15 – Other fixed obstacle on sidewalk or shoulder
  16 – Run-off without obstacle
  17 – Culvert headwall

* **obsm**
  Mobile obstacle struck:
  -1 – Not specified
  0 – None
  1 – Pedestrian
  2 – Vehicle
  4 – Rail vehicle
  5 – Domestic animal
  6 – Wild animal
  9 – Other

* **choc**
  Initial point of impact:
  -1 – Not specified
  0 – None
  1 – Front
  2 – Front-right
  3 – Front-left
  4 – Rear
  5 – Rear-right
  6 – Rear-left
  7 – Right side
  8 – Left side
  9 – Multiple impacts (rollover)

* **manv**
  Main maneuver before the accident:
  -1 – Not specified
  0 – Unknown
  1 – No change of direction
  2 – Same direction, same lane
  3 – Between two lanes
  4 – Reversing
  5 – Against traffic
  6 – Crossing the median
  7 – In bus lane, same direction
  8 – In bus lane, opposite direction
  9 – Merging
  10 – U-turn on carriageway
  11 – Changing lane to the left
  12 – Changing lane to the right
  13 – Swerving left
  14 – Swerving right
  15 – Turning left
  16 – Turning right
  17 – Overtaking on the left
  18 – Overtaking on the right
  19 – Crossing the road
  20 – Parking maneuver
  21 – Evasive maneuver
  22 – Opening door
  23 – Stopped (except parking)
  24 – Parked (with occupants)
  25 – Driving on sidewalk
  26 – Other maneuver

* **motor**
  Motorization type:
  -1 – Not specified
  0 – Unknown
  1 – Hydrocarbon (fuel)
  2 – Electric hybrid
  3 – Electric
  4 – Hydrogen
  5 – Human
  6 – Other

* **occutc**
  Number of occupants in the public transport vehicle.

---

## Section USERS

* **Num\_Acc**
  Accident identifier (same as in the CHARACTERISTICS file).

* **id\_usager**
  Unique numeric identifier of the user (including pedestrians attached to the vehicles that struck them).

* **id\_vehicule**
  Unique numeric identifier of the vehicle in which the user was (or to which the pedestrian is attached).

* **num\_Veh**
  Alphanumeric vehicle identifier.

* **place**
  Position of the user in the vehicle at the time of the accident (10 – Pedestrian, not applicable).

* **catu**
  User category:
  1 – Driver
  2 – Passenger
  3 – Pedestrian

* **grav**
  Severity of the user’s injury:
  1 – Unharmed
  2 – Fatality
  3 – Hospitalized injury
  4 – Minor injury

* **sexe**
  User’s sex:
  1 – Male
  2 – Female

* **An\_nais**
  User’s year of birth.

* **trajet**
  Purpose of trip at the time of the accident:
  -1 – Not specified
  0 – Not specified
  1 – Home–work
  2 – Home–school
  3 – Shopping
  4 – Professional use
  5 – Leisure
  9 – Other

**From 2019 onward**, safety equipment is recorded as use (up to three items per user), rather than separate existence and use indicators:

* **secu1**, **secu2**, **secu3**
  Indicates presence and use of safety equipment (up to three entries):
  -1 – Not specified
  0 – No equipment
  1 – Seatbelt
  2 – Helmet
  3 – Child restraint device
  4 – Reflective vest
  5 – Airbag (for 2- or 3-wheelers)
  6 – Gloves (for 2- or 3-wheelers)
  7 – Gloves + airbag (for 2- or 3-wheelers)
  8 – Indeterminable
  9 – Other

* **locp**
  Pedestrian location:
  -1 – Not specified
  0 – Not applicable
  1 – On carriageway, more than 50 m from crosswalk
  2 – On carriageway, within 50 m of crosswalk
  3 – On crosswalk without traffic lights
  4 – On crosswalk with traffic lights
  5 – On sidewalk
  6 – On shoulder
  7 – On refuge or emergency lane
  8 – On service road
  9 – Unknown

* **actp**
  Pedestrian action:
  -1 – Not specified
  0 – Not applicable or none
  1 – Walking in direction of striking vehicle
  2 – Walking opposite direction of striking vehicle
  3 – Crossing
  4 – Hidden (masked)
  5 – Playing or running
  6 – With an animal
  9 – Other
  A – Boarding or alighting from vehicle
  B – Unknown

* **etatp**
  Indicates whether the pedestrian was alone:
  -1 – Not specified
  1 – Alone
  2 – Accompanied
  3 – In a group
