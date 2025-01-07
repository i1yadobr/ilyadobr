/mob/living/silicon/robot/_examine_text(mob/user)
	var/custom_infix = custom_name ? ", [modtype] [braintype]" : ""
	. = ..(user, infix = custom_infix)

	var/msg = ""
	msg += "\n"
	msg += examine_all_modules()

	var/damage_description = ""
	if (getBruteLoss())
		if (getBruteLoss() < 75)
			damage_description += "It looks slightly dented.\n"
		else
			damage_description += "<B>It looks severely dented!</B>\n"
	if (src.getFireLoss())
		if (getFireLoss() < 75)
			damage_description += "It looks slightly charred.\n"
		else
			damage_description += "<B>It looks severely burnt and heat-warped!</B>\n"
	msg += SPAN("warning", "[damage_description]")

	if(opened)
		msg += SPAN("warning", "Its cover is open and the power cell is [cell ? "installed" : "missing"].")
	else
		msg += "Its cover is closed."
	msg += "\n"

	if(!has_power)
		msg += SPAN("warning", "It appears to be running on backup power.")
		msg += "\n"
	switch(stat)
		if(CONSCIOUS)
			if (ssd_check())
				msg += "It appears to be in stand-by mode." //afk
		if(UNCONSCIOUS)
			msg += SPAN("warning", "It doesn't seem to be responding.")
		if(DEAD)
			msg += SPAN("deadsay", "It's broken, but looks repairable.")
	msg += "\n"
	msg += "*---------*"

	if(print_flavor_text()) msg += "\n[print_flavor_text()]\n"

	if (pose)
		if( findtext(pose,".",length(pose)) == 0 && findtext(pose,"!",length(pose)) == 0 && findtext(pose,"?",length(pose)) == 0 )
			pose = addtext(pose,".") //Makes sure all emotes end with a period.
		msg += "\nIt is [pose]"

	if(hasHUD(user, HUD_SCIENCE))
		if (module)
			msg += "<hr>"
			var/visors = ""
			msg += "<b>[SPAN("notice", "Supported upgrades:")]</b>"
			msg += "\n"
			for(var/i in module.supported_upgrades)
				var/atom/tmp = i
				if(findtext("[tmp]","/obj/item/borg/upgrade/visor/"))
					visors += SPAN("notice", "	[initial(tmp.name)]<br>")
				else
					msg += SPAN("notice", "	[initial(tmp.name)]<br>")
			msg += "<b>[SPAN("notice", "Supported visors:")]</b>"
			msg += "\n"
			msg += visors

	. += "\n[msg]"
	user.showLaws(src)
	return
