/mob/living/silicon/ai/_examine_text(mob/user)
	. = ..()
	var/msg = ""
	if (stat == DEAD)
		msg += SPAN("deadsay", "It appears to be powered-down.")
		msg += "\n"
	else
		var/damage_description = ""
		if (getBruteLoss())
			if (getBruteLoss() < 30)
				damage_description += "It looks slightly dented.\n"
			else
				damage_description += "<B>It looks severely dented!</B>\n"
		if (getFireLoss())
			if (getFireLoss() < 30)
				damage_description += "It looks slightly charred.\n"
			else
				damage_description += "<B>Its casing is melted and heat-warped!</B>\n"
		if (!has_power())
			if (getOxyLoss() > 175)
				damage_description += "<B>It seems to be running on backup power. Its display is blinking a \"BACKUP POWER CRITICAL\" warning.</B>\n"
			else if(getOxyLoss() > 100)
				damage_description += "<B>It seems to be running on backup power. Its display is blinking a \"BACKUP POWER LOW\" warning.</B>\n"
			else
				damage_description += "It seems to be running on backup power.\n"

		if (stat == UNCONSCIOUS || ssd_check())
			damage_description += "It is non-responsive and displaying the text: \"RUNTIME: Sensory Overload, stack 26/3\".\n"
		msg += "<span class='warning'>[damage_description]</span>"
	msg += "*---------*"
	if(hardware && (hardware.owner == src))
		msg += "<br>"
		msg += hardware.get_examine_desc()
	. += "\n[msg]"
	user.showLaws(src)
	return

/mob/proc/showLaws(mob/living/silicon/S)
	return

/mob/observer/ghost/showLaws(mob/living/silicon/S)
	if(antagHUD || is_admin(src))
		S.laws.show_laws(src)
