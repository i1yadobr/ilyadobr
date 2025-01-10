// UnarmedAttack of metroids handles feeding on targets, stunning them, poking them, or damaging them based on intent.
// It also allows metroid to stop feeding on the target on click.
// If target is not a living creature, metroid performs a generic attack with damage based on `is_adult`.
// Strength of shocking or stunning the target is based on metroid's `powerlevel`.
/mob/living/carbon/metroid/UnarmedAttack(atom/A, proximity)
	if(!..())
		return

	setClickCooldown(DEFAULT_ATTACK_COOLDOWN)

	// TODO(rufus): refactor to a semantic Feeding() proc that would return a bool
	if(Victim)
		if(Victim == A)
			Feedstop()
		return



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
