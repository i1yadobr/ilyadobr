// click.dm is the main file that is responsible for distributing clicks to their respective procs and handlers.
// It is the origin point of most click handling in the game.
// Below is an overview of the main click handling flow to help navigate click code.
// Also, see the reference section at the end of this comment for additional links and references.
//
// The main flow is:
// BYOND -> /atom/Click() -> /datum/click_handler/OnClick(atom) -> /mob/ClickOn(atom) -> checks/procs
// All three procs have various overrides and exceptions, but in general this is the path and naming that is used.
//
//
// # Click()
// All¹ click interactions start at BYOND's native /atom/Click()² proc which is invoked
// when the client clicks anything in the game. This function is overriden by various atoms in our code,
// including in this file for the base /atom. This is where we take over from BYOND.
//
// Click() calls include so called params³, which include additional information about the click like
// held modifier keys (ctrl/shift/alt) and position on the atom's icon that was clicked.
// These params are passed further and don't affect anything at the current stage.
//
// Most of the time the Click() proc simply invokes the click_handler (/datum/click_handler)⁸ of the mob who
// initiated the click, determined by a special usr var⁴.
// The main exception to this are screen objects (/obj/screen)⁵, special kinds of objects that are only displayed
// to a specific mob. The main use case for these is the user interface, also known as HUD.
//
//
// # Click handlers⁸
// Every mob has a stack⁶ (/datum/stack)⁷ structure of click_handlers.
// Out of this stack, the last added click handler is picked, also known as the "top" click handler of the stack.
// This click handler's OnClick() function is called with a reference to the atom that was clicked and click params.
//
// Most of the time mobs have the default click handler (/datum/click_handler/default) as their top and only one.
// The only this click_handler does is call ClickOn() proc of the mob who initiated the click, passing it a reference
// to the clicked atom and click params.
// Why the detour to click_handler instead of just calling mob's ClickOn()? Because there are certain scenarios
// where we don't want neither our mob nor clicked atom to handle the click. Instead, we might want to trigger
// some ability that is pending target. This is exactly the case with non-default click handlers for changelings
// or spiders, for example.
//
// Various mobs also implement their own click handling logic. For example synthetics like AI and Cyborgs handle
// clicks very differently from the regular "carbon" mobs.
// Since click handlers keep track of their mob, the ClickOn() function of the correct mob type will be
// called automatically from here and allow specific mob' code to handle the click however they want.
//
//
// #Mob's ClickOn(atom)
// This is where the actual bulk of the execution branching happens.
// Most of the default ClickOn() code can be found in this file.
//
// ClickOn() starts applying various checks to the current mob state and click params³ to determine where
// to pass the click handling next.
// This includes:
// - mandatory 1 deciscond check, ensuring no one clicks faster than 10 times per second
// - handling ctrl/shift/alt clicks or combination of those
// - determining if something inside the user's inventory was clicked
// - determining if clicked atom was adjacent (within 1 tile range) or remote
// - checking if user clicked something with an item in their hands or "unarmed"
// All the factors above are taken into account to call appropriate "attack" procs which clicked objects
// use to define their interactive functionality.
// In case of ctrl/shift/alt clicks, special "CtrlClickOn", "ShiftClickOn" etc. procs are called instead,
// which other mobtypes can override to handle these types of click in their own way.
//
// # Reference and additional information
// 1. There are exceptions. Double clicks are handled by https://www.byond.com/docs/ref/#/atom/proc/DblClick and
//    drag and drop interactions are handled by https://www.byond.com/docs/ref/#/atom/proc/MouseDrop.
//    Both have overrides in our code to define custom behavior for various scenarios.
// 2. Click(): https://www.byond.com/docs/ref/#/atom/proc/Click
//    In BYOND it's also possible to handle the /client/Click() (https://www.byond.com/docs/ref/#/client/proc/Click)
//    which captures clicks on any control in the game window, not only game objects and the HUD.
//    However, this is not currently used in the codebase (exception: code/modules/admin/callproc/callproc.dm)
// 3. Click params: https://www.byond.com/docs/ref/#/DM/mouse
// 4. usr variable: https://www.byond.com/docs/ref/#/proc/var/usr
// 5. /obj/screen: see code/_onclick/hud/screen_objects.dm
// 6. Stack concept: https://en.wikipedia.org/wiki/Stack_(abstract_data_type)
// 7. /datum/stack: see code/__std/stack.dm
// 8. /datum/click_handler: see code/_onclick/click_handler.dm


// Click() and DblClick() are overrides of BYOND's native functions with the same name that act as entrypoints
// to all click handling (except for /client/Click() used for one specific admin-only function).
// These functions retrieve the appropriate /datum/click_handler of the user and simply pass the call.
//
// Note that some atoms have their own overrides of Click() that take precedence.
// This is extensively used by /obj/screen elements that are used for user interface, also known as HUD,
// as they define unique functionality depsite being /obj's just like the rest of the objects in the game.
/atom/Click(location, control, params) // This is their reaction to being clicked on (standard proc)
	var/datum/click_handler/click_handler = usr.GetClickHandler()
	click_handler.OnClick(src, params)

/atom/DblClick(location, control, params)
	var/datum/click_handler/click_handler = usr.GetClickHandler()
	click_handler.OnDblClick(src, params)


// ClickOn() for the base mob type handles multiple checks related to the mob state and click params and forwards
// the call to the appropriate proc.
// Main performed checks include:
// - mandatory 1 deciscond check, ensuring no one clicks faster than 10 times per second
// - check of the user's click cooldown which might still be active after they clicked something else
// - check of user state being valid for a click, e.g. not stunned, paralyzed etc.
// - handling ctrl/shift/alt clicks or combinations of those
// - determining if something inside the user's inventory was clicked
// - determining if clicked atom was adjacent (within 1 tile range) or remote
// - checking if user clicked something with an item in their hands or "unarmed"
//
// ClickOn currently distributes click to the following functions:
// - /mob/CtrlClickOn(), /mob/ShiftClickOn() etc. for clicks with modifier keys held
// - /obj/mecha/click_action() for clicks on mechs
// - /mob/living/carbon/human/RestrainedSelfClick() for human actions on self while restrained
// - /mob/throw_item() for handling item throws
// - /obj/item/attack_self() for activating items in hands on click
// - /obj/item/resolve_attackby() for main handling of clicks on atoms within reach using an item
// - /obj/item/afterattack() for secondary handling of clicks on atoms using an item if click wasn't
//   handled by resolve_attackby() or if clicked atom is not withing reach
// - /mob/UnarmedAttack() for main handling of clicks on atoms within reach while not using an item
// - /mob/RangedAttack() for main handling of clicks on atoms outside of the mob's reach while not using an item
//
// ClickOn also changes the direction the mob is facing towards the clicked atom (unless modifier keys are used).
// Clicks with modifier keys may also change the direction user is facing.
// If the mob is being aimed at, ClickOn will also trigger the "Click" restriction by calling /mob/trigger_aiming(TARGET_CAN_CLICK).
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

	if(restrained())
		// NOTE(rufus): currently only human clicks are allowed for restrained mobs,
		//   the rest of the code is not adapted to restrained clicks yet and doesn't
		//   handle them properly.
		if(!istype(A, /mob/living/carbon/human))
			return
		if(A == src)
			var/mob/living/carbon/human/H = A
			H.RestrainedSelfClick()
			return
		// the click falls through to regular interaction, attack code will
		// recognize the restrained state on its own and default to bites/kicks

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


/mob/proc/DblClickOn(atom/A, params)
	return

/mob/proc/CtrlClickOn(atom/A)
	A.CtrlClick(src)

/mob/proc/CtrlShiftClickOn(atom/A)
	A.CtrlShiftClick(src)

/mob/proc/CtrlAltClickOn(atom/A)
	A.CtrlAltClick(src)

/mob/proc/ShiftClickOn(atom/A)
	A.ShiftClick(src)

/mob/proc/AltClickOn(atom/A)
	A.AltClick(src)

// MiddleClickOn of the base mob type makes mob point towards atom A if
// pointing preference is set to Middle-Click.
// Otherwise it makes mob change their active hand.
/mob/proc/MiddleClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/pointing) == GLOB.PREF_MIDDLE_CLICK)
		if(pointed(A))
			return
	swap_hand()

// ShiftMiddleClickOn of the base mob type makes mob point towards atom A if
// pointing preference is set to Shift-Middle-Click.
/mob/proc/ShiftMiddleClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/pointing) == GLOB.PREF_SHIFT_MIDDLE_CLICK)
		if(pointed(A))
			return
