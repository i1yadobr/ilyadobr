/datum/vote/map
	name = "map"

/datum/vote/map/can_run(mob/creator, automatic)
	if(automatic)
		return TRUE
	if(is_admin(creator)) // manual map votes can only be started by admins
		return TRUE
	return FALSE

/datum/vote/map/setup_vote()
	for(var/name in GLOB.all_maps)
		if(name in list("Example", "Genesis", "Pathos-I", "Sunset"))
			continue
		choices += name
	..()

/datum/vote/map/report_result()
	if(..())
		return 1
	var/datum/map/M = GLOB.all_maps[result[1]]

	if (M)
		to_world(SPAN("notice", "Map has been changed to: <b>[M.name]</b>"))
		fdel("data/use_map")
		text2file("[M.type]", "data/use_map")

//Used by the ticker.
/datum/vote/map/end_game
	manual_allowed = 0

/datum/vote/map/end_game/report_result()
	SSticker.end_game_state = END_GAME_READY_TO_END
	. = ..()

/datum/vote/map/end_game/start_vote()
	SSticker.end_game_state = END_GAME_AWAITING_MAP
	..()
