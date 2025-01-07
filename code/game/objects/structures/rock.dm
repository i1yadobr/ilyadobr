/obj/structure/rock
	name = "huge rock"
	desc = "Huge rocky chunk of asteroid minerals."
	icon = 'icons/turf/asteroid.dmi'
	icon_state = "asteroid_bigstone1"
	opacity = 0
	density = 1
	anchored = 1
	var/list/iconlist = list("asteroid_bigstone1","asteroid_bigstone2","asteroid_bigstone3","asteroid_bigstone4")
	var/health = 40

/obj/structure/rock/New()
	..()
	icon_state = pick(iconlist)

/obj/structure/rock/Destroy()
	var/mineralSpawnChanceList = list(uranium = 10, osmium = 10, iron = 20, coal = 20, diamond = 2, gold = 10, silver = 10, plasma = 20)
	if(prob(20))
		var/mineral_name = util_pick_weight(mineralSpawnChanceList) //temp mineral name
		mineral_name = lowertext(mineral_name)
		var/ore = text2path("/obj/item/ore/[mineral_name]")
		for(var/i=1,i <= rand(2,6),i++)
			new ore(get_turf(src))
	return ..()

/obj/structure/rock/attackby(obj/item/I, mob/user)
	if(isMonkey(user))
		to_chat(user, SPAN("warning", "You don't have the dexterity to do this!"))
		return
	if(istype(I, /obj/item/pickaxe/drill))
		if(!user.canClick())
			return
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		if(!istype(user.loc, /turf))
			return
		var/obj/item/pickaxe/drill/D = I
		playsound(user, D.drill_sound, 20, 1)
		to_chat(user, SPAN("notice", "You start [D.drill_verb]."))
		if(do_after(user, D.dig_delay, src))
			to_chat(user, SPAN("notice", "You finish [D.drill_verb] \the [src]."))
			qdel(src)
		return
	if(istype(I, /obj/item/pickaxe))
		if(!user.canClick())
			return
		user.setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		var/obj/item/pickaxe/P = I
		playsound(user, P.drill_sound, 20, 1)
		// basic pickaxe is 10 and silver is 30, gold at 50 and diamond at 80 bypass the check
		if(P.mining_power <= 30)
			if(prob(100-P.mining_power)) // basic pickaxes *should* be annoying to use, this makes 70-90% chance to fail
				to_chat(user, "Despite your skill, \the [src] proves to be a formidable challenge for your basic [I.name], refusing to break.")
				return
			to_chat(user, "With some struggle on impact, you manage to crack \the [src] and clear it out of the way.")
			qdel(src)
			return
		to_chat(user, "With a decisive strike, you demolish \the [src] into tiny pieces as if it's nothing.")
		qdel(src)
		return
	return ..()

/obj/structure/rock/Bumped(AM)
	. = ..()
	if(istype(AM,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if((istype(H.l_hand,/obj/item/pickaxe)) && (!H.hand))
			attackby(H.l_hand,H)
		else if((istype(H.r_hand,/obj/item/pickaxe)) && H.hand)
			attackby(H.r_hand,H)

	else if(istype(AM,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = AM
		if(istype(R.module_active,/obj/item/pickaxe))
			attackby(R.module_active,R)

	else if(istype(AM,/obj/mecha))
		var/obj/mecha/M = AM
		if(istype(M.selected,/obj/item/mecha_parts/mecha_equipment/tool/drill))
			M.selected.action(src)
