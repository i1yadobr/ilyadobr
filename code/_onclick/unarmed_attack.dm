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

// TODO(rufus): move to human code module
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	if(!..())
		return
	if(machine_visual) // if user is viewing cameras or has some other machinery affect its view, don't allow attacks
		return

	var/obj/item/clothing/gloves/G = gloves
	if(istype(G) && G.Touch(A, TRUE))
		return

	A.attack_hand(src)

// TODO(rufus): move to alien code
/mob/living/carbon/alien/UnarmedAttack(atom/A, proximity)
	if(!..())
		return

	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	A.attack_generic(src, rand(5,6), "bitten")

// TODO(rufus): move to simple_animal code or module
/mob/living/simple_animal/UnarmedAttack(atom/A, proximity)
	if(!..())
		return
	if(istype(A, /mob/living))
		if(!melee_damage_upper)
			custom_emote(VISIBLE_MESSAGE, "[friendly] [A]!")
			return
	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
	var/damage = rand(melee_damage_lower, melee_damage_upper)
	if(A.attack_generic(src, damage, attacktext, environment_smash, damtype, defense) && loc && attack_sound)
		if(attack_sound)
			playsound(loc, attack_sound, 50, TRUE, 1)
		if(istype(A, /mob/living) && ckey)
			admin_attack_log(src, A, "Has [attacktext] its victim.", "Has been [attacktext] by its attacker.", attacktext)

// TODO(rufus): move to metroid code or module
/mob/living/carbon/metroid/UnarmedAttack(atom/A, proximity)
	if(!..())
		return

	// TODO(rufus): refactor to a semantic Feeding() proc that would return a bool
	if(Victim)
		if(Victim == A)
			Feedstop()
		return

	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	if(!istype(A, /mob/living))
		A.attack_generic(src, (is_adult ? rand(20,40) : rand(5,25)), "glomped")
		return

	var/mob/living/M = A
	var/power = clamp(powerlevel + rand(0, 3), 0, 10)
	// TODO(rufus): move meaningful blocks to functions instead of clumping all the logic in a switch with comments
	switch(src.a_intent)
		if(I_HELP) // We just poke the other
			M.visible_message(SPAN("notice", "[src] gently pokes [M]!"), SPAN("notice", "[src] gently pokes you!"))
		if(I_DISARM) // We stun the target, with the intention to feed
			var/stunprob = power * 10
			if(istype(A, /mob/living/carbon/metroid))
				stunprob = 1

			if(prob(stunprob))
				var/shock_damage = clamp((powerlevel-3) * rand(6, 10), 0, 100)
				M.electrocute_act(shock_damage, src, 1.0, ran_zone())
			else if(prob(40))
				M.visible_message(SPAN("danger", "[src] has pounced at [M]!"), SPAN("danger", "[src] has pounced at you!"))
				M.Weaken(power)
				M.Stun(power/2)
			else
				M.visible_message(SPAN("danger", "[src] has tried to pounce at [M]!"), SPAN("danger", "[src] has tried to pounce at you!"))
			M.updatehealth()
		if(I_GRAB) // We feed
			Wrap(M)
		if(I_HURT) // Attacking
			if(istype(M, /mob/living/carbon) && prob(15))
				M.visible_message(SPAN("danger", "[src] has pounced at [M]!"), SPAN("danger", "[src] has pounced at you!"))
				M.Weaken(power)
				M.Stun(power/2)
			else
				M.attack_generic(src, (is_adult ? rand(20,40) : rand(5,25)), "glomped")
