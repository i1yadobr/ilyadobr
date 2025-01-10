// UnarmedAttack of simple animals damages the target for a value between `melee_damage_lower` and `melee_damage_upper`.
// If simple animal doesn't have melee damage, a `friendly` emote will be displayed.
/mob/living/simple_animal/UnarmedAttack(atom/A, proximity)
	if(!..())
		return
	if(istype(A, /mob/living))
		if(!melee_damage_upper)
			custom_emote(VISIBLE_MESSAGE, "[friendly] [A]!")
			return
	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/damage = rand(melee_damage_lower, melee_damage_upper)
	if(A.attack_generic(src, damage, attacktext, environment_smash, damtype, defense))
		if(attack_sound)
			playsound(src, attack_sound, 50, TRUE, 1)
