// TODO(rufus): check if climbable behavior should be on base atom type or could be moved to a subtype
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
