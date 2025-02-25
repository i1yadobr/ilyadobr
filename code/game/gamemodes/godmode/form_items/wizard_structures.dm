/obj/structure/deity/wizard_recharger
	name = "fountain of power"
	desc = "Refreshing, cool water surrounded by archaic carvings."
	icon_state = "fountain"
	power_adjustment = 2
	build_cost = 700

/obj/structure/deity/wizard_recharger/attack_hand(mob/living/hitter)
	if(!hitter.mind || !hitter.mind.learned_spells || !hitter.mind.learned_spells.len)
		to_chat(hitter, SPAN("warning", "You don't feel as if this will do anything for you."))
		return

	hitter.visible_message(SPAN("notice", "\The [hitter] dips their hands into \the [src], a soft glow emanating from them."))
	if(do_after(hitter,600,src,needhand=0))
		for(var/s in hitter.mind.learned_spells)
			var/datum/spell/spell = s
			switch(spell.charge_type)
				if(SP_RECHARGE)
					spell.charge_counter = spell.charge_max
				if(SP_CHARGES)
					spell.charge_counter = min(spell.charge_counter + 1, spell.charge_max)
		to_chat(hitter, SPAN("notice", "You feel refreshed!"))
		return
	to_chat(hitter,SPAN("warning", "You need to keep in contact with \the [src]!"))
