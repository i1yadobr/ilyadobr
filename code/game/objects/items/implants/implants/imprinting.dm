/obj/item/implant/imprinting
	name = "imprinting implant"
	desc = "Latest word in training your peons."
	origin_tech = list(TECH_MATERIAL = 1, TECH_BIO = 2, TECH_DATA = 3)
	var/list/instructions = list("Do your job.", "Respect your superiours.", "Wash you hands after using the toilet.")
	var/brainwashing = 0

/obj/item/implant/imprinting/get_data()
	. = {"
	<b>Implant Specifications:</b><BR>
	<b>Name:</b> NanoTrasen BB-56 "Educator" Employee Assistance Implant<BR>
	<b>Life:</b> 1 year.<BR>
	<HR>
	<b>Function:</b> Adjusts itself to host's brainwaves, and presents supplied instructions as their 'inner voice' for less intrusive reminding. It will transmit them every 5 minutes in non-obtrusive manner.<BR>
	<b>Special Features:</b> Do NOT implant if subject is under effect of any mind-altering drugs.
	It carries risk of over-tuning, making subject unable to question the suggestions received, treating them as beliefs they feel strongly about.<BR>
	It is HIGLY ILLEGAL and NanoTrasen does NOT endorse use of this device in such way.
	Any amount of Nanotrasen brand "Mind-Breaker"(TM) present in bloodstream will trigger this side-effect.<BR>"}
	. += "<HR><B>Instructions:</B><BR>"
	for(var/i = 1 to instructions.len)
		. += "- [instructions[i]] <A href='byond://?src=\ref[src];edit=[i]'>Edit</A> <A href='byond://?src=\ref[src];del=[i]'>Remove</A><br>"
	. += "<A href='byond://?src=\ref[src];add=1'>Add</A>"

/obj/item/implant/imprinting/Topic(href, href_list)
	..()
	if (href_list["add"])
		var/mod = sanitize(input("Add an instruction", "Instructions") as text|null)
		if(mod)
			instructions += mod
		interact(usr)
	if (href_list["edit"])
		var/idx = text2num(href_list["edit"])
		var/mod = sanitize(input("Edit the instruction", "Instruction Editing", instructions[idx]) as text|null)
		if(mod)
			instructions[idx] = mod
			interact(usr)
	if (href_list["del"])
		instructions -= instructions[text2num(href_list["del"])]
		interact(usr)

/obj/item/implant/imprinting/implanted(mob/M)
	var/mob/living/carbon/human/H = M
	if(!istype(H))
		return FALSE
	if(H.reagents.has_reagent(/datum/reagent/mindbreaker))
		brainwashing = 1
	var/msg
	if(brainwashing)
		msg += "[SPAN("danger", "The fog in your head clears, and you remember some important things. You hold following things as deep convictions, almost like synthetics' laws:")]<br>"
	else
		msg += "[SPAN("notice", "You hear an annoying voice in the back of your head. The things it keeps reminding you of:")]<br>"
	for(var/thing in instructions)
		msg += "- [thing]<br>"
	to_chat(M, msg)
	if(M.mind)
		M.mind.store_memory("<hr>[msg]")

	set_next_think(world.time)
	return TRUE

/obj/item/implant/imprinting/think()
	var/instruction = pick(instructions)
	if(brainwashing)
		instruction = SPAN("warning", "You recall one of your beliefs: \"[instruction]\"")
	else
		instruction = SPAN("notice", "You remember suddenly: \"[instruction]\"")
	to_chat(imp_in, instruction)

	set_next_think(world.time + 5 MINUTES)

/obj/item/implant/imprinting/removed()
	if(brainwashing)
		to_chat(imp_in,SPAN("notice", "You are no longer so sure of those beliefs you've had..."))
	..()
	set_next_think(0)

/obj/item/implanter/imprinting
	name = "imprinting implanter"
	imp = /obj/item/implant/imprinting

/obj/item/implantcase/imprinting
	name = "glass case - 'imprinting'"
	imp = /obj/item/implant/imprinting
