/obj/machinery/computer/diseasesplicer
	name = "disease splicer"
	icon = 'icons/obj/computer.dmi'
	icon_keyboard = "med_key"
	icon_screen = "crew"
	component_types = list(
		/obj/item/stock_parts/micro_laser = 2,
		/obj/item/stock_parts/scanning_module,
		/obj/item/circuitboard/diseasesplicer
	)

	var/obj/item/virusdish/dish = null
	var/datum/disease2/effect/memorybank = null
	var/list/species_buffer = null

	var/analysed = 0
	var/burning = 0
	var/splicing = 0
	var/scanning = 0

	var/speed = 1

/obj/machinery/computer/diseasesplicer/Initialize()
	. = ..()
	RefreshParts()

/obj/machinery/computer/diseasesplicer/attackby(obj/O, mob/user)
	if(burning || splicing || scanning)
		to_chat(user, SPAN("notice", "\The [src] is busy. Please wait for completion of previous operation."))
		return 1
	if(dish)
		to_chat(user, SPAN("notice", "\The [src] is full. Please remove external items."))
		return 1
	if(default_deconstruction_screwdriver(user, O))
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return

	if(istype(O,/obj/item/virusdish))
		var/mob/living/carbon/c = user
		if (dish)
			to_chat(user, SPAN("notice", "\The [src] is already loaded."))
			return
		if(!c.drop(O, src))
			return
		dish = O

	if(istype(O,/obj/item/diseasedisk))
		to_chat(user, "You upload the contents of the disk onto the buffer.")
		var/obj/item/diseasedisk/disk = O
		memorybank = disk.effect
		species_buffer = disk.species
		analysed = disk.analysed

	src.attack_hand(user)

/obj/machinery/computer/diseasesplicer/attack_ai(mob/user)
	return src.attack_hand(user)

/obj/machinery/computer/diseasesplicer/attack_hand(mob/user)
	if(..()) return
	ui_interact(user)

/obj/machinery/computer/diseasesplicer/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	user.set_machine(src)

	var/data[0]
	data["dish_inserted"] = !!dish
	data["growth"] = 0
	data["affected_species"] = null

	if (memorybank)
		data["buffer"] = list("name" = (analysed ? memorybank.name : "Unknown Symptom"), "stage" = memorybank.stage)
	if (species_buffer)
		data["species_buffer"] = analysed ? jointext(species_buffer, ", ") : "Unknown Species"

	if (splicing)
		data["busy"] = "Splicing..."
	else if (scanning)
		data["busy"] = "Scanning..."
	else if (burning)
		data["busy"] = "Copying data to disk..."
	else if (dish)
		data["growth"] = min(dish.growth, 100)

		if (dish.virus2)
			if (dish.virus2.affected_species)
				data["affected_species"] = dish.analysed ? jointext(dish.virus2.affected_species, ", ") : "Unknown"

			if (dish.growth >= 50)
				var/list/effects[0]
				for (var/datum/disease2/effect/e in dish.virus2.effects)
					effects.Add(list(list("name" = (dish.analysed ? e.name : "Unknown"), "stage" = (e.stage), "reference" = "\ref[e]")))
				data["effects"] = effects
			else
				data["info"] = "Insufficient cell growth for gene splicing."
		else
			data["info"] = "No virus detected."
	else
		data["info"] = "No dish loaded."

	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "disease_splicer.tmpl", src.name, 400, 600)
		ui.set_initial_data(data)
		ui.open()

/obj/machinery/computer/diseasesplicer/Process()
	if(stat & (NOPOWER|BROKEN))
		return

	if(scanning)
		scanning -= 1*speed
		if(scanning <= 0)
			ping("\The [src] pings, \"Analysis complete.\"")
			SSnano.update_uis(src)

	if(splicing)
		splicing -= 1*speed
		if(splicing <= 0)
			ping("\The [src] pings, \"Splicing operation complete.\"")
			SSnano.update_uis(src)

	if(burning)
		burning -= 1*speed
		if(burning <= 0)
			var/obj/item/diseasedisk/d = new /obj/item/diseasedisk(src.loc)
			d.analysed = analysed
			if(analysed)
				if (memorybank)
					d.SetName("[memorybank.name] GNA disk (Stage: [memorybank.stage])")
					d.effect = memorybank
				else if (species_buffer)
					d.SetName("[jointext(species_buffer, ", ")] GNA disk")
					d.species = species_buffer
			else
				if (memorybank)
					d.SetName("Unknown GNA disk (Stage: [memorybank.stage])")
					d.effect = memorybank
				else if (species_buffer)
					d.SetName("Unknown Species GNA disk")
					d.species = species_buffer

			ping("\The [src] pings, \"Backup disk saved.\"")
			SSnano.update_uis(src)

/obj/machinery/computer/diseasesplicer/RefreshParts()
	var/T = 0
	for(var/obj/item/stock_parts/scanning_module/S in component_parts)
		T += S.rating
	for(var/obj/item/stock_parts/micro_laser/L in component_parts)
		T += L.rating
	speed = T/3

/obj/machinery/computer/diseasesplicer/OnTopic(user, href_list)
	if (href_list["close"])
		SSnano.close_user_uis(user, src, "main")
		return TOPIC_HANDLED

	if (href_list["grab"])
		if (dish)
			memorybank = locate(href_list["grab"])
			species_buffer = null
			analysed = dish.analysed
			dish = null
			scanning = 10
		return TOPIC_REFRESH

	if (href_list["affected_species"])
		if (dish)
			memorybank = null
			species_buffer = dish.virus2.affected_species
			analysed = dish.analysed
			dish = null
			scanning = 10
		return TOPIC_REFRESH

	if(href_list["eject"])
		if (dish)
			dish.dropInto(loc)
			dish = null
		return TOPIC_REFRESH

	if(href_list["splice"])
		if(dish)
			var/target = text2num(href_list["splice"]) // target = 1+ for effects, -1 for species
			if(memorybank && target > 0)
				if(target < memorybank.stage)
					return // too powerful, catching this for href exploit prevention

				var/datum/disease2/effect/target_effect
				var/list/illegal_types = list()
				var/datum/disease2/effect/neweffect = new memorybank.type
				neweffect.generate(memorybank.data)
				neweffect.chance = memorybank.chance
				neweffect.multiplier = memorybank.multiplier
				neweffect.stage = target
				for(var/datum/disease2/effect/e in dish.virus2.effects)
					if(e.stage == target)
						target_effect = e
					if(!e.allow_multiple)
						illegal_types += e.type
				if(neweffect.type in illegal_types)
					to_chat(user, SPAN("warning", "Virus DNA can't hold more than one [memorybank]"))
					return 1
				dish.virus2.effects -= target_effect
				dish.virus2.effects += neweffect
				dish.virus2.update_disease()
				qdel(target_effect)

			else if(species_buffer && target == -1)
				dish.virus2.affected_species = species_buffer

			else
				return TOPIC_HANDLED

			splicing = 10
			dish.virus2.uniqueID = rand(0,10000)
		return TOPIC_REFRESH

	if(href_list["disk"])
		burning = 10
		return TOPIC_REFRESH
