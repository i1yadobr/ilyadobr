/mob/living/silicon/pai/_examine_text(mob/user)
	. = ..(user, infix = ", personal AI")

	var/msg = ""
	switch(src.stat)
		if(CONSCIOUS)
			if(!src.client)
				msg += "\nIt appears to be in stand-by mode." //afk
		if(UNCONSCIOUS)
			msg += "\n[SPAN("warning", "It doesn't seem to be responding.")]"
		if(DEAD)
			msg += "\n[SPAN("deadsay", "It looks completely unsalvageable.")]"
	msg += "\n*---------*"

	if(print_flavor_text()) msg += "\n[print_flavor_text()]\n"

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt is [pose]"

	. += "\n[msg]"
