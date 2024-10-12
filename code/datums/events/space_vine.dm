// TODO(rufus): while I respect the code and effort put into space vines, the current implementation
//   is ancient and absolutely boring to play with. The crew has to do clicky-click for a few minutes
//   and potentially gets hurt. Sometimes inexperienced people just die in the vines because they have
//   no idea how to handle them. This needs major rethinking and refactoring as right now the implementation
//   is to dull and routinish gameplay-wise.
//   Keeping this enabled for now at an increased mtth of 4 hours, but only for the sake of having at least
//   something semi-dangerous happening randomly. To be disabled and refactored as soon as some proper events
//   are added to the storyteller/random events subsystem.
/datum/event/space_vine
	id = "space_vine"
	name = "Space Vines"
	description = "The station begins to overgrow with some space vines"

	mtth = 4 HOURS
	difficulty = 55

/datum/event/space_vine/New()
	. = ..()

	add_think_ctx("announce", CALLBACK(null, /proc/level_seven_announcement), 0)

/datum/event/space_vine/get_mtth()
	. = ..()
	// TODO(rufus): space vines shouldn't be dependant on engineers
	. -= (SSevents.triggers.roles_count["Engineer"] * (8 MINUTES))
	. = max(1 HOUR, .)

/datum/event/space_vine/on_fire()
	spacevine_infestation()

	set_next_think_ctx("announce", world.time + (1 MINUTE))
