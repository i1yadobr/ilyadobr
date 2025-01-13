// CtrlClick of the base atom type is a no-op.
/atom/proc/CtrlClick(mob/user)
	return

// CtrlShiftClick of the base atom type is a no-op.
/atom/proc/CtrlShiftClick(mob/user)
	return

// CtrlAltClick of the base atom type is a no-op.
/atom/proc/CtrlAltClick(mob/user)
	return

// ShiftClick of the base atom type triggers examination of atom by the user if user can see the atom.
/atom/proc/ShiftClick(mob/user)
	if(user.client && (src in view(user.client.eye)))
		user.examinate(src)
	return

// AltClick of the base atom type toggles the Turf examination panel for the user if user is adjacent.
/atom/proc/AltClick(mob/user)
	var/turf/T = get_turf(src)
	if(T && user.TurfAdjacent(T))
		if(user.listed_turf == T)
			user.listed_turf = null
		else
			user.listed_turf = T
			user.client.statpanel = "Turf"
	return

// AICtrlClick of the base atom type is a no-op that returns FALSE to indicate that interaction wasn't handled.
/atom/proc/AICtrlClick()
	return FALSE

// AICtrlShiftClick of the base atom type is a no-op that returns FALSE to indicate that interaction wasn't handled.
/atom/proc/AICtrlShiftClick()
	return FALSE

// AICtrlAltClick of the base atom type is a no-op that returns FALSE to indicate that interaction wasn't handled.
/atom/proc/AICtrlAltClick()
	return FALSE

// AIShiftClick of the base atom type is a no-op that returns FALSE to indicate that interaction wasn't handled.
/atom/proc/AIShiftClick()
	return FALSE

// AIAltClick of the base atom type is a no-op that returns FALSE to indicate that interaction wasn't handled.
/atom/proc/AIAltClick(atom/A)
	return FALSE

// AIMiddleClick of the base atom type is a no-op that returns FALSE to indicate that interaction wasn't handled.
/atom/proc/AIMiddleClick(mob/living/silicon/user)
	return FALSE

// TODO(rufus): check if climbable behavior should be on base atom type or could be moved to a subtype
//
// attack_hand for base atom type calls object_shaken() proc if anyone is climbing on this atom,
// and displays a visible message that user shook the atom.
//
// This proc is intended to be extended by subtypes to handle "unarmed" interactions, which are clicks on
// the atom while not holding any item in hand.
//
// This proc is usually called by the UnarmedAttack() proc, which in turn is called by the click handling system.
// See code/_onclick/click.dm for an overview of click handling in general.
/atom/proc/attack_hand(mob/user)
	if(climbers.len && !(user in climbers))
		object_shaken()
		user.visible_message(SPAN("warning", "[user.name] shakes \the [src]."), SPAN("notice", "You shake \the [src]."))

// attack_ai for base atom type is a no-op.
//
// This proc is intended to be overridden by subtypes for handling silicon mobs interactions (AI and Cyborgs).
//
// This proc is usually called by the AI's or Cyborg's ClickOn() proc, which in part of the click system.
// See code/_onclick/click.dm for an overview of click handling in general.
/atom/proc/attack_ai(mob/user as mob)
	return

// attack_robot for base atom type forwards the click to the attack_ai() proc.
//
// This proc is intended to be overridden by subtypes for unique interactions that are different from AI variants.
//
// This proc is only called by the Cyborg's ClickOn() proc, which in part of the click system.
// See code/_onclick/click.dm for an overview of click handling in general.
/atom/proc/attack_robot(mob/user as mob)
	attack_ai(user)
