/obj/item/device/hailer
	name = "hailer"
	desc = "Used by obese officers to save their breath for running."
	icon_state = "voice0"
	item_state = "flashbang"	//looks exactly like a flash (and nothing like a flashbang)
	w_class = ITEM_SIZE_TINY
	obj_flags = OBJ_FLAG_CONDUCTIBLE

	var/use_message = "Halt! Security!"
	var/spamcheck = 0
	var/insults

/obj/item/device/hailer/verb/set_message()
	set name = "Set Hailer Message"
	set category = "Object"
	set desc = "Alter the message shouted by your hailer."

	if(!isnull(insults))
		to_chat(usr, "The hailer is fried. The tiny input screen just shows a waving ASCII penis.")
		return

	var/new_message = input(usr, "Please enter new message (leave blank to reset).") as text
	if(!new_message || new_message == "")
		use_message = "Halt! Security!"
	else
		use_message = capitalize(copytext(sanitize(new_message), 1, MAX_MESSAGE_LEN))

	to_chat(usr, "You configure the hailer to shout \"[use_message]\".")

/obj/item/device/hailer/attack_self(mob/living/carbon/user as mob)
	if (spamcheck)
		return

	if(isnull(insults))
		playsound(src, 'sound/voice/halt.ogg', 100, 1, vary = 0)
		// TODO(rufus): refactor to hailer's own audible message, /atom/proc/audible_message(), and add runechat message override
		user.audible_message(SPAN("warning", "[user]'s [name] rasps, \"[use_message]\""), null, SPAN("warning", "\The [user] holds up \the [name]."))
	else
		if(insults > 0)
			playsound(src, 'sound/voice/binsult.ogg', 100, 1, vary = 0)
			// Yes, it used to show the transcription of the sound clip. That was a) inaccurate b) immature as shit.
			// TODO(rufus): refactor to hailer's own audible message, /atom/proc/audible_message(), and add runechat message override
			user.audible_message(SPAN("warning", "[user]'s [name] gurgles something indecipherable and deeply offensive."), null, SPAN("warning", "\The [user] holds up \the [name]."))
			insults--
		else
			to_chat(user, SPAN("danger", "*BZZZZZZZZT*"))

	spamcheck = 1
	spawn(20)
		spamcheck = 0

/obj/item/device/hailer/emag_act(remaining_charges, mob/user)
	if(isnull(insults))
		to_chat(user, SPAN("danger", "You overload \the [src]'s voice synthesizer."))
		insults = rand(1, 3)//to prevent dickflooding
		return 1
	else
		to_chat(user, "The hailer is fried. You can't even fit the sequencer into the input slot.")
