// Cyborg click handling overrides default /mob/ClickOn() with their own click handling system which
// only checks for adjacency on item interactions, but otherwise allows cyborgs to interact regardless
// of the distance to objects.
//
// See code/_onclick/click.dm for base click handling implementations and an overview of click handling in general.
/mob/living/silicon/robot/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	var/list/modifiers = params2list(params)
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["middle"])
		if(modifiers["shift"])
			ShiftMiddleClickOn(A)
		else
			MiddleClickOn(A)
		return
	if(modifiers["shift"])
		ShiftClickOn(A)
		return
	if(modifiers["alt"]) // alt and alt-gr (rightalt)
		AltClickOn(A)
		return
	if(modifiers["ctrl"])
		CtrlClickOn(A)
		return

	if(incapacitated())
		return

	if(!canClick())
		return

	face_atom(A)

	if(silicon_camera.in_camera_mode)
		silicon_camera.camera_mode_off()
		if(is_component_functioning("camera"))
			silicon_camera.captureimage(A, usr)
		else
			to_chat(src, SPAN("danger", "Your camera isn't functional."))
		return

	var/obj/item/I = get_active_hand()

	// Cyborgs interact with the world remotely when not using an item
	if(!I)
		A.add_hiddenprint(src)
		A.attack_robot(src)
		return

	if(I == A)
		I.attack_self(src)
		return

	// Regardless of turfs, if A is our location, or A shares the same location with us, or A is in our contents,
	// we allow item interaction with A.
	if(A == loc || (A in loc) || (A in contents))
		var/resolved = I.resolve_attackby(A, src, params)
		if(!resolved && A && I)
			I.afterattack(A, src, TRUE, params)
		return

	if(!isturf(loc))
		return

	// Item interactions in the world where A is turf or is on a turf require cyborg to be adjacent
	if(isturf(A) || isturf(A.loc))
		if(A.Adjacent(src))
			var/resolved = I.resolve_attackby(A, src, params)
			if(!resolved && A && I)
				I.afterattack(A, src, TRUE, params)
			return
		else
			I.afterattack(A, src, FALSE, params)
			return
	return


// CtrlClickOn for cyborgs forwards the click to the regular CtrlClick interaction of the atom A.
// If A is an airlock, an APC, or a turred control panel, or a turf, it calls the AI variant of
// the CtrlClick interaction instead.
/mob/living/silicon/robot/CtrlClickOn(atom/A)
	if(istype(A, /obj/machinery/door/airlock) \
	|| istype(A, /obj/machinery/power/apc) \
	|| istype(A, /obj/machinery/turretid) \
	|| istype(A, /turf))
		A.AICtrlClick()
		return
	A.CtrlClick(src)

// CtrlShiftClickOn for cyborgs forwards the click to the regular CtrlShiftClick interaction of the atom A.
/mob/living/silicon/robot/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)

// ShiftClickOn for cyborgs forwards the click to the regular ShiftClick interaction of the atom A.
// If A is an airlock or a turf, it calls the AI variant of the ShiftClick interaction instead.
/mob/living/silicon/robot/ShiftClickOn(atom/A)
	if(istype(A, /obj/machinery/door/airlock) || istype(A, /turf))
		A.AIShiftClick()
		return
	A.ShiftClick(src)

// AltClickOn for cyborgs forwards the click to the regular AltClick interaction of the atom A.
// If A is a turret control panel or a turf, it calls the AI variant of the AltClick interaction instead.
//
// NOTE: below is a unqiue exception which maps a differnt keybind.
// If A is an airlock, it calls the AI variant of the **CtrlAltClick** interaction instead.
/mob/living/silicon/robot/AltClickOn(atom/A)
	if(istype(A, /obj/machinery/turretid) || istype(A, /turf))
		A.AIAltClick()
		return
	if(istype(A, /obj/machinery/door/airlock))
		A.AICtrlAltClick()
		return
	A.AltClick(src)

//MiddleClickOn for cyborgs cycles through selected modules.
/mob/living/silicon/robot/MiddleClickOn(atom/A)
	cycle_modules()
	return
