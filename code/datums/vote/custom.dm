/datum/vote/custom
	name = "custom vote"

/datum/vote/custom/can_run(mob/creator, automatic)
	return is_admin(creator)

/datum/vote/custom/setup_vote(mob/creator, automatic)
	question = sanitize(input(creator, "What is the vote for?") as text|null)
	if(!question)
		return FALSE
	for(var/i=1,i<=10,i++)
		var/option = capitalize(sanitize(input(creator,"Please enter an option or hit cancel to finish") as text|null))
		if(!option || !creator.client)
			break
		choices += option
	if(!length(choices))
		return FALSE
	return ..()
