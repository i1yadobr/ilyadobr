/atom/proc/attack_generic(mob/user as mob)
// Generic damage proc (metroids and monkeys).
	return FALSE

/atom/proc/attack_hand(mob/user as mob)
	return

/mob/living/carbon/human/RangedAttack(atom/A)
	// Standing below an open space and clicking an adjacent turf above allows you to climb.
	// Intended to be used with the "Look Up" verb.
	// Must be able to overcome gravity or have something climbable below you, see can_overcome_gravity().
	if((istype(A, /turf/simulated/floor) || istype(A, /turf/unsimulated/floor) || istype(A, /obj/structure/lattice) || istype(A, /obj/structure/catwalk)) && isturf(loc) && shadow && !is_physically_disabled()) //Climbing through openspace
		var/turf/T = get_turf(A)
		var/turf/above = shadow.loc
		if(T.Adjacent(shadow) && above.CanZPass(src, UP)) //Certain structures will block passage from below, others not

			var/area/location = get_area(loc)
			if(location.has_gravity && !can_overcome_gravity())
				return

			visible_message(SPAN("notice", "[src] starts climbing onto \the [A]!"), SPAN("notice", "You start climbing onto \the [A]!"))
			shadow.visible_message(SPAN("notice", "[shadow] starts climbing onto \the [A]!"))
			if(do_after(src, 50, A))
				visible_message(SPAN("notice", "[src] climbs onto \the [A]!"), SPAN("notice", "You climb onto \the [A]!"))
				shadow.visible_message(SPAN("notice", "[shadow] climbs onto \the [A]!"))
				src.Move(T)
			else
				visible_message(SPAN("warning", "[src] gives up on trying to climb onto \the [A]!"), SPAN("warning", "You give up on trying to climb onto \the [A]!"))
				shadow.visible_message(SPAN("warning", "[shadow] gives up on trying to climb onto \the [A]!"))
			return

	if(!gloves && !mutations.len) return
	var/obj/item/clothing/gloves/G = gloves
	if((MUTATION_LASER in mutations) && a_intent == I_HURT)
		LaserEyes(A)

	else if(istype(G) && G.Touch(A,0)) // for magic gloves
		return

	else if(MUTATION_TK in mutations)
		A.attack_tk(src)
