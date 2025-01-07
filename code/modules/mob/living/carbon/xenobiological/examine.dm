/mob/living/carbon/metroid/_examine_text(mob/user)
	. = ..()
	var/msg = ""
	if (src.stat == DEAD)
		msg += SPAN("deadsay", "It is limp and unresponsive.")
		msg += "\n"
	else
		if (src.getBruteLoss())
			msg += SPAN("warning", "It has [src.getBruteLoss() < 40 ? "some punctures" : "severe punctures and tears"] in its flesh!")
			msg += "\n"

		switch(powerlevel)

			if(2 to 3)
				msg += "It is flickering gently with a little electrical activity."
				msg += "\n"
			if(4 to 5)
				msg += "It is glowing gently with moderate levels of electrical activity."
				msg += "\n"
			if(6 to 9)
				msg += SPAN("warning", "It is glowing brightly with high levels of electrical activity.")
				msg += "\n"
			if(10)
				msg += SPAN("warning", "<B>It is radiating with massive levels of electrical activity!</B>")
				msg += "\n"
	msg += "*---------*"
	. += "\n[msg]"
	return
