/datum/build_mode/relocate_to
	name = "Relocate To"
	icon_state = "buildmode9"
	var/atom/movable/to_relocate

/datum/build_mode/relocate_to/Destroy()
	ClearRelocator()
	. = ..()

/datum/build_mode/relocate_to/Help()
	to_chat(user, SPAN("notice", "***********************************************************"))
	to_chat(user, SPAN("notice", "Left Click on Movable Atom = Select object to be relocated"))
	to_chat(user, SPAN("notice", "Right Click on Turf        = Destination to be relocated to"))
	to_chat(user, SPAN("notice", "***********************************************************"))

/datum/build_mode/relocate_to/OnClick(atom/A, list/parameters)
	if(parameters["left"])
		if(istype(A, /atom/movable))
			SetRelocator(A)
	else if(parameters["right"])
		if(to_relocate)
			var/destination_turf = get_turf(A)
			if(destination_turf)
				to_relocate.forceMove(destination_turf)
				Log("Relocated '[log_info_line(to_relocate)]' to '[log_info_line(destination_turf)]'")
			else
				to_chat(user, SPAN("warning", "Unable to locate destination turf."))
		else
			to_chat(user, SPAN("warning", "You have nothing selected to relocate."))

/datum/build_mode/relocate_to/proc/SetRelocator(new_relocator)
	if(to_relocate == new_relocator)
		return
	ClearRelocator()

	to_relocate = new_relocator
	register_signal(to_relocate, SIGNAL_QDELETING, nameof(.proc/ClearRelocator))
	to_chat(user, SPAN("notice", "Will now be relocating \the [to_relocate]."))

/datum/build_mode/relocate_to/proc/ClearRelocator(feedback)
	if(!to_relocate)
		return

	unregister_signal(to_relocate, SIGNAL_QDELETING)
	to_relocate = null
	if(feedback)
		Warn("The selected relocation object was deleted.")
