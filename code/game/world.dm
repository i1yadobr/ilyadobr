#define REBOOT_HARD 1
#define REBOOT_REALLY_HARD 2

var/server_name = "ZeroOnyx"

/var/game_id = null
/hook/global_init/proc/generate_gameid()
	if(game_id != null)
		return
	game_id = ""

	var/list/c = list("a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	var/l = c.len

	var/t = world.timeofday
	for(var/_ = 1 to 4)
		game_id = "[c[(t % l) + 1]][game_id]"
		t = round(t / l)
	game_id = "-[game_id]"
	t = round(world.realtime / (10 * 60 * 60 * 24))
	for(var/_ = 1 to 3)
		game_id = "[c[(t % l) + 1]][game_id]"
		t = round(t / l)
	return 1

/proc/toggle_ooc()
	config.misc.ooc_allowed = !config.misc.ooc_allowed
	if(config.misc.ooc_allowed)
		to_world("<b>The OOC channel has been globally enabled!</b>")
	else
		to_world("<b>The OOC channel has been globally disabled!</b>")

/proc/disable_ooc()
	if(config.misc.ooc_allowed)
		toggle_ooc()

/proc/enable_ooc()
	if(!config.misc.ooc_allowed)
		toggle_ooc()

/proc/toggle_looc()
	config.misc.looc_allowed = !config.misc.looc_allowed
	if(config.misc.looc_allowed)
		to_world("<b>The LOOC channel has been globally enabled!</b>")
	else
		to_world("<b>The LOOC channel has been globally disabled!</b>")

/proc/disable_looc()
	if(config.misc.ooc_allowed)
		toggle_ooc()

/proc/enable_looc()
	if(!config.misc.looc_allowed)
		toggle_looc()

// Find mobs matching a given string
//
// search_string: the string to search for, in params format; for example, "some_key;mob_name"
// restrict_type: A mob type to restrict the search to, or null to not restrict
//
// Partial matches will be found, but exact matches will be preferred by the search
//
// Returns: A possibly-empty list of the strongest matches
/proc/text_find_mobs(search_string, restrict_type = null)
	var/list/search = params2list(search_string)
	var/list/ckeysearch = list()
	for(var/text in search)
		ckeysearch += ckey(text)

	var/list/match = list()

	for(var/mob/M in SSmobs.mob_list)
		if(restrict_type && !istype(M, restrict_type))
			continue
		var/strings = list(M.name, M.ckey)
		if(M.mind)
			strings += M.mind.assigned_role
			strings += M.mind.special_role
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(H.species)
				strings += H.species.name
		for(var/text in strings)
			if(ckey(text) in ckeysearch)
				match[M] += 10 // an exact match is far better than a partial one
			else
				for(var/searchstr in search)
					if(findtext(text, searchstr))
						match[M] += 1

	var/maxstrength = 0
	for(var/mob/M in match)
		maxstrength = max(match[M], maxstrength)
	for(var/mob/M in match)
		if(match[M] < maxstrength)
			match -= M

	return match

#define RECOMMENDED_VERSION 515
/world/New()
	SetupLogs()

	if(world.system_type == UNIX)
		GLOB.converter_dll = "./converter.so"
	else
		GLOB.converter_dll = "converter.dll"
	if(!fexists(GLOB.converter_dll))
		log_error("CRITICAL: [GLOB.converter_dll] not found")
		log_error("Can't read config, shutting down...")
		sleep(50)
		shutdown()

	if(byond_version < RECOMMENDED_VERSION)
		to_world_log("Your server's byond version does not meet the recommended requirements for this server. Please update BYOND")

	load_sql_config("config/dbconfig.txt")

	// Load up the base config.toml
	try
		config.load_configuration()
	catch(var/exception/e)
		log_error("CRITICAL: failed to read config: [e.name]")
		log_error("Can't read config, shutting down...")
		sleep(50)
		shutdown()

	if(config.general.server_port)
		var/port = OpenPort(config.general.server_port)
		to_world_log(port ? "Changed port to [port]" : "Failed to change port")

	//set window title
	if(config.general.subserver_name)
		var/subserver_name = uppertext(copytext(config.general.subserver_name, 1, 2)) + copytext(config.general.subserver_name, 2)
		name = "[config.general.server_name]: [subserver_name] - [GLOB.using_map.full_name]"
	else
		name = "[config.general.server_name] - [GLOB.using_map.full_name]"

	watchlist = new /datum/watchlist

	var/list/lobby_music_tracks = subtypesof(/lobby_music)
	var/lobby_music_type = /lobby_music
	if(lobby_music_tracks.len)
		lobby_music_type = pick(lobby_music_tracks)
	GLOB.lobby_music = new lobby_music_type()

	callHook("startup")

	. = ..()

	Master.Initialize(10, FALSE)
	webhook_send_roundstatus("lobby", "[config.general.server_id]")

#undef RECOMMENDED_VERSION

var/world_topic_spam_protect_time = world.timeofday

/world/Topic(T, addr, master, key)
	log_href("\"[T]\", from:[addr], master:[master][log_end]")

	var/input[] = params2list(T)
	var/key_valid = config.external.comms_password && input["key"] == config.external.comms_password

	if (T == "ping")
		var/x = 1
		for (var/client/C)
			x++
		return x

	else if(T == "discordstatus")
		var/list/playerlist = list()
		for(var/client/C in GLOB.clients)
			if(C.holder && C.is_stealthed() && !key_valid)
				continue
			playerlist += C.key
		var/list/response = list()
		response["playerlist"] = playerlist
		response["roundtime"] = roundduration2text()
		response["map"] = GLOB.using_map.name
		response["evac"] = evacuation_controller.is_evacuating()
		return json_encode(response)

	// TODO(rufus): finish refactoring this
	else if ("ooc_message" in input)
		var/client_key = input["sender_key"]
		var/client_ckey = ckey(client_key)
		var/message = html_encode(input["message"])
		if(!client_ckey || !message)
			return
		if(!config.misc.ooc_allowed)
			return "globally muted"
		// TODO(rufus): make a better function to look up jobbans, or replace this with a call to one if it already exists
		if(jobban_keylist.Find("[client_ckey] - OOC"))
			return "banned from ooc"
		var/sent_message = "[create_text_tag("dooc", "Discord")] <EM>[client_key]:</EM> <span class='message linkify'>[message]</span>"
		for(var/client/target in GLOB.clients)
			if(target?.is_key_ignored(client_key))
				continue
			to_chat(target, "<span class='ooc dooc'><span class='everyone'>[sent_message]</span></span>", type = MESSAGE_TYPE_DOOC)


/world/Reboot(reason, reboot_hardness = 0)
	// sound_to(world, sound('sound/AI/newroundsexy.ogg')

	if(reboot_hardness == REBOOT_REALLY_HARD)
		..(reason)
		return

	if(!reboot_hardness == REBOOT_HARD)
		Master.Shutdown()

	for(var/client/C in GLOB.clients)
		C?.tgui_panel?.send_roundrestart()

		if(config.external.server) //if you set a server location in config.txt, it sends you there instead of trying to reconnect to the same world address. -- NeoFite
			send_link(C, "byond://[config.external.server]")

	game_log("World rebooted at [time_stamp()]")

	if(blackbox)
		blackbox.save_all_data_to_sql()

	..(reason)

/world/Del()
	callHook("shutdown")
	return ..()

/world/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	to_file(F, the_mode)

/hook/startup/proc/loadMOTD()
	world.load_motd()
	return 1

/world/proc/load_motd()
	join_motd = file2text("config/motd.txt")
	load_regular_announcement()

/world/proc/update_status()
	var/s = ""

	if (config && config.general.server_name)
		s += "<b>[config.general.server_name]</b>"

	// TODO(rufus): come up with a good description and potentially sprinkle some features on top, keeping it minimal for now
	if ((!config.game.enter_allowed) || (config.game.use_whitelist) )
		s += ", Limited Access"

	/* does this help? I do not know */
	if (src.status != s)
		src.status = s

#define WORLD_LOG_START(X) WRITE_FILE(GLOB.world_##X##_log, "\n\nStarting up round ID [game_id]. [time2text(world.realtime, "DD.MM.YY hh:mm")]\n---------------------")
#define WORLD_SETUP_LOG(X) GLOB.world_##X##_log = file("[log_directory]/[log_prefix][#X].log") ; WORLD_LOG_START(X)
#define WORLD_SETUP_LOG_DETAILED(X) GLOB.world_##X##_log = file("[log_directory_detailed]/[log_prefix_detailed][#X].log") ; WORLD_LOG_START(X)

/world/proc/SetupLogs()
	if (!game_id)
		util_crash_with("Unknown game_id!")

	var/log_directory = "data/logs/[time2text(world.realtime, "YYYY/MM-Month")]"
	var/log_prefix = "[time2text(world.realtime, "DD.MM.YY")]_"

	GLOB.log_directory = log_directory // TODO: remove GLOB.log_directory, check initialize.log

	var/log_directory_detailed = "data/logs/[time2text(world.realtime, "YYYY/MM-Month")]/[time2text(world.realtime, "DD.MM.YY")]_detailed"
	var/log_prefix_detailed = "[time2text(world.realtime, "DD.MM.YY_hh.mm")]_[game_id]_"

	WORLD_SETUP_LOG_DETAILED(runtime)
	WORLD_SETUP_LOG_DETAILED(qdel)
	WORLD_SETUP_LOG_DETAILED(debug)
	WORLD_SETUP_LOG_DETAILED(hrefs)
	WORLD_SETUP_LOG(story)
	WORLD_SETUP_LOG(common)

#undef WORLD_SETUP_LOG_DETAILED
#undef WORLD_SETUP_LOG
#undef WORLD_LOG_START

#define FAILED_DB_CONNECTION_CUTOFF 5
var/failed_db_connections = 0


/hook/startup/proc/connectDB()
	if(!config.external.sql_enabled)
		log_to_dd("SQL disabled. Your server will not use the main database.")
	else if(!setup_database_connection())
		log_to_dd("Your server failed to establish a connection with the main database.")
	else
		log_to_dd("Main database connection established.")
	return TRUE

/proc/setup_database_connection()

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)	//If it failed to establish a connection more than 5 times in a row, don't bother attempting to connect anymore.
		return 0

	if(!dbcon)
		dbcon = new()

	var/user = sqllogin
	var/pass = sqlpass
	var/db = sqldb
	var/address = sqladdress
	var/port = sqlport

	dbcon.Connect("dbi:mysql:[db]:[address]:[port]","[user]","[pass]")
	. = dbcon.IsConnected()
	if ( . )
		failed_db_connections = 0	//If this connection succeeded, reset the failed connections counter.
	else
		failed_db_connections++		//If it failed, increase the failed connections counter.
		log_to_dd(dbcon.ErrorMsg())

	return .

//This proc ensures that the connection to the main database (global variable dbcon) is established
/proc/establish_db_connection()
	if(!config.external.sql_enabled)
		return FALSE

	if(failed_db_connections > FAILED_DB_CONNECTION_CUTOFF)
		return FALSE

	if(!dbcon || !dbcon.IsConnected())
		return setup_database_connection()
	else
		return TRUE
