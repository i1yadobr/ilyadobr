// TODO(rufus): refactor to a separate unarmed attack check proc which will be called by subtypes.
//   Semantically UnarmedAttack should just handle the attack and not return any meaningful value.
// UnarmedAttack of living mobs checks if an UnarmedAttack is currently allowed.
// It returns a boolean value which subtypes use to determine if they should proceed with their attack logic.
//
// UnarmedAttack does not perform any attack or logic on its own as /mob/living is considered a base path for other
// mob types and should not be used as is for any mobs.
/mob/living/UnarmedAttack(atom/A, proximity)
	if(GAME_STATE < RUNLEVEL_GAME)
		to_chat(src, "You cannot interact with the world before the game has started.")
		return FALSE

	if(stat)
		return FALSE

	return TRUE
