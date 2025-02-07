/datum/vote/transfer
	name = "transfer"
	question = "End the shift?"

/datum/vote/transfer/can_run(mob/creator, automatic)
	if(GAME_STATE <= RUNLEVEL_SETUP)
		return FALSE
	if(evacuation_controller?.state != EVAC_IDLE)
		return FALSE
	if(automatic)
		return TRUE
	if(config.vote.allow_vote_restart || is_admin(creator))
		return TRUE
	return FALSE

/datum/vote/transfer/setup_vote(mob/creator, automatic)
	choices = list("Initiate Crew Transfer", "Extend the Round ([config.vote.autotransfer_interval / 600] minutes)")
	..()

/datum/vote/transfer/handle_default_votes()
	if(config.vote.default_no_vote)
		return
	var/factor = 0.5
	switch(world.time / (1 MINUTE))
		if(0 to 60)
			factor = 0.5
		if(61 to 120)
			factor = 0.8
		if(121 to 240)
			factor = 1
		if(241 to 300)
			factor = 1.2
		else
			factor = 1.4
	choices["Initiate Crew Transfer"] = round(choices["Initiate Crew Transfer"] * factor)
	to_world("<font color='purple'>Crew Transfer Factor: [factor]</font>")

/datum/vote/transfer/report_result()
	if(..())
		return 1
	if(result[1] == "Initiate Crew Transfer")
		init_autotransfer()

/datum/vote/transfer/mob_not_participating(mob/user)
	if((. = ..()))
		return
