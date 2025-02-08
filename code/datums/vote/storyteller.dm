/datum/vote/storyteller
	name = "storyteller"

/datum/vote/storyteller/can_run(mob/creator, automatic)
	if(automatic)
		return TRUE
	if(is_admin(creator))
		return TRUE
	return FALSE

/datum/vote/storyteller/setup_vote(mob/creator, automatic)
	for(var/datum/storyteller_character/C in GLOB.all_storytellers)
		choices += C
		display_choices[C] = "[C.name] - [C.desc]"
	choices += "Random"
	return ..()

/datum/vote/storyteller/report_result()
	if(..())
		return TRUE

	if(result[1] == "Random")
		SSstoryteller.character = pick(GLOB.all_storytellers)
		log_and_message_admins("Storyteller's character was changed to [SSstoryteller.character.name].")
		return

	SSstoryteller.character = result[1]
