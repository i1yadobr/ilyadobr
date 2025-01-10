// This file outlines generic unarmed attack behavior that doesn't fall into any specialised category.

/mob/proc/UnarmedAttack(atom/A, proximity)
	return FALSE

// TODO(rufus): refactor to a separate unarmed attack check proc which will be called by subtypes.
//   Semantically UnarmedAttack should just handle the attack and not return any meaningful value.
// Return value used in subtypes to determine if UnarmedAttack is currently allowed
/mob/living/UnarmedAttack(atom/A, proximity)
	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(src, "You cannot interact with the world before the game has started.")
		return FALSE

	if(stat)
		return FALSE

	return TRUE
