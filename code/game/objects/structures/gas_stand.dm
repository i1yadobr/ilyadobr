/obj/structure/gas_stand
	name = "gas stand"
	icon = 'icons/obj/gas_stand.dmi'
	desc = "Gas stand with retractable gas mask."
	icon_state = "gas_stand_idle"
	pull_slowdown = PULL_SLOWDOWN_TINY

	var/obj/item/tank/tank
	var/mob/living/carbon/breather
	var/obj/item/clothing/mask/breath/contained

	var/spawn_type = null
	var/mask_type = /obj/item/clothing/mask/breath/anesthetic

	var/is_loosen = TRUE
	var/valve_opened = FALSE

/obj/structure/gas_stand/New()
	..()
	if (spawn_type)
		tank = new spawn_type (src)
	contained = new mask_type (src)
	update_icon()

/obj/structure/gas_stand/update_icon()
	if (breather)
		icon_state = "gas_stand_inuse"
	else
		icon_state = "gas_stand_idle"

	overlays.Cut()

	if (tank)
		if(istype(tank,/obj/item/tank/anesthetic))
			overlays += "tank_anest"
		else if(istype(tank,/obj/item/tank/nitrogen))
			overlays += "tank_nitro"
		else if(istype(tank,/obj/item/tank/oxygen))
			overlays += "tank_oxyg"
		else if(istype(tank,/obj/item/tank/plasma))
			overlays += "tank_plasma"
		else if(istype(tank,/obj/item/tank/hydrogen))
			overlays += "tank_hydro"
		else
			overlays += "tank_other"

/obj/structure/gas_stand/Destroy()
	if(breather)
		breather.internal = null
		if(breather.internals)
			breather.internals.icon_state = "internal0"
	if(tank)
		qdel(tank)
	if(breather)
		breather.drop(contained)
		visible_message(SPAN("notice", "The mask rapidly retracts just before \the [src] is destroyed!"))
	qdel(contained)
	contained = null
	breather = null
	return ..()

/obj/structure/gas_stand/attack_robot(mob/user)
	if(Adjacent(user))
		attack_hand(user)

/obj/structure/gas_stand/MouseDrop(mob/living/carbon/human/target, src_location, over_location)
	..()
	if(istype(target) && CanMouseDrop(target))
		if(!can_apply_to_target(target, usr)) // There is no point in attempting to apply a mask if it's impossible.
			return
		usr.visible_message("\The [usr] begins placing the mask onto [target]..")
		if(!do_mob(usr, target, 25) || !can_apply_to_target(target, usr))
			return
		// place mask and add fingerprints
		usr.visible_message("\The [usr] has placed \the mask on [target]'s mouth.")
		attach_mask(target)
		src.add_fingerprint(usr)
		update_icon()
		set_next_think(world.time)

/obj/structure/gas_stand/attack_hand(mob/user as mob)
	if (tank && is_loosen)
		user.visible_message(SPAN("notice", "\The [user] removes \the [tank] from \the [src]."), SPAN("notice", "You remove \the [tank] from \the [src]."))
		user.pick_or_drop(tank)
		src.add_fingerprint(user)
		tank.add_fingerprint(user)
		tank = null
		update_icon()
		return
	if (!tank)
		to_chat(user, SPAN("warning", "There is no tank in \the [src]!"))
		return
	else
		if (valve_opened)
			src.visible_message(SPAN("notice", "\The [user] closes valve on \the [src]!"))
			if(breather)
				if(breather.internals)
					breather.internals.icon_state = "internal0"
				breather.internal = null
			valve_opened = FALSE
			update_icon()
		else
			src.visible_message(SPAN("notice", "\The [user] opens valve on \the [src]!"))
			if(breather)
				breather.internal = tank
				if(breather.internals)
					breather.internals.icon_state = "internal1"
			valve_opened = TRUE
			playsound(src, 'sound/effects/internals.ogg', 100, 1)
			update_icon()
			set_next_think(world.time)

/obj/structure/gas_stand/proc/attach_mask(mob/living/carbon/C)
	if(C && istype(C))
		contained.forceMove(get_turf(C))
		C.equip_to_slot(contained, slot_wear_mask)
		if(tank)
			tank.forceMove(C)
		breather = C

/obj/structure/gas_stand/proc/can_apply_to_target(mob/living/carbon/human/target, mob/user as mob)
	if(!user)
		user = target
	// Check target validity
	if(!target.organs_by_name[BP_HEAD])
		to_chat(user, SPAN("warning", "\The [target] doesn't have a head."))
		return
	if(!target.check_has_mouth())
		to_chat(user, SPAN("warning", "\The [target] doesn't have a mouth."))
		return
	if(target.wear_mask && target != breather)
		to_chat(user, SPAN("warning", "\The [target] is already wearing a mask."))
		return
	if(target.head && (target.head.body_parts_covered & FACE))
		to_chat(user, SPAN("warning", "Remove their [target.head] first."))
		return
	if(!tank)
		to_chat(user, SPAN("warning", "There is no tank in \the [src]."))
		return
	if(is_loosen)
		to_chat(user, SPAN("warning", "Tighten \the nut with a wrench first."))
		return
	if(!Adjacent(target))
		return
	//when there is a breather:
	if(breather && target != breather)
		to_chat(user, SPAN("warning", "\The [src] is already in use."))
		return
	//Checking if breather is still valid
	if(target == breather && target.wear_mask != contained)
		to_chat(user, SPAN("warning", "\The [target] is not using the supplied mask."))
		return
	return 1

/obj/structure/gas_stand/attackby(obj/item/W as obj, mob/user as mob)
	if(isWrench(W))
		if (valve_opened)
			to_chat(user, SPAN("warning", "Close the valve first."))
			return
		if (tank)
			if (!is_loosen)
				is_loosen = TRUE
			else
				is_loosen = FALSE
				if (valve_opened)
					set_next_think(world.time)
			user.visible_message(SPAN("notice", "\The [user] [is_loosen == TRUE ? "loosen" : "tighten"] \the nut holding [tank] in place."), SPAN("notice", "You [is_loosen == TRUE ? "loosen" : "tighten"] \the nut holding [tank] in place."))
			return
		else
			to_chat(user, SPAN("warning", "There is no tank in \the [src]."))
			return

	if(istype(W, /obj/item/tank))
		if(tank)
			to_chat(user, SPAN("warning", "\The [src] already has a tank installed!"))
		else if(!is_loosen)
			to_chat(user, SPAN("warning", "Loosen the nut with a wrench first."))
		else if(user.drop(W, src))
			tank = W
			user.visible_message(SPAN("notice", "\The [user] attaches \the [tank] to \the [src]."), SPAN("notice", "You attach \the [tank] to \the [src]."))
			add_fingerprint(user)
			update_icon()

/obj/structure/gas_stand/_examine_text(mob/user)
	. = ..()
	if(tank)
		if (!is_loosen)
			. += "\n\The [tank] connected to it."
		. += "\nThe meter shows [round(tank.air_contents.return_pressure())]. The valve is [valve_opened == TRUE ? "open" : "closed"]."
		if (tank.distribute_pressure == 0)
			. += "\nUse wrench to replace tank."
	else
		. += "\n"
		. += SPAN("warning", "It is missing a tank!")

/obj/structure/gas_stand/think()
	if(breather)
		if(!can_apply_to_target(breather))
			if(tank)
				tank.forceMove(src)
			if(breather.wear_mask == contained)
				breather.drop(contained, src)
			else
				qdel(contained)
				contained = new mask_type(src)
			src.visible_message(SPAN("notice", "\The [contained] slips to \the [src]!"))
			breather = null
			update_icon()
			return
		if(valve_opened)
			if (tank)
				breather.internal = tank
				if(breather.internals)
					breather.internals.icon_state = "internal1"
		else
			if(breather.internals)
				breather.internals.icon_state = "internal0"
			breather.internal = null
	else if (valve_opened)
		var/datum/gas_mixture/removed = tank.remove_air(0.01)
		var/datum/gas_mixture/environment = loc.return_air()
		environment.merge(removed)
		if (tank.distribute_pressure == 0 && !breather)
			return
	else
		return

	set_next_think(world.time + 1 SECOND)

/obj/structure/gas_stand/anesthetic
	icon_state = "gas_stand_idle"
	name = "anaesthetic machine"
	desc = "Anaesthetic machine used to support the administration of anaesthesia ."
	spawn_type = /obj/item/tank/anesthetic
	mask_type = /obj/item/clothing/mask/breath/anesthetic
	is_loosen = FALSE
