// AI click handling overrides default /mob/ClickOn() handling with a much cleaner implementation since
// AI doesn't have a `restrained()` state, doesn't use items, and has no need for `Adjacent()` checks.
//
// See code/_onclick/click.dm for base click handling implementations and an overview of click handling in general.
/mob/living/silicon/ai/ClickOn(atom/A, params)
	if(world.time <= next_click)
		return
	next_click = world.time + 1

	if(incapacitated())
		return

	var/list/modifiers = params2list(params)
	if(modifiers["ctrl"] && modifiers["alt"])
		CtrlAltClickOn(A)
		return
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

	face_atom(A)

	if(control_disabled || !canClick())
		return

	if(multitool_mode && isobj(A))
		var/obj/O = A
		var/datum/extension/interactive/multitool/MT = get_extension(O, /datum/extension/interactive/multitool)
		if(MT)
			MT.interact(aiMulti, src)
			return

	// TODO(rufus): convert to a click_handler (code/_onclick/click_handler.dm)
	if(silicon_camera.in_camera_mode)
		silicon_camera.camera_mode_off()
		silicon_camera.captureimage(A, usr)
		return

	A.add_hiddenprint(src)
	A.attack_ai(src)

/mob/living/silicon/ai/DblClickOn(atom/A, params)
	if(control_disabled || stat)
		return

	if(ismob(A))
		ai_actual_track(A)
	else
		A.move_camera_by_click()

/mob/living/silicon/ai/MouseDrop() // AI is prohibited from drag-n-drop interactions
	return


// Clicks with modifier buttons are handled in a unique way for AI interactions and atoms implement
// unique procs for these interactions, e.g. /atom/AICtrlClick(), /atom/AIShiftClick() etc.
// These procs are expected to return a boolean value indicating if interaction was handled.
//
// Interactions that weren't handled by the AI proc fall through to the base /mob/living or /mob
// click handling functions which handle clicks as if AI was a regular mob, with actual adjacency
// taken into account.
//
// See code/_onclick/click.dm for base click handling implementations and an overview of click handling in general.

/mob/living/silicon/ai/CtrlClickOn(atom/A)
	if(!control_disabled && A.AICtrlClick(src))
		return
	..()

/mob/living/silicon/ai/CtrlAltClickOn(atom/A)
	if(!control_disabled && A.AICtrlAltClick(src))
		return
	..()

/mob/living/silicon/ai/ShiftClickOn(atom/A)
	if(!control_disabled && A.AIShiftClick(src))
		return
	..()

/mob/living/silicon/ai/AltClickOn(atom/A)
	if(!control_disabled && A.AIAltClick(src))
		return
	..()

/mob/living/silicon/ai/MiddleClickOn(atom/A)
	if(!control_disabled && A.AIMiddleClick(src))
		return
	..()
