GLOBAL_DATUM_INIT(xenomorphs, /datum/antagonist/xenos, new)

/datum/antagonist/xenos
	id = MODE_XENOMORPH
	role_text = "Xenomorph"
	role_text_plural = "Xenomorphs"
	flags = ANTAG_RANDSPAWN | ANTAG_OVERRIDE_JOB | ANTAG_DISPLAY_IN_CHARSETUP
	mob_path = /mob/living/carbon/alien/larva
	welcome_text = "Hiss! You are a larval alien. Hide and bide your time until you are ready to evolve."
	antag_indicator = "hudalien"
	antaghud_indicator = "hudalien"

	faction_role_text = "Xenomorph Thrall"
	faction_descriptor = "Hive"
	faction_welcome = "Your will is ripped away as your humanity merges with the xenomorph overmind. You are now \
		a thrall to the queen and her brood. Obey their instructions without question. Serve the hive."
	faction = "xenomorph"
	faction_indicator = "hudalien"

	hard_cap = 5
	hard_cap_round = 8
	initial_spawn_req = 4
	initial_spawn_target = 6

	spawn_announcement_title = "Lifesign Alert"
	spawn_announcement_delay = 5000

	station_crew_involved = FALSE

/datum/antagonist/xenos/Initialize()
	spawn_announcement = replacetext(GLOB.using_map.unidentified_lifesigns_message, "%STATION_NAME%", station_name())
	spawn_announcement_sound = GLOB.using_map.unidentified_lifesigns_sound
	. = ..()
	if(config.game.xeno_min_age)
		min_player_age = config.game.xeno_min_age

/datum/antagonist/xenos/greet(datum/mind/player)
	to_chat(player.current, SPAN("danger", "<font size=3>You are a [role_text]!</font>"))
	if(ishuman(player.current))
		to_chat(player.current, SPAN("notice", "Hiss! You are a xenomorph! Do everything you can to make sure the hive thriving!"))
	else
		to_chat(player.current, SPAN("notice", "[welcome_text]"))
	if(config.gamemode.antag_objectives == CONFIG_ANTAG_OBJECTIVES_NONE || !player.objectives.len)
		to_chat(player.current, SPAN("notice", "[antag_text]"))

	show_objectives_at_creation(player)
	return TRUE

/datum/antagonist/xenos/antags_are_dead()
	for(var/datum/mind/antag in current_antagonists)
		if(antag.current.stat != DEAD)
			return FALSE
	return TRUE

/datum/antagonist/xenos/proc/get_vents()
	var/list/vents = list()
	for(var/obj/machinery/atmospherics/unary/vent_pump/temp_vent in GLOB.atmos_machinery)
		if(!temp_vent.welded && temp_vent.network && (temp_vent.loc.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION)))
			if(temp_vent.network.normal_members.len > 50)
				vents += temp_vent
	return vents

/datum/antagonist/xenos/create_objectives(datum/mind/player)
	if(!..())
		return

	var/datum/objective/survive/survive_objective = new
	survive_objective.owner = player
	player.objectives += survive_objective

	var/datum/objective/escape/escape_objective = new
	escape_objective.owner = player
	player.objectives += escape_objective

/datum/antagonist/xenos/place_mob(mob/living/player)
	player.forceMove(get_turf(pick(get_vents())))

/datum/antagonist/xenos/update_antag_mob(datum/mind/player, preserve_appearance)
	if(!player.current || (!ishuman(player.current) && !istype(player.current, mob_path))) // Humans keep their humanity, others become larvae
		var/mob/previous_mob = player.current
		player.transfer_to(new mob_path(get_turf(previous_mob)))
		if(previous_mob)
			qdel(previous_mob)
	player.original_mob = weakref(player.current)
	return player.current
