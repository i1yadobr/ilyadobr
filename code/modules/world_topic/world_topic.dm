/proc/handle_world_topic(topic_data)
	var/input[] = params2list(topic_data)
	var/authorized = input["key"] == config?.external?.webhook_key

	if (topic_data == "ping")
		var/x = 1
		for(var/client/C)
			x++
		return x

	else if(topic_data == "discordstatus")
		var/list/playerlist = list()
		for(var/client/C in GLOB.clients)
			if(C.holder && C.is_stealthed())
				continue
			playerlist += C.key
		var/list/response = list()
		response["playerlist"] = playerlist
		response["roundtime"] = roundduration2text()
		response["map"] = GLOB.using_map.name
		response["evac"] = evacuation_controller?.is_evacuating()
		return json_encode(response)

	else if("dooc" in input)
		var/sender_key = input["sender_key"]
		var/message = html_encode(input["message"])
		if(!authorized)
			return json_encode(list("code"="unauthorized"))
		if(!sender_key || !message)
			return json_encode(list("code"="malformed_data"))
		if(!config.misc.ooc_allowed)
			return json_encode(list("code"="ooc_disabled"))
		// TODO(rufus): make a better function to look up jobbans, or replace this with a call to one if it already exists
		if(jobban_keylist.Find("[ckey(sender_key)] - OOC"))
			return json_encode(list("code"="banned"))
		var/sent_message = "[create_text_tag("dooc", "Discord")] <EM>[sender_key]:</EM> [SPAN("message linkify", "[message]")]"
		for(var/client/target in GLOB.clients)
			if(target?.is_key_ignored(sender_key))
				continue
			to_chat(target, SPAN("ooc dooc", "[SPAN("everyone", "[sent_message]")]"), type = MESSAGE_TYPE_DOOC)
		return json_encode(list("code"="success"))

	else if("ahelp" in input)
		var/sender_key = input["sender_key"]
		var/target_key = input["target_key"]
		var/message = html_encode(input["message"])
		if(!authorized)
			return json_encode(list("code"="unauthorized"))
		if(!sender_key || !message)
			return json_encode(list("code"="malformed_data"))

		var/client/target_client
		for(var/client/C in GLOB.clients)
			if(C.ckey == ckey(target_key))
				target_client = C
				break
		if(!target_client)
			return json_encode(list("code" = "no_client"))
		var/player_message = "<font color='red'>Discord PM from <b>[sender_key]</b>: [message]</font>"
		var/admin_message =  SPAN("info", "Discord PM from [sender_key] to <b>[key_name(target_client)]</b> : [message]")

		sound_to(target_client, sound('sound/effects/adminhelp.ogg'))
		to_chat(target_client, player_message, type=MESSAGE_TYPE_ADMINPM)
		for(var/client/A in GLOB.admins)
			if(A == target_client)
				continue
			to_chat(A, admin_message)
		return json_encode(list("code"="success"))

	return json_encode(list("code"="unknown_topic"))
