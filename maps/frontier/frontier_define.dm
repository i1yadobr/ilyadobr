
/datum/map/frontier
	name = "Frontier"
	full_name = "NSS Frontier"
	path = "frontier"

	lobby_icon = "icons/misc/lobby_splashes/eos_frontier.png"

	shuttle_types = list(
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod3,
		/datum/shuttle/autodock/ferry/escape_pod/escape_pod5,
		/datum/shuttle/autodock/ferry/supply/drone,
		/datum/shuttle/autodock/ferry/elevator,
		/datum/shuttle/autodock/multi/antag/mining,
		/datum/shuttle/autodock/ferry/research,
		/datum/shuttle/autodock/ferry/engie,
		/datum/shuttle/autodock/ferry/mining,
		/datum/shuttle/autodock/multi/antag/rescue,
		/datum/shuttle/autodock/ferry/emergency/centcom,
		/datum/shuttle/autodock/ferry/administration,
		/datum/shuttle/autodock/multi/antag/syndicate,
		/datum/shuttle/autodock/multi/antag/elite_syndicate,
		/datum/shuttle/autodock/ferry/deathsquad,
		/datum/shuttle/autodock/multi/antag/merchant,
		/datum/shuttle/autodock/multi/antag/skipjack,
	)

	map_levels = list(
		new /datum/space_level/frontier_1,
		new /datum/space_level/frontier_2,
		new /datum/space_level/null_space,
		new /datum/space_level/telecomms,
		new /datum/space_level/construction_site,
		new /datum/space_level/snow_asteroid,
		new /datum/space_level/derelict,
		new /datum/space_level/bearcat_1,
		new /datum/space_level/bearcat_2,
		new /datum/space_level/jungle_level,
		new /datum/space_level/old_restaurant,
		new /datum/space_level/sensor_array,
		new /datum/space_level/science_ship_1,
		new /datum/space_level/science_ship_2
	)

	station_name  = "NSS Frontier"
	station_short = "Frontier"
	dock_name     = "NAS Crescent"
	boss_name     = "Central Command"
	boss_short    = "Centcomm"
	company_name  = "NanoTrasen"
	company_short = "NT"
	system_name   = "Arcturus"

	emergency_shuttle_docked_message = "The Emergency Shuttle has docked with the station. You have approximately %ETD% to board the Emergency Shuttle."
	emergency_shuttle_leaving_dock = "The Emergency Shuttle has left the station. Estimate %ETA% until the shuttle docks at %dock_name%."
	emergency_shuttle_called_message = "An emergency evacuation shuttle has been called. It will arrive in approximately %ETA%"
	emergency_shuttle_recall_message = "The emergency shuttle has been recalled."

	evac_controller_type = /datum/evacuation_controller/shuttle

	station_networks = list(
		NETWORK_CIVILIAN_EAST,
		NETWORK_CIVILIAN_WEST,
		NETWORK_COMMAND,
		NETWORK_ENGINE,
		NETWORK_ENGINEERING,
		NETWORK_ENGINEERING_OUTPOST,
		NETWORK_EXODUS,
		NETWORK_MAINTENANCE,
		NETWORK_MEDICAL,
		NETWORK_MINE,
		NETWORK_RESEARCH,
		NETWORK_RESEARCH_OUTPOST,
		NETWORK_ROBOTS,
		NETWORK_PRISON,
		NETWORK_SECURITY,
		NETWORK_ALARM_ATMOS,
		NETWORK_ALARM_CAMERA,
		NETWORK_ALARM_FIRE,
		NETWORK_ALARM_MOTION,
		NETWORK_ALARM_POWER,
		NETWORK_THUNDER,
		NETWORK_TELECOM,
		NETWORK_MASTER
	)

	post_round_safe_areas = list (
		/area/centcom,
		/area/shuttle/escape/centcom,
		/area/shuttle/escape_pod1,
		/area/shuttle/escape_pod2,
		/area/shuttle/escape_pod3,
		/area/shuttle/escape_pod5,
		/area/shuttle/transport/centcom,
		/area/shuttle/administration/,
		/area/shuttle/specops/centcom,
	)

	job_positions_overrides = list(
		/datum/job/bartender = 1,
		/datum/job/hydro = 1,
		/datum/job/iaa = 1,
		/datum/job/lawyer = 1,
		/datum/job/engineer = 3,
		/datum/job/doctor = 3,
		/datum/job/chemist = 1,
		/datum/job/paramedic = 1,
		/datum/job/scientist = 4,
		/datum/job/roboticist = 1,
		/datum/job/officer = 3
	)
