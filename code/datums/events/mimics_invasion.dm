#define MAX_MIMICS 16
#define MIN_MIMICS 8
#define PLAYABLE_MIMICS 3

// TODO(rufus): disabled event (unticked from .dme), not balanced and annoying
//   Mimics as a concept are great. The implementation, however, is very bad.
//   Current mimics are just an annoyance that griefs players and forces you
//   to click an object a few times, after which just patch yourself with a bandage.
//   There were efforts to make a cool trapping mechanic for playable mimics,
//   but the implementation was to gib the caught player. For some reason.
//   And boy was that mechanic abused.
//   Review the mimics from the gamedesign perspective, find solutions to them
//   being a major crew-griefing annoyance for absolutely zero reason, or
//   get rid of the mimic random event altogether.
/datum/event/mimics_invasion
	id = "mimics_invasion"
	name = "Mimics invasion"
	description = "Some things at the station come to life and become mimics."

	mtth = 5 HOURS
	difficulty = 75
	fire_only_once = TRUE

/datum/event/mimics_invasion/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(null, /proc/level_seven_announcement), 0)

/datum/event/mimics_invasion/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (5 MINUTES))
	. = max(1 HOUR, .)

/datum/event/mimics_invasion/on_fire()
	set background = 1
	set waitfor = 0

	var/mimics_count = rand(MIN_MIMICS, MAX_MIMICS)
	var/spawned = 0

	while(spawned < mimics_count)
		CHECK_TICK

		var/area/A = pick_area(list(/proc/is_station_area))
		var/obj/item/O = pick(A.contents)

		if(QDELETED(O) || !istype(O))
			continue

		var/turf/T = get_turf(O.loc)
		var/mob/living/simple_animal/hostile/mimic/M = new(T, O, null)
		log_and_message_admins("A mimic has spawned", null, T, M)

		if(spawned < PLAYABLE_MIMICS)
			M.controllable = TRUE
			notify_ghosts("A new mimic available", null, M, posses_mob = TRUE)
		else
			M.controllable = FALSE

		spawned += 1

	set_next_think_ctx("announce", world.time + (30 SECONDS))

#undef MAX_MIMICS
#undef MIN_MIMICS
#undef PLAYABLE_MIMICS
