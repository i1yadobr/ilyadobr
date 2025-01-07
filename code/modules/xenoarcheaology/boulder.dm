// TODO(rufus): unify /obj/structure/boulder, /obj/structure/rock, and /obj/strucutre/rubble,
//   they are just reskins of the same thing
/obj/structure/boulder
	name = "rocky debris"
	desc = "Leftover rock from an excavation, it's been partially dug out already but there's still a lot to go."
	icon = 'icons/obj/mining.dmi'
	icon_state = "boulder1"
	density = 1
	opacity = 1
	anchored = 1
	var/excavation_level = 0
	var/datum/geosample/geological_data
	var/datum/artifact_find/artifact_find

/obj/structure/boulder/New()
	..()
	icon_state = "boulder[rand(1,4)]"
	excavation_level = rand(5, 50)

/obj/structure/boulder/Destroy()
	qdel(geological_data)
	qdel(artifact_find)

	return ..()

/obj/structure/boulder/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/core_sampler))
		src.geological_data.artifact_distance = rand(-100,100) / 100
		src.geological_data.artifact_id = artifact_find.artifact_id

		var/obj/item/device/core_sampler/C = I
		C.sample_item(src, user)
		return

	if(istype(I, /obj/item/device/depth_scanner))
		var/obj/item/device/depth_scanner/C = I
		C.scan_atom(user, src)
		return

	if(istype(I, /obj/item/device/measuring_tape))
		var/obj/item/device/measuring_tape/P = I
		user.visible_message(SPAN("notice", "\The [user] extends \the [P] towards \the [src]."), SPAN("notice", "You extend \the [P] towards \the [src]."))
		if(do_after(user, 15))
			to_chat(user, SPAN("notice", "\The [src] has been excavated to a depth of [src.excavation_level]cm."))
		return

	if(istype(I, /obj/item/pickaxe/drill))
		if(!user.canClick())
			return
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		var/obj/item/pickaxe/drill/D = I
		to_chat(user, SPAN("warning", "You start [D.drill_verb] [src]."))
		if(!do_after(user, D.dig_delay))
			return
		to_chat(user, SPAN("notice", "You finish [D.drill_verb] [src]."))
		qdel(src)
		return

		// TODO(rufus): how does this even make sense with the drill update?
		//   Historically you would carefully uncover the artifact and then, quoting an old contributor
		//   from mine_turfs.dm, "pick hits that edge just right, you extract your find perfectly".
		//   And now what? You carefully drill the item out with an industrial drill? Nuh-uh. Needs to be fixed.
		//   Yes, even if this breaks xenoarchology from digging up artifacts from boulders, still commenting this out for now.

		// excavation_level += D.excavation_amount

		// if(excavation_level > 200)
		// 	//failure
		// 	user.visible_message(SPAN("warning", "\The [src] suddenly crumbles away."), SPAN("warning", "\The [src] has disintegrated under your onslaught, any secrets it was holding are long gone."))
		// 	qdel(src)
		// 	return

		// if(prob(excavation_level))
		// 	//success
		// 	if(artifact_find)
		// 		var/spawn_type = artifact_find.artifact_find_type
		// 		var/obj/O = new spawn_type(get_turf(src))
		// 		if(istype(O, /obj/machinery/artifact))
		// 			var/obj/machinery/artifact/X = O
		// 			if(X.main_effect)
		// 				X.main_effect.artifact_id = artifact_find.artifact_id
		// 		src.visible_message(SPAN("warning", "\The [src] suddenly crumbles away."))
		// 	else
		// 		user.visible_message(SPAN("warning", "\The [src] suddenly crumbles away."), SPAN("notice", "\The [src] has been whittled away under your careful excavation, but there was nothing of interest inside."))

	if(istype(I, /obj/item/pickaxe))
		// TODO(rufus): research and apply a proper way to apply cooldown for both drills and pickaxes
		//   on /obj/structure/boulder, /obj/structure/rock, and /obj/strucutre/rubble
		if(!user.canClick())
			return
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		var/obj/item/pickaxe/P = I
		if(!P.mining_power)
			to_chat(user, "While you're using a pickaxe-like thing, there's no way this flimsy tool will be able to strike through \a [src.name]")
			return
		playsound(user, P.drill_sound, 20, 1)
		// basic pickaxe is 10 and silver is 30, gold at 50 and diamond at 80 bypass the check
		if(P.mining_power <= 30)
			if(prob(100-P.mining_power)) // basic pickaxes *should* be annoying to use, this makes 70-90% chance to fail
				to_chat(user, "Despite your skill, \the [src] proves to be a formidable challenge for your basic [I.name], refusing to break.")
				return
			to_chat(user, "With some struggle on impact, you manage to hit \the [src] at the right spot and clear it out of the way.")
			qdel(src)
			return
		to_chat(user, "With a decisive strike, you demolish \the [src] into tiny pieces as if it's nothing.")
		qdel(src)
		return

/obj/structure/boulder/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		var/obj/item/pickaxe/P = H.get_inactive_hand()
		if(istype(P))
			src.attackby(P, H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/pickaxe))
			attackby(R.module_active,R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)
