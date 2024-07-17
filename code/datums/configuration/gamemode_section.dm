/datum/configuration_section/gamemode
	name = "gamemode"

	var/list/probabilities = list()
	var/antag_scaling = FALSE
	var/changeling_starting_points = 0
	var/antag_objectives = "auto"
	var/ert_admin_only = FALSE
	var/restrict_security_antag_roles = FALSE

/datum/configuration_section/gamemode/load_data(data)
	CONFIG_LOAD_LIST(probabilities, data["probabilities"])
	for(var/game_mode in probabilities)
		if(game_mode in gamemode_cache)
			log_misc("Probability of [game_mode] is [probabilities[game_mode]].")
		else
			log_misc("Unknown game mode probability configuration definition: [game_mode].")

	CONFIG_LOAD_BOOL(antag_scaling, data["antag_scaling"])
	CONFIG_LOAD_NUM(changeling_starting_points, data["changeling_starting_points"])
	CONFIG_LOAD_STR(antag_objectives, data["antag_objectives"])
	if(!(antag_objectives in list(CONFIG_ANTAG_OBJECTIVES_NONE, CONFIG_ANTAG_OBJECTIVES_VERB, CONFIG_ANTAG_OBJECTIVES_AUTO)))
		log_misc("Incorrect antag objectives definition: [antag_objectives]")
		antag_objectives = CONFIG_ANTAG_OBJECTIVES_AUTO

	CONFIG_LOAD_BOOL(ert_admin_only, data["ert_admin_only"])
	CONFIG_LOAD_BOOL(restrict_security_antag_roles, data["restrict_security_antag_roles"])
