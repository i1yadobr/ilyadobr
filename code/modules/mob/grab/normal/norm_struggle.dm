/datum/grab/normal/struggle
	state_name = NORM_STRUGGLE
	fancy_desc = "holding"

	upgrab_name = NORM_AGGRESSIVE
	downgrab_name = NORM_PASSIVE

	shift = 8

	stop_move = 1
	can_absorb = 0
	point_blank_mult = 1
	same_tile = 0
	breakability = 3

	grab_slowdown = 10
	upgrade_cooldown = 20

	can_downgrade_on_resist = 0

	icon_state = "reinforce"

	break_chance_table = list(5, 20, 30, 80, 100)


/datum/grab/normal/struggle/process_effect(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant

	if(affecting.incapacitated() || affecting.a_intent == I_HELP)
		affecting.visible_message(SPAN("warning", "[affecting] isn't prepared to fight back as [assailant] tightens \his grip!"))
		G.done_struggle = TRUE
		G.upgrade(TRUE)

/datum/grab/normal/struggle/enter_as_up(obj/item/grab/G)
	var/mob/living/carbon/human/affecting = G.affecting
	var/mob/living/carbon/human/assailant = G.assailant

	if(affecting.incapacitated() || affecting.a_intent == I_HELP)
		affecting.visible_message(SPAN("warning", "[affecting] isn't prepared to fight back as [assailant] tightens \his grip!"))
		G.done_struggle = TRUE
		G.upgrade(TRUE)
	else
		affecting.visible_message(SPAN("warning", "[affecting] struggles against [assailant]!"))
		G.done_struggle = FALSE
		addtimer(CALLBACK(G, nameof(.proc/handle_resist)), 1 SECOND)
		resolve_struggle(G)

/datum/grab/normal/struggle/proc/resolve_struggle(obj/item/grab/G)
	set waitfor = FALSE
	if(do_after(G.assailant, upgrade_cooldown, G, can_move = 1))
		G.done_struggle = TRUE
		G.upgrade(TRUE)
	else
		G.downgrade()

/datum/grab/normal/struggle/can_upgrade(obj/item/grab/G)
	return G.done_struggle

/datum/grab/normal/struggle/on_hit_disarm(obj/item/grab/normal/G)
	to_chat(G.assailant, SPAN("warning", "Your grip isn't strong enough to pin."))
	return 0

/datum/grab/normal/struggle/on_hit_grab(obj/item/grab/normal/G)
	to_chat(G.assailant, SPAN("warning", "Your grip isn't strong enough to jointlock."))
	return 0

/datum/grab/normal/struggle/on_hit_harm(obj/item/grab/normal/G)
	to_chat(G.assailant, SPAN("warning", "Your grip isn't strong enough to dislocate."))
	return 0

/datum/grab/normal/struggle/resolve_openhand_attack(obj/item/grab/G)
	return 0
