/datum/grab/normal/aggressive
	state_name = NORM_AGGRESSIVE

	upgrab_name = NORM_NECK
	downgrab_name = NORM_PASSIVE

	shift = 12


	stop_move = 1
	can_absorb = 0
	shield_assailant = 0
	point_blank_mult = 1
	same_tile = 0
	can_throw = 1
	force_danger = 1
	breakability = 3

	icon_state = "reinforce1"

	break_chance_table = list(5, 20, 40, 80, 100)

/datum/grab/normal/aggressive/process_effect(obj/item/grab/G)
	if(!G.affecting)
		return
	var/mob/living/carbon/human/affecting = G.affecting

	if(G.target_zone in list(BP_L_HAND, BP_R_HAND))
		if(affecting.can_unequip(affecting.l_hand))
			affecting.drop_l_hand()
		if(affecting.can_unequip(affecting.r_hand))
			affecting.drop_r_hand()

	// Keeps those who are on the ground down
	if(affecting.lying)
		affecting.Weaken(2)
		affecting.Stun(2)

/datum/grab/normal/aggressive/can_upgrade(obj/item/grab/G)
	if(!(G.target_zone in list(BP_CHEST, BP_HEAD)))
		to_chat(G.assailant, SPAN("warning", "You need to be grabbing their torso or head for this!"))
		return FALSE
	var/obj/item/clothing/C = G.affecting.head
	if(istype(C)) //powersuit helmets etc
		if((C.item_flags & ITEM_FLAG_STOPPRESSUREDAMAGE) && C.armor["melee"] > 20)
			to_chat(G.assailant, SPAN("warning", "\The [C] is in the way!"))
			return FALSE
	return TRUE
