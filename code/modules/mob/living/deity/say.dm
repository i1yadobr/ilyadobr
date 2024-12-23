/mob/living/deity/say(message, datum/language/speaking = null, verb="says", alt_name="")
	if(!..(sanitize(message), speaking, verb, alt_name))
		return 0
	if(pylon)
		pylon.audible_message("<b>\The [pylon]</b> reverberates, \"[message]\"", runechat_message = "[message]")
	else
		for(var/m in minions)
			var/datum/mind/mind = m
			to_chat(mind.current, "<span class='cult'><font size='3'>[message]</font></span>")
