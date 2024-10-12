// TODO(rufus): while xenomorphs do need some refactoring, this is fine to keep enabled and as is for now.
//   Consider making facehugger subspecies that apply random effects to the victim, have varying
//   incubation time and apply random complications instead of just allowing any sort-of-medical
//   person to cut out the embryo and be done with the event. See the original Alien movie series
//   for some inspiration. Aliens are absolute and ultimate murder species with evolutionary
//   measures protecting them with unmatched efficiency until the specimen is fully grown.
//   It was definitely *not* possible to just cut out the embryo.
//   However, these ideas might need a broad alien rework first.
/datum/event/stray_facehugger
	id = "stray_facehugger"
	name = "Stray Facehugger"
	description = "Facehugger will appear somewhere in the technical rooms"

	mtth = 3 HOURS
	difficulty = 60
	fire_only_once = TRUE

/datum/event/stray_facehugger/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Security"] * (20 MINUTES))
	. = max(1 HOUR, .)

/datum/event/stray_facehugger/on_fire()
	var/turf/T = pick_subarea_turf(/area/maintenance, list(/proc/is_station_turf, /proc/not_turf_contains_dense_objects))

	if(!T)
		log_debug("Facehugger event failed to find a proper spawn point. Aborting.")
		return

	spawn()
		log_and_message_admins("Stray facehugger spawned in \the [T.loc]")
		new /mob/living/simple_animal/hostile/facehugger(T)
