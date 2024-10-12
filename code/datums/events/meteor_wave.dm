// TODO(rufus): disabled event (unticked from .dme), unfair and round-ending.
//   Ah, meteors, the classic of SS13, the event that started it all.
//   Meteors are cool as a round-griefing final event, but right now they don't give
//   crew enough time to react. If there are no engineers or setting up shields on
//   some map is not a common practice (e.g. Frotier when it was singulo-engine only),
//   the shift is basically forcibly ended by this event. Even if engineers are there,
//   unless the shields are already set up, they can't really do anything about the announcement.
//   Consider giving crew more warm-up time to get ready for meteors. Counter the potential
//   "well, they'll just set up shields and forget about it" with varying levels of severity.
//   Review meteor types, detection, counteraction systems, potential machinery upgrades and
//   orderable stuff. Basically make this into an experience with multiple paths to choose from
//   rather than a flat shield check with two outcomes, ignore or round end.
//   Keeping this disabled until at the very least the warm-up time is adjusted properly.
/datum/event/meteor_wave_base
	id = "meteor_wave_base"
	name = "Meteor Wave Incoming"
	description = "A group of meteorites is approaching the station"

	mtth = 2.5 HOURS
	difficulty = 80

	blacklisted_maps = list(/datum/map/polar)

	options = newlist(
		/datum/event_option/meteor_wave_option {
			id = "option_moderate";
			name = "Moderate Level";
			description = "";
			weight = 80;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION_R;
			severity = EVENT_LEVEL_MODERATE;
			event_id = "meteor_wave";
		},
		/datum/event_option/meteor_wave_option {
			id = "option_major";
			name = "Major Level";
			description = "";
			weight = 20;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			severity = EVENT_LEVEL_MAJOR;
			event_id = "meteor_wave";
		}
	)

/datum/event/meteor_wave_base/check_conditions()
	. = SSevents.evars["meteor_wave_running"] != TRUE

/datum/event/meteor_wave_base/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (15 MINUTES))
	. = max(1 HOUR, .)

/datum/event_option/meteor_wave_option
	var/severity = EVENT_LEVEL_MODERATE

/datum/event_option/meteor_wave_option/on_choose()
	SSevents.evars["meteor_wave_severity"] = severity

/datum/event/meteor_wave
	id = "meteor_wave"
	name = "Meteor Wave"

	hide = TRUE
	triggered_only = TRUE

	var/severity = EVENT_LEVEL_MODERATE
	var/alarmWhen   = 30
	var/next_meteor = 40
	var/waves = 1
	var/start_side
	var/next_meteor_lower = 10
	var/next_meteor_upper = 20
	var/end = 0
	var/activeFor = 0
	var/list/affecting_z = list()

/datum/event/meteor_wave/New()
	. = ..()

	add_think_ctx("end", CALLBACK(src, nameof(.proc/end)), 0)

/datum/event/meteor_wave/on_fire()
	SSevents.evars["meteor_wave_running"] = TRUE
	affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)
	severity = SSevents.evars["meteor_wave_severity"]

	waves = 0
	for(var/n in 1 to severity)
		waves += rand(5, 15)

	start_side = pick(GLOB.cardinal)
	end = worst_case_end()

	announce()

	set_next_think_ctx("end", world.time + end)
	set_next_think(world.time)

/datum/event/meteor_wave/think()
	activeFor += 1
	// Begin sending the alarm signals to shield diffusers so the field is already regenerated (if it exists) by the time actual meteors start flying around.
	if(alarmWhen < activeFor)
		for(var/obj/machinery/shield_diffuser/SD in GLOB.machines)
			if(isStationLevel(SD.z))
				SD.meteor_alarm(10)

	if(waves && activeFor >= next_meteor)
		send_wave()

	set_next_think(world.time + 1 SECONDS)

/datum/event/meteor_wave/proc/send_wave()
	var/pick_side = prob(80) ? start_side : (prob(50) ? turn(start_side, 90) : turn(start_side, -90))
	spawn()
		spawn_meteors(get_wave_size(), get_meteors(), pick_side, pick(affecting_z))

	next_meteor += rand(next_meteor_lower, next_meteor_upper) / severity
	waves--

/datum/event/meteor_wave/proc/get_wave_size()
	return severity * rand(2,4)

/datum/event/meteor_wave/proc/announce()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_announcement.Announce(replacetext(GLOB.using_map.meteor_detected_message, "%STATION_NAME%", station_name()), "[station_name()] Sensor Array", new_sound = GLOB.using_map.meteor_detected_sound, zlevels = affecting_z)
		else
			command_announcement.Announce("The [station_name()] is now in a meteor shower.", "[station_name()] Sensor Array", zlevels = affecting_z)

/datum/event/meteor_wave/proc/end()
	set_next_think(0)
	SSevents.evars["meteor_wave_running"] = FALSE

	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			command_announcement.Announce("The [station_name()] has cleared the meteor storm.", "[station_name()] Sensor Array", zlevels = affecting_z)
		else
			command_announcement.Announce("The [station_name()] has cleared the meteor shower", "[station_name()] Sensor Array", zlevels = affecting_z)

/datum/event/meteor_wave/proc/worst_case_end()
	return 2 MINUTE + ((30 / severity) * waves) + (30 SECONDS)

/datum/event/meteor_wave/proc/get_meteors()
	switch(severity)
		if(EVENT_LEVEL_MAJOR)
			return meteors_major
		if(EVENT_LEVEL_MODERATE)
			return meteors_moderate
		else
			return meteors_minor

var/list/meteors_minor = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
)

var/list/meteors_moderate = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
	/obj/effect/meteor/emp        = 10,
)

var/list/meteors_major = list(
	/obj/effect/meteor/medium     = 80,
	/obj/effect/meteor/big        = 30,
	/obj/effect/meteor/dust       = 30,
	/obj/effect/meteor/irradiated = 30,
	/obj/effect/meteor/emp        = 30,
	/obj/effect/meteor/flaming    = 10,
	/obj/effect/meteor/golden     = 10,
	/obj/effect/meteor/silver     = 10,
	/obj/effect/meteor/tunguska   = 1,
)
