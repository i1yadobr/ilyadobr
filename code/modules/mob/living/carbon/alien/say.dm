/mob/living/carbon/alien/say(message)
	var/verb = "says"
	var/message_range = world.view

	if(client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, SPAN("warning", "You cannot speak in IC (Muted)."))
			return

	message = sanitize(message)

	if(stat == 2)
		return say_dead(message)

	if(copytext(message,1,2) == get_prefix_key(/decl/prefix/custom_emote))
		return emote(copytext(message,2))

	var/datum/language/speaking = parse_language(message)

	message = trim(message)

	if(!message || stat)
		return

	..(message, speaking, verb, null, null, message_range, null)
