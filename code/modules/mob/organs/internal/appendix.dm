/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	parent_organ = BP_GROIN
	organ_tag = BP_APPENDIX
	var/inflamed = 0

/obj/item/organ/internal/appendix/update_icon()
	..()
	if(inflamed)
		icon_state = "appendix-inflamed"
		SetName("inflamed appendix")

/obj/item/organ/internal/appendix/think()
	..()
	if(!owner)
		return
	if(!isundead(owner) && inflamed)
		inflamed++
		if(prob(5))
			if(owner.can_feel_pain())
				owner.custom_pain("You feel a stinging pain in your abdomen!")
				if(owner.can_feel_pain())
					owner.visible_message("<B>\The [owner]</B> winces slightly.")
		if(inflamed > 200)
			if(prob(3))
				take_internal_damage(0.1)
				if(owner.can_feel_pain())
					owner.visible_message("<B>\The [owner]</B> winces painfully.")
				owner.adjustToxLoss(1)
		if(inflamed > 400)
			if(prob(1))
				germ_level += rand(2,6)
				if (owner.nutrition > 100)
					owner.vomit()
				else
					to_chat(owner, SPAN("danger", "You gag as you want to throw up, but there's nothing in your stomach!"))
					owner.Weaken(10)
					owner.Stun(10)
		if(inflamed > 600)
			if(prob(1))
				if(owner.can_feel_pain())
					owner.custom_pain("You feel a stinging pain in your abdomen!")
					owner.Weaken(10)
					owner.Stun(10)

				var/obj/item/organ/external/E = owner.get_organ(parent_organ)
				E.sever_artery()
				E.germ_level = max(INFECTION_LEVEL_TWO, E.germ_level)
				owner.adjustToxLoss(25)
				removed()
				qdel(src)
