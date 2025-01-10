// TODO(rufus): move code from this file to an appropriate location or refactor into one of the existing systems for abilities.
//   Laser eyes is a legacy ability triggered on RangedAttack() if user has MUTATION_LASER set.

/mob/proc/LaserEyes(atom/A)
	return

/mob/living/LaserEyes(atom/A)
	setClickCooldown(DEFAULT_QUICK_COOLDOWN)
	var/turf/T = get_turf(src)

	var/obj/item/projectile/beam/LE = new (T)
	LE.icon = 'icons/effects/genetics.dmi'
	LE.icon_state = "eyelasers"
	playsound(usr.loc, 'sound/effects/weapons/energy/taser2.ogg', 75, 1)
	LE.launch(A)

/mob/living/carbon/human/LaserEyes()
	if(nutrition>0)
		..()
		nutrition = max(nutrition - rand(1,5),0)
		handle_regular_hud_updates()
	else
		to_chat(src, SPAN("warning", "You're out of energy!  You need food!"))
