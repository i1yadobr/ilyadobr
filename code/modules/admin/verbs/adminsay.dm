/client/proc/cmd_admin_say(msg as text)
	set category = "Special Verbs"
	set name = "Asay" //Gave this shit a shorter name so you only have to time out "asay" rather than "admin say" to use it --NeoFite
	set hidden = 1
	if(!check_rights(R_ADMIN))	return

	msg = sanitize(msg)
	if(!msg)	return

	log_admin("ADMIN: [key_name(src)]: [msg]")

	if(check_rights(R_ADMIN,0))
		for(var/client/C in GLOB.admins)
			if(R_ADMIN & C.holder.rights)
				to_chat(C, SPAN("admin_channel", "" + create_text_tag("admin", "ADMIN") + " [SPAN("name", "[key_name(usr, 1)]")]([admin_jump_link(mob, src)]): [SPAN("message linkify", "[msg]")]"))

	feedback_add_details("admin_verb","M") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_mod_say(msg as text)
	set category = "Special Verbs"
	set name = "Msay"
	set hidden = 1

	if(!check_rights(R_ADMIN|R_MOD|R_MENTOR))	return

	msg = sanitize(msg)

	log_admin("MOD: [key_name(src)]: [msg]")

	if (!msg)
		return

	var/sender_name = key_name(usr, 1)
	if(check_rights(R_ADMIN, 0))
		sender_name = SPAN("admin", "[sender_name]")
	for(var/client/C in GLOB.admins)
		to_chat(C, SPAN("mod_channel", "" + create_text_tag("mod", "MOD") + " [SPAN("name", "[sender_name]")]([admin_jump_link(mob, C.holder)]): [SPAN("message linkify", "[msg]")]"))

	feedback_add_details("admin_verb","MS") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
