/obj/item/storage/guncase
	name = "guncase"
	icon = 'icons/obj/storage.dmi'
	force = 8
	throw_range = 4
	w_class = ITEM_SIZE_LARGE
	mod_weight = 1.4
	mod_reach = 0.7
	mod_handy = 1
	max_w_class = ITEM_SIZE_NORMAL
	max_storage_space = DEFAULT_BACKPACK_STORAGE
	locked = TRUE

	// icon_state of the overlay that will be drawn over the guncase when it's unlocked.
	// Green LED indicator by default.
	var/opened_overlay_icon_state = "guncase0"
	// Used to track if items were already spawned.
	// If not, items from the `selected_option` will be spawned upon unlocking.
	var/items_spawned = FALSE
	// List of /datum/guncase_spawn_option instances that can be selected for this guncase
	var/list/spawn_options
	// Currently selected /datum/guncase_spawn_option from the `spawn_options` list or null if nothing was selected yet.
	var/datum/guncase_spawn_option/selected_option

	var/datum/browser/choice_interface

/obj/item/storage/guncase/attack_self(mob/user)
	if(locked && !items_spawned)
		show_choice_interface(user)
		if(choice_interface?.user == user)
			choice_interface.open()
		return
	attack_hand(user)

/obj/item/storage/guncase/attackby(obj/item/W, mob/user)
	var/obj/item/card/id/I = W.get_id_card()
	if(!I) // swipe with an access item is required to lock/unlock
		return ..()
	if(!allowed(user)) // compares required access vars to all the access sources on the user's mob, see `req_access` var
		to_chat(user, SPAN("warning", "Access denied!"))
		return
	if(!selected_option)
		to_chat(user, SPAN("warning", "\The [src] blinks red. You need to make a choice first."))
		return
	if(!items_spawned)
		spawn_contents()
		register_stored_guns(I.registered_name)
		choice_interface.close(user)
	locked = !locked
	to_chat(user, SPAN("notice", "You [locked ? "" : "un"]lock \the [src]."))
	overlays.Cut()
	if(!locked)
		overlays += image(icon, opened_overlay_icon_state)

/obj/item/storage/guncase/proc/spawn_contents()
	if(items_spawned || !selected_option)
		return
	for(var/item_path in selected_option.spawn_items)
		var/num = 1
		// if assoc value is a non-zero number, use it as a number of items to spawn
		if(selected_option.spawn_items[item_path])
			num = selected_option.spawn_items[item_path]

		for(var/n in 1 to num)
			new item_path(src)
	items_spawned = TRUE

/obj/item/storage/guncase/proc/register_stored_guns(owner_name)
	for(var/thing in contents)
		if(istype(thing, /obj/item/gun/energy/security))
			var/obj/item/gun/energy/security/gun = thing
			gun.owner = owner_name

/obj/item/storage/guncase/proc/show_choice_interface(mob/user)
	if(user.incapacitated() || !user.Adjacent(src) || !user.client)
		return
	user.set_machine(src)

	var/dat = "The case can be unlocked by swiping your ID card across the lock."
	dat += "<hr>"
	dat += "Chosen Gun: <b>[selected_option ? selected_option.name : "none"]</b>"
	if(selected_option)
		dat += "<br>"
		dat += selected_option.desc
	if(!items_spawned)
		dat += "<hr>"
		dat += "Be careful! Once you chose your weapon and unlock the gun case, you won't be able to change it."
		dat += "<hr>"
		for(var/datum/guncase_spawn_option/option in spawn_options)
			dat += "<a href=\"?src=\ref[src];type=[option.codename]\">[option.name]</a>"
			dat += "<br>"

	if(!choice_interface || choice_interface.user != user)
		choice_interface = new /datum/browser(user, "mob[name]", "<b>[src]</b>", 360, 400)
		choice_interface.set_content(dat)
	else
		choice_interface.set_content(dat)
		choice_interface.update()

/obj/item/storage/guncase/Topic(href, href_list)
	if((usr.stat || usr.restrained()) || (get_dist(src, usr) > 1))
		return
	if(!href_list["type"])
		return
	select_spawn_option(href_list["type"])
	for(var/mob/M in viewers(1, get_turf(src)))
		if((M.client && M.machine == src))
			show_choice_interface(M)

/obj/item/storage/guncase/proc/select_spawn_option(codename)
	for(var/datum/guncase_spawn_option/option in spawn_options)
		if(codename == option.codename)
			selected_option = option
			return
	CRASH("Unexpected guncase option codename for [src] ([src.type]): \"[codename]\"")


/obj/item/storage/guncase/detective
	name = "detective's gun case"
	icon_state = "guncasedet"
	item_state = "guncasedet"
	desc = "A heavy-duty container with a digital locking system. This one has a wooden coating and its locks are the color of brass."
	req_access = list(access_forensics_lockers)
	spawn_options = list(
		new /datum/guncase_spawn_option/m1911,
		new /datum/guncase_spawn_option/sw_legacy,
		new /datum/guncase_spawn_option/sw620,
		new /datum/guncase_spawn_option/m2019,
		new /datum/guncase_spawn_option/t9)

/obj/item/storage/guncase/security
	name = "security hardcase"
	icon_state = "guncasesec"
	item_state = "guncase"
	desc = "A heavy-duty container with an ID-based locking system. This one is painted in NT Security colors."
	req_access = list(access_security)
	override_w_class = list(/obj/item/gun/energy/security)
	max_storage_space = null
	storage_slots = 7
	spawn_options = list(
		new /datum/guncase_spawn_option/security/taser_pistol,
		new /datum/guncase_spawn_option/security/taser_smg,
		new /datum/guncase_spawn_option/security/taser_rifle,
		new /datum/guncase_spawn_option/security/classic)
