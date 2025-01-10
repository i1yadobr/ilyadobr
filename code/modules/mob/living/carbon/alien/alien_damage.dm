/mob/living/carbon/alien/attack_hand(mob/living/carbon/M as mob)
	..()
	switch(M.a_intent)

		if (I_HELP)
			help_shake_act(M)

		else
			var/damage = rand(1, 9)
			if (prob(90))
				if (MUTATION_HULK in M.mutations)
					damage += 5
					spawn(0)
						Paralyse(1)
						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)
				playsound(loc, SFX_FIGHTING_PUNCH, rand(80, 100), 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(SPAN("danger", "\The [M] has punched \the [src]!"), 1)
				if (damage > 4.9)
					Weaken(rand(10,15))
					for(var/mob/O in viewers(M, null))
						if ((O.client && !( O.blinded )))
							O.show_message(SPAN("danger", "\The [M] has weakened \the [src]!"), 1, SPAN("warning", "You hear someone fall."), 2)
				adjustBruteLoss(damage)
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(SPAN("danger", "\The [M] has attempted to punch \the [src]!"), 1)
	return

/mob/living/carbon/alien/ex_act(severity)
	if(!blinded)
		flash_eyes()
	var/b_loss = 0
	var/f_loss = 0
	switch(severity)
		if(1.0)
			b_loss += 500
			gib()
			return
		if(2.0)
			b_loss += 60
			f_loss += 60
			ear_damage += 30
			ear_deaf += 120
		if(3.0)
			b_loss += 30
			if(prob(50))
				Paralyse(1)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

/mob/living/carbon/alien/adjustBruteLoss(damage)
	..()
	updatehealth()

/mob/living/carbon/alien/adjustFireLoss(damage)
	..()
	updatehealth()

/mob/living/carbon/alien/adjustToxLoss(damage)
	..()
	updatehealth()

/mob/living/carbon/alien/adjustOxyLoss(damage)
	..()
	updatehealth()
