/datum/vote/custom
	name = "custom vote"

/datum/vote/custom/can_run(mob/creator, automatic)
	return is_admin(creator)

/datum/vote/custom/setup_vote(mob/creator, automatic)
	question = capitalize(sanitize(input(creator, "What is the vote for?", "Custom vote setup") as text|null))
	if(!question)
		return FALSE
	for(var/i=1,i<=10,i++)
		var/prompt = "Please enter an option. Hit cancel to review the vote before submission or cancel it.\n\
		              Choices: [i-1]/10."
		var/option = capitalize(sanitize(input(creator, "[prompt]\n\n[get_vote_preview_text()]", "Custom vote setup") as text|null))
		if(!option || !creator?.client)
			break
		choices += option
	if(!creator?.client || !length(choices))
		return FALSE
	var/single_choice_warning
	if(length(choices) == 1)
		single_choice_warning = "\n\nWARNING: there's only one choice, make sure the democracy is intended."
	var/submit = alert("Submit vote?\n[get_vote_preview_text()][single_choice_warning]", "Custom vote setup", "Submit", "Cancel") == "Submit"
	if(!submit)
		return FALSE
	return ..()

/datum/vote/custom/proc/get_vote_preview_text()
	var/preview = "Vote topic: [question]\n\
	               Vote choices: "
	if(!length(choices))
		preview += "*none*"
		return preview
	for(var/choice in choices)
		preview += "\n - [choice]"
	return preview
