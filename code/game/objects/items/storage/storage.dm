/obj/item/storage
	name = "storage"
	icon = 'icons/obj/storage.dmi'
	// List of object types that this item can store and their quantity limits.
	// Optional associative value can be set to limit the number of items per type.
	// Examples:
	//  can_hold = list(/obj/item/reagent_containers/food/donut/normal) // can only hold donuts, any amount
	//  can_hold = list(/obj/item/card/emag = 2) // can only hold up to two emags
	var/list/can_hold
	// List of object types that this item explicitly cannot store.
	var/list/cant_hold

	// Locked storage won't open, but will still register clicks, provide feedback, and receive fingerprints.
	var/locked = FALSE
	// Maximum size of objects that this item can store.
	// Note: Ensure items specified in can_hold fit within this size limit.
	var/max_w_class = ITEM_SIZE_SMALL
	// List of object types that can bypass the max_w_class restriction.
	var/list/override_w_class
	// Total storage capacity of this item. Automatically calculated at initialization if not set.
	var/max_storage_space
	// Total number of individual item slots this storage has.
	// Note: storage space limit is still calculated for slot-based inventories,
	// so make sure to take that into account if you're using can_store/override_w_class.
	var/storage_slots
	// Sound effect or name of the sound effect group to use. May be null for no sound.
	var/use_sound = SFX_SEARCH_CASE
	// Initial set of objects this item contains. Use associative values for quantity.
	// Examples:
	//  startswith = list(/obj/item/card/emag)
	//  startswith = list(/obj/item/reagent_containers/food/donut/normal = 6)
	var/list/startswith
	// Enable "Empty Contents" verb for this storage, allowing to quickly dump all the contents below the user.
	var/allow_quick_empty = FALSE
	// Reference to the storage interface that will be shown to users who have this storage open.
	var/datum/storage_ui/storage_ui = /datum/storage_ui/default

	// NOTE: variables from this section are also referenced outside of this file, e.g. in /obj/item/attackby()
	// TODO(rufus): this shouldn't be the case, check if access to these variables can be limited to this file,
	//   and helper functions or getters can be used instead.
	// Allow this storage to pick up items by clicking on them.
	var/use_to_pickup = FALSE
	// Allow this storage to switch gathering mode from "single item" to "everything on tile".
	var/allow_quick_gather = FALSE
	// Current quick gather mode. Applied only in combination with enabled use_to_pickup.
	var/quick_gather = TRUE

/obj/item/storage/Initialize()
	. = ..()
	if(allow_quick_empty)
		verbs += /obj/item/storage/verb/quick_empty
	else
		verbs -= /obj/item/storage/verb/quick_empty

	if(allow_quick_gather)
		verbs += /obj/item/storage/verb/toggle_gathering_mode
	else
		verbs -= /obj/item/storage/verb/toggle_gathering_mode

	if(isnull(max_storage_space) && !isnull(storage_slots))
		max_storage_space = storage_slots * base_storage_cost(max_w_class)

	storage_ui = new storage_ui(src)
	prepare_ui()

	if(startswith)
		for(var/item_path in startswith)
			var/list/data = startswith[item_path]
			if(islist(data))
				var/qty = data[1]
				var/list/argsl = data.Copy()
				argsl[1] = src
				for(var/i in 1 to qty)
					new item_path(arglist(argsl))
			else
				for(var/i in 1 to (isnull(data)? 1 : data))
					new item_path(src)
		update_icon()

/obj/item/storage/Destroy()
	QDEL_NULL(storage_ui)
	. = ..()

// TODO(rufus): refactor this function into a cleaner execution flow
/obj/item/storage/MouseDrop(obj/over_object as obj)
	if(!canremove)
		return

	if((ishuman(usr) || isrobot(usr) || issmall(usr)) && !usr.incapacitated())
		if(over_object == usr && Adjacent(usr)) // this must come before the screen objects only block
			// TODO(rufus): move fingerprints to open()
			src.add_fingerprint(usr)
			src.open(usr)
			return TRUE

		if(!(istype(over_object, /obj/screen)))
			return ..()

		//makes sure that the storage is equipped, so that we can't drag it into our hand from miles away.
		if(loc != usr)
			return

		add_fingerprint(usr)
		switch(over_object.name)
			if(BP_R_HAND)
				if(usr.drop(src))
					usr.put_in_r_hand(src)
			if(BP_L_HAND)
				if(usr.drop(src))
					usr.put_in_l_hand(src)
			if("back")
				usr.drop(src)

/obj/item/storage/AltClick(mob/usr)
	if(!canremove)
		return

	if((ishuman(usr) || isrobot(usr) || issmall(usr)) && !usr.incapacitated() && Adjacent(usr))
		add_fingerprint(usr)
		open(usr)
		return TRUE

/obj/item/storage/proc/return_inv()
	var/list/L = list(  )

	L += src.contents

	for(var/obj/item/storage/S in src)
		L += S.return_inv()
	for(var/obj/item/gift/G in src)
		L += G.gift
		if (istype(G.gift, /obj/item/storage))
			L += G.gift:return_inv()
	return L

/obj/item/storage/proc/show_to(mob/user)
	if(storage_ui)
		storage_ui.show_to(user)

/obj/item/storage/proc/hide_from(mob/user)
	if(storage_ui)
		storage_ui.hide_from(user)

/obj/item/storage/proc/open(mob/user)
	if(locked)
		to_chat(usr, SPAN("warning", "\The [src] is locked and cannot be opened!"))
		return
	if(src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)
	if(isrobot(user) && user.hud_used)
		var/mob/living/silicon/robot/robot = user
		if(robot.shown_robot_modules) //The robot's inventory is open, need to close it first.
			robot.hud_used.toggle_show_robot_modules()

	prepare_ui()
	if(storage_ui) // I guess we can afford performing double checks for such procs. Better this than hundreds of runtimes.
		storage_ui.on_open(user)
		storage_ui.show_to(user)

/obj/item/storage/proc/prepare_ui()
	if(storage_ui)
		storage_ui.prepare_ui()

/obj/item/storage/proc/close(mob/user)
	hide_from(user)
	if(storage_ui)
		storage_ui.after_close(user)

	if(src.use_sound)
		playsound(src.loc, src.use_sound, 50, 1, -5)

/obj/item/storage/proc/close_all()
	if(storage_ui)
		storage_ui.close_all()

/obj/item/storage/proc/storage_space_used()
	. = 0
	for(var/obj/item/I in contents)
		. += I.get_storage_cost()

//This proc return 1 if the item can be picked up and 0 if it can't.
//Set the stop_messages to stop it from printing messages
/obj/item/storage/proc/can_be_inserted(obj/item/W, mob/user, stop_messages = 0)
	if(!istype(W))
		return //Not an item

	if(user && user.is_equipped(W) && !user.can_unequip(W))
		return 0

	if(src.loc == W)
		return 0 //Means the item is already in the storage item

	if(locked)
		if(!stop_messages)
			to_chat(user, SPAN("notice", "\The [src] is locked."))
		// TODO(rufus): replace `return 0` with `return FALSE` throughout this file
		return 0

	if(storage_slots != null && contents.len >= storage_slots)
		if(!stop_messages)
			to_chat(user, SPAN("notice", "\The [src] is full, make some space."))
		return 0 //Storage item is full

	// TODO(rufus): move anchored check before the storage check, as it doesn't make sense to report
	//   that storage is full if item cannot be picked up anyways.
	if(W.anchored)
		return 0

	if(length(can_hold))
		if(!is_type_in_list(W, can_hold))
			if(!stop_messages && ! istype(W, /obj/item/hand_labeler))
				to_chat(user, SPAN("notice", "\The [src] cannot hold \the [W]."))
			return 0
		var/max_instances = can_hold[W.type]
		if(max_instances && instances_of_type_in_list(W, contents) >= max_instances)
			if(!stop_messages && !istype(W, /obj/item/hand_labeler))
				to_chat(user, SPAN("notice", "\The [src] has no more space specifically for \the [W]."))
			return 0

	//If attempting to lable the storage item, silently fail to allow it
	if(istype(W, /obj/item/hand_labeler) || istype(W, /obj/item/forensics) && user.a_intent != I_HELP)
		return FALSE

	// Don't allow insertion of unsafed compressed matter implants
	// Since they are sucking something up now, their afterattack will delete the storage
	if(istype(W, /obj/item/implanter/compressed))
		var/obj/item/implanter/compressed/impr = W
		if(!impr.safe)
			// TODO(rufus): remove redundant variable change
			stop_messages = 1
			return 0

	if(length(cant_hold) && is_type_in_list(W, cant_hold))
		if(!stop_messages)
			to_chat(user, SPAN("notice", "\The [src] cannot hold \the [W]."))
		return 0

	if(max_w_class != null && W.w_class > max_w_class && !(override_w_class?.len && is_type_in_list(W, override_w_class)))
		if(!stop_messages)
			to_chat(user, SPAN("notice", "\The [W] is too big for this [src.name]."))
		return 0

	var/total_storage_space = W.get_storage_cost()
	if(total_storage_space == ITEM_SIZE_NO_CONTAINER)
		if(!stop_messages)
			to_chat(user, SPAN("notice", "\The [W] cannot be placed in [src]."))
		return 0

	total_storage_space += storage_space_used() //Adds up the combined w_classes which will be in the storage item if the item is added to it.
	if(total_storage_space > max_storage_space)
		if(!stop_messages)
			to_chat(user, SPAN("notice", "\The [src] is too full, make some space."))
		return 0

	return 1

// TODO(rufus): replace `stop_warning` in the comment below with the current variable name, `prevent_warning`
//This proc handles items being inserted. It does not perform any checks of whether an item can or can't be inserted. That's done by can_be_inserted()
//The stop_warning parameter will stop the insertion message from being displayed. It is intended for cases where you are inserting multiple items at once,
//such as when picking up all the items on a tile with one click.
/obj/item/storage/proc/handle_item_insertion(obj/item/W, prevent_warning = 0, NoUpdate = 0)
	if(QDELETED(W))
		return FALSE
	if(ismob(W.loc))
		var/mob/M = W.loc
		if(!M.drop(W))
			return FALSE
	W.forceMove(src)
	W.on_enter_storage(src)
	if(usr)
		add_fingerprint(usr)
		if(!prevent_warning)
			for(var/mob/M in viewers(usr, null))
				if (M == usr)
					to_chat(usr, SPAN("notice", "You put \the [W] into [src]."))
				else if (M in range(1)) //If someone is standing close enough, they can tell what it is... TODO replace with distance check
					M.show_message(SPAN("notice", "\The [usr] puts [W] into [src]."))
				else if (W && W.w_class >= ITEM_SIZE_NORMAL) //Otherwise they can only see large or normal items from a distance...
					M.show_message(SPAN("notice", "\The [usr] puts [W] into [src]."))

		if(!NoUpdate)
			update_ui_after_item_insertion()

	// TODO(rufus): check if sound should be played based on prevent_warning.
	//   Or replace prevent_warning and NoUpdate with a single user_feedback parameter if splitting them is redundant.
	if(use_sound)
		playsound(loc, use_sound, 50, 1, -5)

	update_icon()
	return TRUE

/obj/item/storage/proc/update_ui_after_item_insertion()
	prepare_ui()
	if(storage_ui)
		storage_ui.on_insertion(usr)

/obj/item/storage/proc/update_ui_after_item_removal()
	prepare_ui()
	if(storage_ui)
		storage_ui.on_post_remove(usr)

//Call this proc to handle the removal of an item from the storage item. The item will be moved to the atom sent as new_target
// TODO(rufus): replace `NoUpdate` with an inverse `update` parameter and update respective checks to use (!update).
//   This would remove double semantic negation in conditionals, e.g. if(not no update), which causes mental overhead
/obj/item/storage/proc/remove_from_storage(obj/item/W as obj, atom/new_location, NoUpdate = 0)
	if(!istype(W))
		return 0
	if(locked)
		to_chat(usr, SPAN("warning", "\The [W] cannot be removed because [src] is locked."))
		return 0
	new_location = new_location || get_turf(src)

	if(storage_ui)
		storage_ui.on_pre_remove(usr, W)

	if(ismob(loc))
		W.dropped(usr)
	if(ismob(new_location))
		W.hud_layerise()
	else
		W.reset_plane_and_layer()
	W.forceMove(new_location)

	if(usr && !NoUpdate)
		update_ui_after_item_removal()
	if(W.maptext)
		W.maptext = ""
	W.on_exit_storage(src)
	if(!NoUpdate)
		update_icon()
	return 1

// Only do ui functions for now; the obj is responsible for anything else.
/obj/item/storage/proc/on_item_pre_deletion(obj/item/W)
	if(storage_ui)
		storage_ui.on_pre_remove(usr, W)

// Only do ui functions for now; the obj is responsible for anything else.
/obj/item/storage/proc/on_item_post_deletion()
	update_ui_after_item_removal()
	update_icon()

//Run once after using remove_from_storage with NoUpdate = 1
/obj/item/storage/proc/finish_bulk_removal()
	update_ui_after_item_removal()
	update_icon()

//This proc is called when you want to place an item into the storage item.
/obj/item/storage/attackby(obj/item/W, mob/user)
	. = ..()

	if(.)
		return

	if(isrobot(user) && W == user.get_active_hand())
		return //Robots can't store their modules.

	if(istype(W, /obj/item/device/lightreplacer))
		var/obj/item/device/lightreplacer/LP = W
		var/amt_inserted = 0
		var/turf/T = get_turf(user)
		for(var/obj/item/light/L in src.contents)
			if(L.status == 0)
				if(LP.uses < LP.max_uses)
					LP.AddUses(1)
					amt_inserted++
					remove_from_storage(L, T)
					qdel(L)
		if(amt_inserted)
			to_chat(user, "You inserted [amt_inserted] light\s into \the [LP.name]. You have [LP.uses] light\s remaining.")
			return

	if(!can_be_inserted(W, user))
		return

	if(istype(W, /obj/item/tray))
		var/obj/item/tray/T = W
		if(T.calc_carry() > 0)
			if(prob(85))
				to_chat(user, SPAN("warning", "The tray won't fit in [src]."))
				return
			else
				if(user.drop(W))
					to_chat(user, SPAN("warning", "God damnit!"))
	W.add_fingerprint(user)
	return handle_item_insertion(W)

/obj/item/storage/allow_drop()
	return TRUE

/obj/item/storage/attack_hand(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.l_store == src && !H.get_active_hand())	//Prevents opening if it's in a pocket.
			if(H.put_in_hands(src))
				H.l_store = null
			return
		if(H.r_store == src && !H.get_active_hand())
			if(H.put_in_hands(src))
				H.r_store = null
			return

	// TODO(rufus): normalize the flow of this section
	if(loc == user)
		open(user)
	else
		..()
		if(storage_ui)
			storage_ui.on_hand_attack(user)
	add_fingerprint(user)
	return

/obj/item/storage/proc/gather_all(turf/T, mob/user)
	var/success = 0
	var/failure = 0

	for(var/obj/item/I in T)
		// TODO(rufus): remove outdated comment
		if(!can_be_inserted(I, user, 0))	// Note can_be_inserted still makes noise when the answer is no
			failure = 1
			continue
		success = 1
		// TODO(rufus): replace with named parameters
		handle_item_insertion(I, 1, 1) // First 1 is no messages, second 1 is no ui updates
	if(success && !failure)
		to_chat(user, SPAN("notice", "You put everything into \the [src]."))
		if (src.use_sound)
			playsound(src.loc, src.use_sound, 50, 1, -5)
		update_ui_after_item_insertion()
	else if(success)
		to_chat(user, SPAN("notice", "You put some things into \the [src]."))
		if (src.use_sound)
			playsound(src.loc, src.use_sound, 50, 1, -5)
		update_ui_after_item_insertion()
	else
		to_chat(user, SPAN("notice", "You fail to pick anything up with \the [src]."))

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	quick_gather = !quick_gather
	to_chat(usr, SPAN("notice", "\The [src] now picks up [quick_gather ? "all items in a tile at once." : "one item at a time"]."))

/obj/item/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (src.loc != usr)) || usr.stat || usr.restrained())
		return

	var/turf/T = get_turf(src)
	hide_from(usr)
	for(var/obj/item/I in contents)
		// TODO(rufus): break the loop if removal failed
		remove_from_storage(I, T, 1)
	finish_bulk_removal()

/obj/item/storage/emp_act(severity)
	// TODO(rufus): invert the check
	// Mobs process EMP of their contents on their own by recursively fetching all the contents via get_contents()
	if(!istype(src.loc, /mob/living))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()

/obj/item/storage/attack_self(mob/user)
	//Clicking on itself will empty it, if it has the verb to do that.
	// TODO(rufus): replace redundant check
	if(user.get_active_hand() == src)
		// TODO(rufus): replace with allow_quick_empty check
		if(src.verbs.Find(/obj/item/storage/verb/quick_empty))
			quick_empty()
			return 1

/obj/item/storage/proc/make_exact_fit()
	storage_slots = contents.len

	if(isnull(can_hold))
		can_hold = list()
	else
		can_hold.Cut()
	max_w_class = 0
	max_storage_space = 0
	for(var/obj/item/I in src)
		can_hold[I.type]++
		max_w_class = max(I.w_class, max_w_class)
		max_storage_space += I.get_storage_cost()

//Returns the storage depth of an atom. This is the number of storage items the atom is contained in before reaching toplevel (the area).
//Returns -1 if the atom was not found on container.
/atom/proc/storage_depth(atom/container)
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !(cur_atom in container.contents))
		if(isarea(cur_atom))
			return -1
		if(istype(cur_atom.loc, /obj/item/storage))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

//Like storage depth, but returns the depth to the nearest turf
//Returns -1 if no top level turf (a loc was null somewhere, or a non-turf atom's loc was an area somehow).
/atom/proc/storage_depth_turf()
	var/depth = 0
	var/atom/cur_atom = src

	while(cur_atom && !isturf(cur_atom))
		if(isarea(cur_atom))
			return -1
		if(istype(cur_atom.loc, /obj/item/storage))
			depth++
		cur_atom = cur_atom.loc

	if(!cur_atom)
		return -1	//inside something with a null loc.

	return depth

/obj/item/proc/get_storage_cost() //If you want to prevent stuff above a certain w_class from being stored, use max_w_class
	return base_storage_cost(w_class)
