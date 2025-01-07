/mob/living/carbon/alien/diona/get_scooped(mob/living/carbon/grabber, self_grab)
	if(grabber.species && grabber.species.name == SPECIES_DIONA && do_merge(grabber))
		return
	else return ..()

/mob/living/carbon/alien/diona/MouseDrop(atom/over_object)
	var/mob/living/carbon/H = over_object

	if(istype(H) && Adjacent(H) && (usr == H) && (H.a_intent == "grab") && hat && !(H.l_hand && H.r_hand))
		H.pick_or_drop(hat, loc)
		H.visible_message(SPAN("danger", "\The [H] removes \the [src]'s [hat]."))
		hat = null
		update_icons()
		return

	return ..()

/mob/living/carbon/alien/diona/attackby(obj/item/W, mob/user)
	if(user.a_intent == I_HELP && istype(W, /obj/item/clothing/head))
		if(hat)
			to_chat(user, SPAN("warning", "\The [src] is already wearing \the [hat]."))
			return
		user.drop(W)
		wear_hat(W)
		user.visible_message(SPAN("notice", "\The [user] puts \the [W] on \the [src]."))
		return
	return ..()
