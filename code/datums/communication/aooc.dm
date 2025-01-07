/decl/communication_channel/aooc
	name = "AOOC"
	config_setting = "aooc_allowed"
	expected_communicator_type = /client
	flags = COMMUNICATION_LOG_CHANNEL_NAME|COMMUNICATION_ADMIN_FOLLOW
	log_proc = /proc/log_ooc
	mute_setting = MUTE_AOOC

/decl/communication_channel/aooc/can_communicate(client/C, message)
	. = ..()
	if(!.)
		return

	if(!C.holder)
		if(isghost(C.mob))
			to_chat(src, SPAN("warning", "You cannot use [name] while ghosting/observing!"))
			return FALSE
		if(!(C.mob && C.mob.mind && C.mob.mind.special_role))
			to_chat(C, SPAN("danger", "You must be an antag to use [name]."))
			return FALSE

/decl/communication_channel/aooc/do_communicate(client/C, message)
	var/datum/admins/holder = C.holder
	message = emoji_parse(C, message)

	for(var/client/target in GLOB.clients)
		if(target.holder)
			receive_communication(C, target, SPAN("ooc", "[SPAN("aooc", "[create_text_tag("aooc", "Antag-OOC")] <EM>[get_options_bar(C, 0, 1, 1)]:</EM> [SPAN("message linkify", "[message]")]")]"))
		else if(target.mob && target.mob.mind && target.mob.mind.special_role)
			var/display_name = C.key
			var/player_display = holder ? "[display_name]([usr.client.holder.rank])" : display_name
			receive_communication(C, target, SPAN("ooc", "[SPAN("aooc", "[create_text_tag("aooc", "Antag-OOC")] <EM>[player_display]:</EM> [SPAN("message linkify", "[message]")]")]"))

/decl/communication_channel/aooc/get_message_type()
	return MESSAGE_TYPE_AOOC
