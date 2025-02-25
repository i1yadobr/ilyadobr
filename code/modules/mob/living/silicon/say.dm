/mob/living/silicon/say(message, sanitize = TRUE, log_message = TRUE)
	return ..(sanitize ? sanitize(message) : message, log_message = log_message)

/mob/living/silicon/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	if(playable_mob) // I don't know why it's here, because living/say already does logging stuff.
		log_say("[key_name(src)]: [message]")

/mob/living/silicon/robot/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	..()
	if(message_mode)
		if(!is_component_functioning("radio"))
			to_chat(src, SPAN("warning", "Your radio isn't functional at this time."))
			return 0
		if(message_mode == "general")
			message_mode = null
		return silicon_radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/ai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	..()
	if(message_mode == "department")
		return holopad_talk(message, verb, speaking)
	else if(message_mode)
		if (ai_radio.disabledAi || !has_power() || stat)
			to_chat(src, SPAN("danger", "System Error - Transceiver Disabled."))
			return 0
		if(message_mode == "general")
			message_mode = null
		return ai_radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/pai/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	..()
	if(message_mode)
		if(message_mode == "general")
			message_mode = null
		return silicon_radio.talk_into(src,message,message_mode,verb,speaking)

/mob/living/silicon/say_quote(text)
	var/ending = copytext(text, length(text))

	if (ending == "?")
		return speak_query
	else if (ending == "!")
		return speak_exclamation

	return speak_statement

#define IS_AI 1
#define IS_ROBOT 2
#define IS_PAI 3

/mob/living/silicon/say_understands(other,datum/language/speaking = null)
	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (istype(other, /mob/living/carbon))
			return 1
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/carbon/brain))
			return 1
	return ..()

/mob/living/silicon/ai/say(message, sanitize = 1)
	if (holo)
		//check if AI using radio while in hologramm
		if(length_char(message) >= 1 && copytext_char(message,1,2) == get_prefix_key(/decl/prefix/radio_main_channel))
			. = ..()
		else if(length_char(message) >= 2 && (copytext_char(message, 1 ,3) in department_radio_keys))
			. = ..()
		else
			. = ..(":H[message]")
	else
		. = ..()
//For holopads only. Usable by AI.
/mob/living/silicon/ai/proc/holopad_talk(message, verb, datum/language/speaking)

	log_say("[key_name(src)]: [message]")

	message = trim(message)

	if (!message)
		return

	var/obj/machinery/hologram/holopad/H = src.holo
	if(H && H.masters[src])//If there is a hologram and its master is the user.

		// AI can hear their own message, this formats it for them.
		if(speaking)
			to_chat(src, "<i>[SPAN("game say", "Holopad transmitted, [SPAN("name", "[real_name]")] [speaking.format_message(message, verb)]")]</i>")
		else
			to_chat(src, "<i>[SPAN("game say", "Holopad transmitted, [SPAN("name", "[real_name]")] [verb], [SPAN("message", "[SPAN("body", "\"[message]\"")]")]")]</i>")

		//This is so pAI's and people inside lockers/boxes,etc can hear the AI Holopad, the alternative being recursion through contents.
		//This is much faster.
		var/list/listening = list()
		var/list/listening_obj = list()
		var/turf/T = get_turf(H)

		if(T)
			var/list/hear = hear(7, T)
			var/list/hearturfs = list()

			for(var/I in hear)
				if(istype(I, /mob/))
					var/mob/M = I
					listening += M
					hearturfs += M.locs[1]
					for(var/obj/O in M.contents)
						listening_obj |= O
				else if(istype(I, /obj/))
					var/obj/O = I
					hearturfs += O.locs[1]
					listening_obj |= O


			for(var/mob/M in GLOB.player_list)
				if(M.stat == DEAD && M.get_preference_value(/datum/client_preference/ghost_ears) == GLOB.PREF_ALL_SPEECH)
					M.hear_say(message,verb,speaking,null,null, src)
					continue
				if(M.loc && (M.locs[1] in hearturfs))
					M.hear_say(message,verb,speaking,null,null, src)


	else
		to_chat(src, "No holopad connected.")
		return 0
	return 1

/mob/living/silicon/ai/proc/holopad_emote(message) //This is called when the AI uses the 'me' verb while using a holopad.

	log_emote("[key_name(src)]: [message]")

	message = trim(message)

	if (!message)
		return

	var/obj/machinery/hologram/holopad/T = src.holo
	if(T && T.masters[src])
		var/rendered = SPAN("game say", "[SPAN("name", "[name]")] [SPAN("message", "[message]")]")
		to_chat(src, "<i>[SPAN("game say", "Holopad action relayed, [SPAN("name", "[real_name]")] [SPAN("message", "[message]")]")]</i>")

		for(var/mob/M in viewers(T.loc))
			M.show_message(rendered, 2)
	else //This shouldn't occur, but better safe then sorry.
		to_chat(src, "No holopad connected.")
		return 0
	return 1

#undef IS_AI
#undef IS_ROBOT
#undef IS_PAI
