/client/proc/panicbunker()
	set category = "Server"
	set name = "Toggle Panic Bunker"

	if (!establish_db_connection())
		to_chat(usr, SPAN("danger", "The Database is not connected!"))
		return

	if(!config.multiaccount.panic_bunker)
		var/age_threshold = input(usr, "Minimum player age?", "Set Panic Bunker account age threshold", 1) as num|null
		if(!age_threshold)
			to_chat(SPAN("danger", "Skipping [age_threshold] age threshold, Panic Bunker is already disabled"))
			return
		config.multiaccount.panic_bunker = age_threshold
		log_and_message_admins("[key_name(usr)] has enabled the Panic Bunker with [age_threshold] day[age_threshold != 1 ? "s" : ""] age threshold")
		return

	config.multiaccount.panic_bunker = 0
	log_and_message_admins("[key_name(usr)] has disabled the Panic Bunker")
	return
