// TODO(rufus): disabled event (unticked from .dme), not balanced and round-ending.
//   Blob is an old thing that is basically space vines on steroids. Inherently, it
//   is also that much more annoying and boring to deal with it.
//   Unlike space vines, current blob implementation just griefs whole departments and
//   chunks of the station not giving crew a fair chance at retaliation.
//   Until this is addressed, blob should stay disabled.
//   *Especially* as a 3 hour mtth random event. Nope.
/datum/event/biohazard_outbreak
	id = "biohazard_outbreak"
	name = "Biohazard Outbreak"
	description = "A blob appears at a random place at the station"

	mtth = 3 HOURS
	fire_only_once = TRUE
	difficulty = 90

/datum/event/biohazard_outbreak/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(null, /proc/level_seven_announcement), 0)

/datum/event/biohazard_outbreak/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (5 MINUTES))
	. = max(1 HOUR, .)

/datum/event/biohazard_outbreak/on_fire()
	var/counts = 0
	var/turf/T = null
	pick_subarea_turf(/area/maintenance, list(/proc/is_station_turf, /proc/not_turf_contains_dense_objects))

	while(!T || counts < 5)
		counts++
		T = pick_subarea_turf(/area/maintenance, list(/proc/is_station_turf, /proc/not_turf_contains_dense_objects))

	if(!T)
		log_and_message_admins("Blob didn't found a space for spawning.")
		return

	new /obj/structure/blob/core(T.loc)
	log_and_message_admins("Blob spawned in \the [get_area(T)]", location = T.loc)

	set_next_think_ctx("announce", world.time + (30 SECONDS))
