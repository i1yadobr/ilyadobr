/datum/build_mode/advanced
	name = "Advanced"
	icon_state = "buildmode2"
	var/build_type

/datum/build_mode/advanced/Help()
	to_chat(user, SPAN("notice", "***********************************************************"))
	to_chat(user, SPAN("notice", "Left Click                       = Create objects"))
	to_chat(user, SPAN("notice", "Right Click                      = Delete objects"))
	to_chat(user, SPAN("notice", "Left Click + Ctrl                = Capture object type"))
	to_chat(user, SPAN("notice", "Middle Click                     = Capture object type"))
	to_chat(user, SPAN("notice", "Right Click on Build Mode Button = Select object type"))
	to_chat(user, "")
	to_chat(user, SPAN("notice", "Use the directional button in the upper left corner to"))
	to_chat(user, SPAN("notice", "change the direction of built objects."))
	to_chat(user, SPAN("notice", "***********************************************************"))

/datum/build_mode/advanced/Configurate()
	SetBuildType(select_subpath(build_type || /obj/structure/closet))

/datum/build_mode/advanced/OnClick(atom/A, list/parameters)
	if(parameters["left"] && !parameters["ctrl"])
		if(ispath(build_type,/turf))
			var/turf/T = get_turf(A)
			T.ChangeTurf(build_type)
		else if(ispath(build_type))
			var/atom/new_atom = new build_type (get_turf(A))
			new_atom.set_dir(host.dir)
			Log("Created - [log_info_line(new_atom)]")
		else
			to_chat(user, SPAN("", "Select a type to construct."))
	else if(parameters["right"])
		Log("Deleted - [log_info_line(A)]")
		qdel(A)
	else if((parameters["left"] && parameters["ctrl"]) || parameters["middle"])
		SetBuildType(A.type)

/datum/build_mode/advanced/proc/SetBuildType(atom_type)
	if(!atom_type || atom_type == build_type)
		return

	if(ispath(atom_type, /atom))
		build_type = atom_type
		to_chat(user, SPAN("notice", "Will now construct instances of the type [atom_type]."))
	else
		to_chat(user, SPAN("warning", "Cannot construct instances of type [atom_type]."))
