/mob/living/carbon/alien/UnarmedAttack(atom/A, proximity)
	if(!..())
		return

	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	A.attack_generic(src, rand(5, 6), "bitten")
