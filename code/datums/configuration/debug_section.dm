/datum/configuration_section/debug
	name = "debug"

	var/only_load_z1 = FALSE

/datum/configuration_section/debug/load_data(list/data)
	CONFIG_LOAD_BOOL(only_load_z1, data["only_load_z1"])
