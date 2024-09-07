/datum/configuration_section/admin
	name = "admin"

	// TODO(rufus): unify 4 sql switches into a single one (admin, ban, alienwhitelist and sql)
	var/admin_legacy_system = TRUE
	var/allow_admin_ooccolor = TRUE
	var/allow_admin_jump = TRUE
	var/allow_admin_rev = TRUE
	var/allow_admin_spawning = TRUE
	var/autostealth = 0
	var/forbid_singulo_possession = FALSE
	var/debug_paranoid = FALSE

/datum/configuration_section/admin/load_data(list/data)
	CONFIG_LOAD_BOOL(admin_legacy_system, data["admin_legacy_system"])
	CONFIG_LOAD_BOOL(allow_admin_ooccolor, data["allow_admin_ooccolor"])
	CONFIG_LOAD_BOOL(allow_admin_jump, data["allow_admin_jump"])
	CONFIG_LOAD_BOOL(allow_admin_rev, data["allow_admin_rev"])
	CONFIG_LOAD_BOOL(allow_admin_spawning, data["allow_admin_spawning"])
	CONFIG_LOAD_NUM(autostealth, data["autostealth"])
	CONFIG_LOAD_BOOL(forbid_singulo_possession, data["forbid_singulo_possession"])
	CONFIG_LOAD_BOOL(debug_paranoid, data["debug_paranoid"])
