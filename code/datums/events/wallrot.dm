// TODO(rufus): this event is quite harmless, but is too weak at the moment. Only one spot on the whole station will
//   be affected and the code to pick that spot is absolutely ancient (and adorably simplistic).
//   The harshness of this event has to be greatly increased.
//   Consider adding some sort of interactivity like early stages of wallrot that can be spotted beforehand,
//   maybe random types of wallrot similar to random types of mold in real life, with some especially dangerous
//   types rotting the wall to the point of breaking it under the pressure contrast between station and vacuum.
//   Keeping this enabled, but this needs a good rethink and a new implementation.
/datum/event/wallrot
	id = "wallrot"
	name = "Wallrot"
	description = "Dangerous fungi will appear on some walls destroying the walls"

	mtth = 2 HOURS
	difficulty = 25

/datum/event/wallrot/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)

/datum/event/wallrot/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Gardener"] * (15 MINUTES))
	. -= (SSevents.triggers.roles_count["Engineer"] * (15 MINUTES))
	. = max(1 HOUR, .)

/datum/event/wallrot/proc/announce()
	var/list/affecting_z = GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)

	command_announcement.Announce(
		"Harmful fungi detected on [station_name()]. Structures may be contaminated.",
		"Biohazard Alert",
		zlevels = affecting_z,
		new_sound = 'sound/AI/wallrotstart.ogg'
	)

/datum/event/wallrot/on_fire()
	set_next_think_ctx("announce", world.time + (rand(2, 5) MINUTES))

	spawn()
		var/turf/simulated/wall/center = null

		// TODO(rufus): just making a hundred attempts to find a single random spot to apply wallrot
		//   is quite a dumb bruteforce approach, but maybe it's not *that* bad of an idea?
		//   In any case, the code is ancient and needs to be updated.
		// 100 attempts
		for(var/i = 0, i < 100, i++)
			var/turf/candidate = locate(rand(1, world.maxx), rand(1, world.maxy), pick(GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			if(istype(candidate, /turf/simulated/wall))
				center = candidate
				break

		if(center)
			// Make sure at least one piece of wall rots!
			center.rot()

			// Have a chance to rot lots of other walls.
			var/rotcount = 0
			var/actual_severity = rand(5, 10)
			for(var/turf/simulated/wall/W in range(5, center))
				if(prob(50))
					W.rot()
					rotcount++

				// Only rot up to severity walls
				if(rotcount >= actual_severity)
					break
