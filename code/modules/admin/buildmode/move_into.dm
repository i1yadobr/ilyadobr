/datum/build_mode/move_into
	name = "Move Into"
	icon_state = "buildmode7"

	var/atom/destination

/datum/build_mode/move_into/Destroy()
	ClearDestination()
	. = ..()

/datum/build_mode/move_into/Help()
	to_chat(user, SPAN("notice", "***********************************************************"))
	to_chat(user, SPAN("notice", "Left Click                  = Select destination"))
	to_chat(user, SPAN("notice", "Right Click on Movable Atom = Move target into destination"))
	to_chat(user, SPAN("notice", "***********************************************************"))

/datum/build_mode/move_into/OnClick(atom/movable/A, list/parameters)
	if(parameters["left"])
		SetDestination(A)
	if(parameters["right"])
		if(!destination)
			to_chat(user, SPAN("warning", "No target destination."))
		else if(!ismovable(A))
			to_chat(user, SPAN("warning", "\The [A] must be of type /atom/movable."))
		else
			to_chat(user, SPAN("notice", "Moved \the [A] into \the [destination]."))
			Log("Moved '[log_info_line(A)]' into '[log_info_line(destination)]'.")
			A.forceMove(destination)

/datum/build_mode/move_into/proc/SetDestination(atom/A)
	if(A == destination)
		return
	ClearDestination()

	destination = A

	register_signal(destination, SIGNAL_QDELETING, nameof(.proc/ClearDestination))
	to_chat(user, SPAN("notice", "Will now move targets into \the [destination]."))

/datum/build_mode/move_into/proc/ClearDestination(feedback)
	if(!destination)
		return

	unregister_signal(destination, SIGNAL_QDELETING)
	destination = null
	if(feedback)
		Warn("The selected destination was deleted.")
