/proc/webhook_send_world_started(server_name)
	webhook_send("world_started", list("server" = server_name))

/proc/webhook_send_ooc(sender_key, message)
	webhook_send("ooc", list("sender_key" = sender_key, "message" = message))

/proc/webhook_send_emote(sender_key, name, message)
	webhook_send("emote", list("sender_key" = sender_key, "name" = name, "message" = message))

/proc/webhook_send_ahelp(from_key, to_key, message)
	webhook_send("ahelp", list("sender_key" = from_key, "target_key" = to_key, "message" = message))

/proc/webhook_send(type, data)
	if(!config.external.webhook_address || !config.external.webhook_key)
		return
	var/query = "[config.external.webhook_address]?type=[type]&data=[url_encode(list2json(data))]&key=[config.external.webhook_key]"
	spawn(-1)
		try
			var/resp[] = world.Export(query)
			if(!resp)
				log_debug("[type] webhook failed to connect")
				return
			var/status_code = resp["STATUS"]
			if(status_code != "200 OK")
				log_debug("[type] webhook returned an unexpected status code: [status_code]")
		catch(var/exception/e)
			log_debug("[type] webhook threw an exception: [e]")
