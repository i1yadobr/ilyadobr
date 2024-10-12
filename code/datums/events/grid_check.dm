// TODO(rufus): while this old event is relatively harmless, it is annoying and very sudden, with
//   crew not having a single way to prevent or interact with this. There are ways to make this more interactive
//   and engaging for the players. For example: there could be some early signs of the incoming power
//   failure, potentially misleading, there could be a machinery that could be built to track such events,
//   there could be some SMES or APC upgrade/rewire/bypass that would allow that piece of tech to stay powered,
//   there could be AI and Cyborg interactions etc. Right now this just annoyingly surprises the crew with a pitch
//   black environment and a following announcement, with stuff like desk lamps still somehow being powered.
//   Needs modernization and rethinking. The current implementation can stay as it's not critically outdated,
//   but as soon as there is some spare time, please update and improve this event.
/datum/event/grid_check
	id = "grid_check"
	name = "Grid Check"
	description = "The station will be de-energized for a while"

	mtth = 3 HOURS
	difficulty = 55

/datum/event/grid_check/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(src, nameof(.proc/announce)), 0)

/datum/event/grid_check/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (18 MINUTES))
	. = max(1 HOUR, .)

/datum/event/grid_check/on_fire()
	power_failure(0, EVENT_LEVEL_MODERATE, GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))

	set_next_think_ctx("announce", world.time + (30 SECONDS))

/datum/event/grid_check/proc/announce()
	GLOB.using_map.grid_check_announcement()
