// TODO(rufus): merge with other sections, redundant, especially after sql will be separated into it's own section
/datum/configuration_section/external
	name = "external"

	var/sql_enabled = FALSE
	var/webhook_address = null
	var/webhook_key = null

/datum/configuration_section/external/load_data(list/data)
	CONFIG_LOAD_BOOL(sql_enabled, data["sql_enabled"])
	CONFIG_LOAD_STR(webhook_address, data["webhook_address"])
	CONFIG_LOAD_STR(webhook_key, data["webhook_key"])
