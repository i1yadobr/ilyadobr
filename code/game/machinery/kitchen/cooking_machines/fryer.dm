/obj/machinery/cooker/fryer
	name = "deep fryer"
	desc = "Deep fried <i>everything</i>."
	icon_state = "fryer_off"
	cook_type = "deep fried"
	on_icon = "fryer_on"
	off_icon = "fryer_off"
	food_color = "#ffad33"

/obj/machinery/cooker/fryer/hurt_big_mob(mob/living/victim, mob/user)

	if(!istype(victim))
		return

	user.visible_message(SPAN("danger", "\The [user] starts pushing \the [victim] into \the [src]!"))
	icon_state = on_icon
	is_cooking = 1

	if(!do_mob(user, victim, 20))
		is_cooking = 0
		icon_state = off_icon
		return

	if(!victim || !victim.Adjacent(user))
		to_chat(user, SPAN("danger", "Your victim slipped free!"))
		is_cooking = 0
		icon_state = off_icon
		return

	var/target_zone = user.zone_sel.selecting
	if(ishuman(victim) && !(target_zone in list(BP_GROIN, BP_CHEST)))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/E = H.get_organ(target_zone)
		if(!E)
			to_chat(user, SPAN("warning", "They are missing that body part!"))
		else
			visible_message(SPAN("danger", "\The [user] shoves \the [victim][E ? "'s [E.name]" : ""] into \the [src]!"))
			var/blocked = H.run_armor_check(target_zone, "energy")
			H.apply_damage(rand(20,30), BURN, target_zone, blocked)

	else
		var/blocked = victim.run_armor_check(null, "energy")
		victim.apply_damage(rand(30,40), BURN, null, blocked)

	if(victim)
		admin_attack_log(user, victim, "Has [cook_type] their victim in \a [src]", "Has been [cook_type] in \a [src] by the attacker.", "[cook_type], in \a [src], ")

	icon_state = off_icon
	is_cooking = 0
	return
