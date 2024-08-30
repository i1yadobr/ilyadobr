/datum/configuration_section/general
	name = "general"

	var/server_name = null
	var/subserver_name = null
	var/server_id = null
	var/server_port = null
	var/per_map_lobbyscreen = TRUE
	var/list/lobbyscreens = list("icons/splashes/onyx_old.png", "icons/splashes/onyx_new.png")
	var/player_limit = 0
	var/hard_player_limit = 0
	var/ticklag = 0.625
	var/client_fps = 65
	var/fps = 20
	var/tick_limit_mc_init = TICK_LIMIT_MC_INIT_DEFAULT
	var/minute_topic_limit = null
	var/second_topic_limit = null

/datum/configuration_section/general/load_data(list/data)
	CONFIG_LOAD_STR(server_name, data["server_name"])
	CONFIG_LOAD_STR(subserver_name, data["subserver_name"])
	CONFIG_LOAD_STR(server_id, data["server_id"])
	CONFIG_LOAD_NUM(server_port, data["server_port"])

	var/lobbyscreen_file
	CONFIG_LOAD_BOOL(per_map_lobbyscreen, data["per_map_lobbyscreen"])
	if(per_map_lobbyscreen && GLOB.using_map?.lobby_icon)
		lobbyscreen_file = file(GLOB.using_map?.lobby_icon)
	CONFIG_LOAD_LIST(lobbyscreens, data["lobbyscreens"])
	if(!lobbyscreen_file && lobbyscreens)
		lobbyscreen_file = file(pick(lobbyscreens))

	if(isfile(lobbyscreen_file))
		GLOB.current_lobbyscreen = lobbyscreen_file

	CONFIG_LOAD_NUM(player_limit, data["player_limit"])
	CONFIG_LOAD_NUM(hard_player_limit, data["hard_player_limit"])
	CONFIG_LOAD_NUM(ticklag, data["ticklag"])
	if(ticklag)
		fps = 10 / ticklag
	if(fps <= 0)
		fps = initial(fps)
	CONFIG_LOAD_NUM(client_fps, data["client_fps"])
	CONFIG_LOAD_NUM(tick_limit_mc_init, data["tick_limit_mc_init"])
	CONFIG_LOAD_NUM(minute_topic_limit, data["minute_topic_limit"])
	CONFIG_LOAD_NUM(second_topic_limit, data["second_topic_limit"])
