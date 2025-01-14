// attack_ai for turfs allows AI to interact with airlocks present on the turf.
// This is a QoL feature intended to help AI players easily interact with open airlocks, as open state sprite
// has very low number of clickable pixels.
/turf/attack_ai(mob/user)
	user.setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
	if(AL)
		AL.attack_ai(user)
		return TRUE
	var/obj/machinery/door/firedoor/FD = locate(/obj/machinery/door/firedoor) in contents
	if(FD)
		FD.attack_ai(user)
		return TRUE

// AICtrlClick for turfs allows AI to Ctrl-click an airlock present on the turf.
// This is a QoL feature intended to help AI players easily interact with open airlocks, as open state sprite
// has very low number of clickable pixels.
/turf/AICtrlClick(mob/user)
	var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
	if(AL)
		AL.AICtrlClick(user)
		return
	return ..()

// AIShiftClick for turfs allows AI to Shift-click an airlock present on the turf.
// This is a QoL feature intended to help AI players easily interact with open airlocks, as open state sprite
// has very low number of clickable pixels.
/turf/AIShiftClick(mob/user)
	var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
	if(AL)
		AL.AIShiftClick(user)
		return
	return ..()

// AIAltClick for turfs allows AI to Alt-click an airlock present on the turf.
// This is a QoL feature intended to help AI players easily interact with open airlocks, as open state sprite
// has very low number of clickable pixels.
/turf/AIAltClick(mob/user)
	var/obj/machinery/door/airlock/AL = locate(/obj/machinery/door/airlock) in contents
	if(AL)
		AL.AIAltClick(user)
		return
	return ..()
