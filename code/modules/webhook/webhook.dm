/proc/webhook_send_world_started(server_name)
	webhook_send("world_started", list("server" = server_name))

/proc/webhook_send_ooc(sender_key, message)
	webhook_send("ooc", list("sender_key" = sender_key, "message" = message))

/proc/webhook_send_emote(sender_key, name, message)
	webhook_send("emote", list("sender_key" = sender_key, "name" = name, "message" = message))

/proc/webhook_send_ahelp(from_key, to_key, message)
	webhook_send("ahelp", list("from" = from_key, "to" = to_key, "message" = message))

/proc/webhook_send(type, data)
	if(!config.external.webhook_address || !config.external.webhook_key)
		return
	var/query = "[config.external.webhook_address]?type=[type]&data=[url_encode(list2json(data))]&key=[config.external.webhook_key]"
	spawn(-1)
		world.Export(query)
