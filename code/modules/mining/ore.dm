/obj/item/ore
	name = "small rock"
	icon = 'icons/obj/mining.dmi'
	icon_state = "ore2"
	randpixel = 10
	w_class = ITEM_SIZE_SMALL
	var/datum/geosample/geologic_data
	var/ore/ore = null // set to a type to find the right instance on init

/obj/item/ore/Initialize()
	. = ..()
	if(ispath(ore))
		ensure_ore_data_initialised()
		ore = ores_by_type[ore]
		if(ore.ore != type)
			log_error("[src] ([src.type]) had ore type [ore.type] but that type does not have [src.type] set as its ore item!")
		update_ore()

/obj/item/ore/proc/update_ore()
	SetName(ore.display_name)
	icon_state = "ore_[ore.icon_tag]"
	origin_tech = ore.origin_tech.Copy()

/obj/item/ore/Value(base)
	. = ..()
	if(!ore)
		return
	var/material/M
	if(ore.smelts_to)
		M = get_material_by_name(ore.smelts_to)
	else if (ore.compresses_to)
		M = get_material_by_name(ore.compresses_to)
	if(!istype(M))
		return
	return 0.5*M.value*ore.result_amount

/obj/item/ore/slag
	name = "slag"
	desc = "Someone screwed up..."
	icon_state = "slag"

/obj/item/ore/uranium
	ore = /ore/uranium

/obj/item/ore/uranium/Initialize()
	. = ..()

	create_reagents()
	reagents.add_reagent(/datum/reagent/uranium, ore.result_amount, null, FALSE)

/obj/item/ore/iron
	ore = /ore/hematite

/obj/item/ore/coal
	ore = /ore/coal

/obj/item/ore/glass
	ore = /ore/glass
	slot_flags = SLOT_HOLSTER

// POCKET SAND!
/obj/item/ore/glass/throw_impact(atom/hit_atom)
	..()
	var/mob/living/carbon/human/H = hit_atom
	if(istype(H) && H.has_eyes() && prob(85))
		to_chat(H, "<span class='danger'>Some of \the [src] gets in your eyes!</span>")
		H.eye_blind += 5
		H.eye_blurry += 10
		spawn(1)
			if(istype(loc, /turf/)) qdel(src)


/obj/item/ore/plasma
	ore = /ore/plasma

/obj/item/ore/silver
	ore = /ore/silver

/obj/item/ore/gold
	ore = /ore/gold

/obj/item/ore/diamond
	ore = /ore/diamond

/obj/item/ore/osmium
	ore = /ore/platinum

/obj/item/ore/hydrogen
	ore = /ore/hydrogen

/obj/item/ore/attackby(obj/item/W, mob/user)
	if(istype(W, /obj/item/device/core_sampler))
		var/obj/item/device/core_sampler/C = W
		C.sample_item(src, user)
		return
	if(istype(W, /obj/item/pickaxe))
		// TODO(rufus): test if the messages below need to stay as SPAN_NOTICE,
		//   basically figure out if they work with chat filters properly or not
		var/datum/gender/G = gender_datums[user.get_visible_gender()]
		if(istype(src, /obj/item/ore/glass)) // "glass" ore is sand, duh
			user.visible_message(
					SPAN_NOTICE("[user] strikes [src.name] with [G.his] [W.name], [pick("not much happens.", "[G.he] look[G.s] rather foolish.", "a moment of confusion ensues.", "[G.his] reasoning nowhere to be found.", "bravo for the effort!", "tremendous effort, little result.")]"),
					SPAN_NOTICE("You strike [src.name] with your [W.name] and [pick("contemplate life.", "wonder why you did that.", "feel a bit uncertain...", "probably look a bit silly.", "feel a bit empty inside.", "think you should probably do it again.")]"),
					SPAN_NOTICE("You hear a swing followed by the crunch of sand under something solid.")
				)
			return
		if(istype(src, /obj/item/ore/slag))
			to_chat(user, SPAN_NOTICE("You obliterate the remaining husk of a once-ore, crushing it with your [W.name]."))
			qdel(src)
			return
		var/luck = rand(1, 100)
		switch(luck)
			if(1 to 10)
				user.visible_message(
					SPAN_NOTICE("As [user] strikes [src.name] with [G.his] [W.name], the ore jostles unexpectedly and strikes [G.him]."),
					SPAN_DANGER("As you strike [src.name] with your [W.name], the ore jostles unexpectedly and strikes you."),
					SPAN_NOTICE("A loud clink and a subsequent thud echo around.")
				)
				src.throw_at(user, 3)
			if(11 to 30)
				user.visible_message(
					SPAN_NOTICE("As [user] strikes [src.name] with [G.his] [W.name], the ore crumbles into dust and tiny pieces."),
					SPAN_DANGER("As you strike [src.name] with your [W.name], it crumbles into dust and tiny pieces."),
					SPAN_NOTICE("A sharp clink can be heard nearby, followed by the sound of crumbling.")
				)
				qdel(src)
			if(31 to 40)
				user.visible_message(
					SPAN_NOTICE("[user] strikes [src.name] with [G.his] [W.name] and manages to destroy all the valuable ore from it, leaving an empty rocky husk."),
					SPAN_DANGER("You strike [src.name] with your [W.name] and manage to destroy all the valuable ore from it, leaving an empty rocky husk."),
					SPAN_NOTICE("A sharp clink can be heard nearby, and a pathetic echo of crumbling settles right after.")
				)
				new /obj/item/ore/slag(src.loc)
				qdel(src)
			if(41 to 95)
				user.visible_message(
					SPAN_NOTICE("[user] strikes [src.name] with [G.his] [W.name] and it jostles around."),
					SPAN_NOTICE("You strike [src.name] with your [W.name] and it jostles around."),
					SPAN_NOTICE("You hear a sharp clink followed by the muffled bouncing of rocks.")
				)
				src.throw_at(src.loc, 0, 1)
			if(96 to 98)
				var/list/material/materials = list()
				if(src.ore?.smelts_to)
					materials += get_material_by_name(src.ore.smelts_to)
				if(src.ore?.compresses_to)
					materials += get_material_by_name(src.ore.compresses_to)
				var/material/M
				if(materials.len)
					M = pick(materials)
				if(!istype(M))
					user.visible_message(
						SPAN_NOTICE("[user] forcefully strikes [src.name] with [G.his] [W.name] and manages to destroy all the valuable ore from it, leaving an empty rocky husk."),
						SPAN_DANGER("You forcefully strike [src.name] with your [W.name] and manage to destroy all the valuable ore from it, leaving an empty rocky husk."),
						SPAN_NOTICE("A forceful clink can be heard nearby, and a pathetic echo of crumbling settles right after.")
					)
					new /obj/item/ore/slag(src.loc)
					qdel(src)
				else
					user.visible_message(
						SPAN_NOTICE("[user] lands a forceful strike of [G.his] [W.name] on [src.name] and manages to extract a clean shiny piece of [M.name] from it."),
						SPAN_NOTICE("You land a forceful strike of your [W.name] on [src.name] and manage to extract a clean shiny piece of [M.name] from it."),
						SPAN_NOTICE("A sound of a foceful clink reverberates around.")
					)
					new M.stack_type(src.loc)
					qdel(src)
			if(99 to 100)
				var/list/material/materials = list()
				if(src.ore?.smelts_to)
					materials += get_material_by_name(src.ore.smelts_to)
				if(src.ore?.compresses_to)
					materials += get_material_by_name(src.ore.compresses_to)
				var/material/M
				if(materials.len)
					M = pick(materials)
				if(!istype(M))
					user.visible_message(
						SPAN_NOTICE("[user] lands a strike of ultimate precision on [src.name] with [G.his] [W.name] and manages to destroy all the valuable ore from it, leaving an empty rocky husk."),
						SPAN_DANGER("You land a strike of ultimate precision on [src.name] with your [W.name] and manage to destroy all the valuable ore from it, leaving an empty rocky husk."),
						SPAN_NOTICE("A clink of ultimate precision can be heard nearby, and a pathetic echo of crumbling settles right after.")
					)
					new /obj/item/ore/slag(src.loc)
					qdel(src)
				else
					user.visible_message(
						SPAN_NOTICE("As [user] unleashes a powerful swing of [G.his] [W.name] with ultimate precision, [src.name] obediently crumbles into a small cloud of dust, under which an unexpected amount of shiny pieces of [M.name] reveal themselves."),
						SPAN_NOTICE("As you unleash a powerful swing of your [W.name] with ultimate precision, [src.name] obediently crumbles into a small cloud of dust, under which an unexpected amount of shiny pieces of [M.name] reveal themselves."),
						SPAN_NOTICE("An ultimately precise and echoey clink resonates from every surface around you.")
					)
					var/num = rand(2, 5)
					for(var/i = 1 to num)
						new M.stack_type(src.loc)
					qdel(src)

	return ..()
