/datum/configuration_section/debug
	name = "debug"

	var/load_minimum_levels = FALSE

/datum/configuration_section/debug/load_data(list/data)
	CONFIG_LOAD_BOOL(load_minimum_levels, data["load_minimum_levels"])
