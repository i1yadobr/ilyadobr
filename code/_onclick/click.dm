/*
	Click code cleanup
	~Sayu
*/

/*
	Before anything else, defer these calls to a per-mobtype handler.  This allows us to
	remove istype() spaghetti code, but requires the addition of other handler procs to simplify it.

	Alternately, you could hardcode every mob's variation in a flat ClickOn() proc; however,
	that's a lot of code duplication and is hard to maintain.

	Note that this proc can be overridden, and is in the case of screen objects.
*/

/atom/Click(location, control, params) // This is their reaction to being clicked on (standard proc)
	var/datum/click_handler/click_handler = usr.GetClickHandler()
	click_handler.OnClick(src, params)

/atom/DblClick(location, control, params)
	var/datum/click_handler/click_handler = usr.GetClickHandler()
	click_handler.OnDblClick(src, params)

// TODO(rufus): update this documentation, attackby() is no longer called directly, resolve_attackby() is called instead.
//   It'd also be nice to mention how attackby() relates to afterattack(), specifically that attackby() may resolve an attack,
//   in which case afterattack() won't be called at all.
/*
	Standard mob ClickOn()
	Handles exceptions: middle click, modified clicks, mech actions

	After that, mostly just check your state, check whether you're holding an item,
	check whether you're adjacent to the target, then pass off the click to whoever
	is recieving it.
	The most common are:
	* mob/UnarmedAttack(atom,adjacent) - used here only when adjacent, with no item in hand; in the case of humans, checks gloves
	* atom/attackby(item,user) - used only when adjacent
	* item/afterattack(atom,user,adjacent,params) - used both ranged and adjacent
	* mob/RangedAttack(atom,params) - used only ranged, only used for tk and laser eyes but could be changed
*/
/mob/proc/ClickOn(atom/A, params)

	if(world.time <= next_click) // Hard check, before anything else, to avoid crashing
		return

	next_click = world.time + 1

	var/list/modifiers = params2list(params)
	var/dragged = modifiers["drag"]
	if(dragged && !modifiers[dragged])
		return
	if(modifiers["shift"] && modifiers["ctrl"])
		CtrlShiftClickOn(A)
		return
	if(modifiers["ctrl"] && modifiers["alt"])
		CtrlAltClickOn(A)
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

	if(stat || paralysis || stunned || weakened)
		return

	face_atom(A) // change direction to face what you clicked on

	if(!canClick())
		return

	if(istype(loc, /obj/mecha))
		if(!locate(/turf) in list(A, A.loc)) // Prevents inventory from being drilled
			return
		var/obj/mecha/M = loc
		M.click_action(A, src)
		return

	if(restrained() && istype(A, /mob/living/carbon/human) && A == src)
		var/mob/living/carbon/human/H = A
		H.RestrainedSelfClick()
		return

	if(in_throw_mode)
		if(isturf(A) || isturf(A.loc))
			throw_item(A)
			trigger_aiming(TARGET_CAN_CLICK)
			return
		throw_mode_off()

	var/obj/item/I = get_active_hand()

	if(I == A) // Handle attack_self
		I.attack_self(src)
		trigger_aiming(TARGET_CAN_CLICK)
		if(hand)
			update_inv_l_hand(0)
		else
			update_inv_r_hand(0)
		return

	//Atoms on your person
	// A is your location but is not a turf; or is on you (backpack); or is on something on you (box in backpack); sdepth is needed here because contents depth does not equate inventory storage depth.
	var/sdepth = A.storage_depth(src)
	if((!isturf(A) && A == loc) || (sdepth != -1 && sdepth <= 1))
		if(I)
			var/resolved = I.resolve_attackby(A, src, params)
			if(!resolved && A && I)
				I.afterattack(A, src, TRUE, params)
		else
			UnarmedAttack(A, TRUE)

		trigger_aiming(TARGET_CAN_CLICK)
		return

	if(!isturf(loc)) // This is going to stop you from telekinesing from inside a closet, but I don't shed many tears for that
		return

	//Atoms on turfs (not on your person)
	// A is a turf or is on a turf, or in something on a turf (pen in a box); but not something in something on a turf (pen in a box in a backpack)
	sdepth = A.storage_depth_turf()
	if(isturf(A) || isturf(A.loc) || (sdepth != -1 && sdepth <= 1))
		if(Adjacent(A)) // see adjacent.dm
			for(var/atom/movable/AM in get_turf(A)) // Checks if A is obscured by a fulltile object
				if(AM.layer > A.layer && AM.atom_flags & ATOM_FLAG_FULLTILE_OBJECT)
					// TODO(rufus): move out of the loop as this is not affected by AM changing in any way
					// If A itself is fulltile or has an exception flag, it can't be obstructed by another fulltile
					if((A.atom_flags & ATOM_FLAG_ADJACENT_EXCEPTION) || (A.atom_flags & ATOM_FLAG_FULLTILE_OBJECT))
						continue
					return
			if(I)
				// Return TRUE in attackby() to prevent afterattack() effects (when safely moving items for example)
				var/resolved = I.resolve_attackby(A,src, params)
				if(!resolved && A && I)
					I.afterattack(A, src, TRUE, params)
			else
				UnarmedAttack(A, TRUE)

			trigger_aiming(TARGET_CAN_CLICK)
			return
		else // non-adjacent click
			if(I)
				I.afterattack(A, src, FALSE, params)
			else
				RangedAttack(A, params)

			trigger_aiming(TARGET_CAN_CLICK)
	return

// setClickCooldown sets a secondary cooldown on the user actions and may be used to limit user clicks for a certain time
// after an action.
//
// This is not called automatically in any way and is intended to be used by atoms/objects code
// to apply custom delay.
//
// The delay is shared with all other objects, so setting click cooldown on one object will block
// the mob from clicking anything else until the cooldown is over.
/mob/proc/setClickCooldown(timeout)
	next_move = max(world.time + timeout, next_move)

/mob/proc/canClick()
	// NOTE: this checks for next_move, which is different from next_click used by
	//   mob/proc/OnClick() to enforce a 1 decisecond limit
	if(config.misc.no_click_cooldown || next_move <= world.time)
		return TRUE
	return FALSE

/mob/proc/DblClickOn(atom/A, params)
	return

/*
	Ranged unarmed attack
*/
/mob/proc/RangedAttack(atom/A, params)
	if(!mutations.len) return
	if((MUTATION_LASER in mutations) && a_intent == I_HURT)
		LaserEyes(A)
	else if(MUTATION_TK in mutations)
		A.attack_tk(src)

/*
	Middle click
*/
/mob/proc/MiddleClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/pointing) == GLOB.PREF_MIDDLE_CLICK)
		if(pointed(A))
			return
	swap_hand()
	return

/mob/proc/ShiftMiddleClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/pointing) == GLOB.PREF_SHIFT_MIDDLE_CLICK)
		if(pointed(A))
			return

/*
	Shift click
*/
/mob/proc/ShiftClickOn(atom/A)
	A.ShiftClick(src)
	return
/atom/proc/ShiftClick(mob/user)
	if(user.client && (src in view(user.client.eye)))
		user.examinate(src)

	return

/*
	Ctrl click
*/
/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)
	return

/atom/proc/CtrlClick(mob/user)
	return

/atom/movable/CtrlClick(mob/user)
	if(Adjacent(user))
		user.start_pulling(src)

/*
	Alt click
*/
/mob/proc/AltClickOn(atom/A)
	A.AltClick(src)

/atom/proc/AltClick(mob/user)
	var/turf/T = get_turf(src)
	if(T && user.TurfAdjacent(T))
		if(user.listed_turf == T)
			user.listed_turf = null
		else
			user.listed_turf = T
			user.client.statpanel = "Turf"
	return TRUE

/mob/proc/TurfAdjacent(turf/T)
	return T.AdjacentQuick(src)

/mob/observer/ghost/TurfAdjacent(turf/T)
	if(!isturf(loc) || !client)
		return FALSE
	return z == T.z && (get_dist(loc, T) <= client.view)

/*
	Control+Shift click
*/
/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)
	return

/atom/proc/CtrlShiftClick(mob/user)
	return

/*
	Control+Alt click
*/
/mob/proc/CtrlAltClickOn(atom/A)
	A.CtrlAltClick(src)
	return

/atom/proc/CtrlAltClick(mob/user)
	return
