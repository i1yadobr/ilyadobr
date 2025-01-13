// AICtrlClick of airlocks toggles bolts which hold the airlock in a locked state.
/obj/machinery/door/airlock/AICtrlClick()
	if(locked)
		Topic(src, list("command"="bolts", "activate" = "0"))
	else
		Topic(src, list("command"="bolts", "activate" = "1"))
	return TRUE

// AICtrlAltClick of airlocks toggles elictrified mode of the airlock.
/obj/machinery/door/airlock/AICtrlAltClick()
	if(!electrified_until)
		// permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "1"))
	else
		// disable both temporary and permanent shock
		Topic(src, list("command"="electrify_permanently", "activate" = "0"))
	return TRUE

// AIShiftClick of airlocks toggles the open state of the airlock.
/obj/machinery/door/airlock/AIShiftClick()  // Opens and closes doors!
	if(density)
		Topic(src, list("command"="open", "activate" = "1"))
	else
		Topic(src, list("command"="open", "activate" = "0"))
	return TRUE

// AIMiddleClick of airlocks toggles the bolt lights which visually display if airlock is locked.
/obj/machinery/door/airlock/AIMiddleClick()
	if(!src.lights)
		Topic(src, list("command"="lights", "activate" = "1"))
	else
		Topic(src, list("command"="lights", "activate" = "0"))
	return TRUE
