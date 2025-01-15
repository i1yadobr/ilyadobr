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

/obj/item/storage/MouseDrop(atom/over_object)
	// TODO(rufus): check if issmall() can be replaced by something more sematically meaningfull
	if(!(ishuman(usr) || isrobot(usr) || issmall(usr)))
		return
	if(usr.incapacitated())
		return

	if(over_object == usr)
		if(!Adjacent(usr))
			to_chat(usr, SPAN("warning", "[src] is too far away to open!"))
			return
		open(usr)
		return

	if(istype(over_object, /obj/screen))
		if(loc != usr)
			return
		if(!canremove)
			to_chat(usr, "[src] cannot be removed!")
			return
		// TODO(rufus): checking by name is not reliable, refactor to something appropriate for type checking
		switch(over_object.name)
			if(BP_R_HAND)
				if(usr.drop(src))
					usr.put_in_r_hand(src)
			if(BP_L_HAND)
				if(usr.drop(src))
					usr.put_in_l_hand(src)
		return
	..()

/obj/item/storage/AltClick(mob/usr)
	if(!canremove)
		return
	if((ishuman(usr) || isrobot(usr) || issmall(usr)) && !usr.incapacitated() && Adjacent(usr))
		open(usr)

// return_inv returns a flat array containing all the contents, regardless of their storage depth.
// It recursively fetches inventories of all the nested storage items and wrapped gifts.
// TODO(rufus): currently doesn't handle wrapped items (/obj/item/smallDelivery), check if handling of those
//   should be added or refactor deliveries and gifts to be subtypes of storage.
/obj/item/storage/proc/return_inv()
	var/list/inv = list()
	inv += contents
	for(var/obj/item/storage/S in src)
		inv += S.return_inv()
	for(var/obj/item/gift/G in src)
		inv += G.gift
		if(istype(G.gift, /obj/item/storage))
			var/obj/item/storage/gift_storage = G.gift
			inv += gift_storage.return_inv()
	return inv

/obj/item/storage/proc/show_to(mob/user)
	storage_ui?.show_to(user)

/obj/item/storage/proc/hide_from(mob/user)
	storage_ui?.hide_from(user)

/obj/item/storage/proc/open(mob/user)
	add_fingerprint(usr)
	if(locked)
		to_chat(usr, SPAN("warning", "\The [src] is locked and cannot be opened!"))
		return
	if(use_sound)
		playsound(src, use_sound, 50, TRUE, -5)
	if(isrobot(user) && user.hud_used)
		var/mob/living/silicon/robot/robot = user
		if(robot.shown_robot_modules) //The robot's inventory is open, need to close it first.
			robot.hud_used.toggle_show_robot_modules()

	prepare_ui()
	storage_ui?.on_open(user)
	storage_ui?.show_to(user)

/obj/item/storage/proc/prepare_ui()
	storage_ui?.prepare_ui()

/obj/item/storage/proc/close(mob/user)
	hide_from(user)
	storage_ui?.after_close(user)

	if(use_sound)
		playsound(src, use_sound, 50, TRUE, -5)

/obj/item/storage/proc/close_all()
	storage_ui?.close_all()

/obj/item/storage/proc/storage_space_used()
	. = 0
	for(var/obj/item/I in contents)
		. += I.get_storage_cost()

// can_be_inserted performs all the checks related to inserting item W into the storage, prints a message to
// the user's chat stating the reason if item cannot be inserted, and returns TRUE if insertion is allowed.
//
// The performed checks include storage capacity checks, item size checks, `can_hold`/`cant_hold` lists,
// if item W can or cannot be moved in general, and unique edge cases for certain special items.
//
// User messages can be disabled by setting `feedback` parameter to FALSE.
/obj/item/storage/proc/can_be_inserted(obj/item/W, mob/user, feedback = TRUE)
	if(!istype(W))
		return FALSE
	if(user && user.is_equipped(W) && !user.can_unequip(W))
		return FALSE
	if(loc == W)
		return FALSE

	if(locked)
		if(feedback)
			to_chat(user, SPAN("notice", "\The [src] is locked."))
		return FALSE

	if(W.anchored)
		return FALSE

	if(storage_slots != null && contents.len >= storage_slots)
		if(feedback)
			to_chat(user, SPAN("notice", "\The [src] is full, make some space."))
		return FALSE

	if(length(can_hold))
		if(!(W.type in can_hold))
			if(feedback && !istype(W, /obj/item/hand_labeler))
				to_chat(user, SPAN("notice", "\The [src] cannot hold \the [W]."))
			return FALSE
		var/max_instances = can_hold[W.type]
		if(max_instances && instances_of_type_in_list(W, contents) >= max_instances)
			if(feedback && !istype(W, /obj/item/hand_labeler))
				to_chat(user, SPAN("notice", "\The [src] has no more space specifically for \the [W]."))
			return FALSE

	// If intent is not set to help, disallow insertion and let the items perform their action
	if(user.a_intent != I_HELP && (istype(W, /obj/item/hand_labeler) || istype(W, /obj/item/forensics)))
		return FALSE

	// Don't allow insertion of unsafed compressed matter implants
	// Since they are sucking something up now, their afterattack will delete the storage
	if(istype(W, /obj/item/implanter/compressed))
		var/obj/item/implanter/compressed/impr = W
		if(!impr.safe)
			return FALSE

	if(length(cant_hold) && (W.type in cant_hold))
		if(feedback)
			to_chat(user, SPAN("notice", "\The [src] cannot hold \the [W]."))
		return FALSE

	if(max_w_class != null && W.w_class > max_w_class && !(override_w_class?.len && is_type_in_list(W, override_w_class)))
		if(feedback)
			to_chat(user, SPAN("notice", "\The [W] is too big for this [src]."))
		return FALSE

	var/total_storage_space = W.get_storage_cost()
	if(total_storage_space == ITEM_SIZE_NO_CONTAINER)
		if(feedback)
			to_chat(user, SPAN("notice", "\The [W] cannot be placed in [src]."))
		return FALSE

	total_storage_space += storage_space_used() //Adds up the combined w_classes which will be in the storage item if the item is added to it.
	if(total_storage_space > max_storage_space)
		if(feedback)
			to_chat(user, SPAN("notice", "\The [src] is too full, make some space."))
		return FALSE
	return TRUE

// handle_item_insertion inserts item W into the storage and optionally provides user feedback.
//
// It does not check storage capacity or other conditions, and assumes that can_be_inserted() proc was used by the caller
// to confirm that insertion is actually allowed.
//
// The `feedback` parameter controls if chat messages, UI updates, icon updates, and sound are handled.
// In cases where multiple items are inserted at once, e.g. with "quick_gather" mode, the `feedback` value should be set
// to FALSE to prevent duplicate messages, sounds, and icon processing.
/obj/item/storage/proc/handle_item_insertion(obj/item/W, feedback = TRUE)
	if(QDELETED(W))
		return FALSE
	if(ismob(W.loc))
		var/mob/M = W.loc
		if(!M.drop(W))
			return FALSE
	W.forceMove(src)
	W.on_enter_storage(src)
	add_fingerprint(usr)
	if(feedback)
		if(usr)
			for(var/mob/M in viewers())
				if(M == usr)
					to_chat(usr, SPAN("notice", "You put \the [W] into [src]."))
				// If someone is standing close enough, they can see the insertion
				else if(M in range(1))
					M.show_message(SPAN("notice", "\The [usr] puts [W] into [src]."))
				// Otherwise, they can only see normal and large items from a distance
				else if(W && W.w_class >= ITEM_SIZE_NORMAL)
					M.show_message(SPAN("notice", "\The [usr] puts [W] into [src]."))
		update_ui_after_item_insertion()
		if(use_sound)
			playsound(loc, use_sound, 50, TRUE, -5)
		update_icon()
	return TRUE

/obj/item/storage/proc/update_ui_after_item_insertion()
	prepare_ui()
	storage_ui?.on_insertion(usr)

/obj/item/storage/proc/update_ui_after_item_removal()
	prepare_ui()
	storage_ui?.on_post_remove(usr)

// remove_from_storage moves item W from storage to `new_location` if storage is unlocked.
// It correctly handles updating the item's `layer` if item is moved to/from the mob.
// It also optionally updates the UI and storage's icon if `feedback` parameter is set to TRUE.
//
// If `new_location` is not passed, the item is removed from the storage and placed on the turf below instead.
/obj/item/storage/proc/remove_from_storage(obj/item/W as obj, atom/new_location, feedback = TRUE)
	if(!istype(W))
		return FALSE
	if(locked)
		to_chat(usr, SPAN("warning", "\The [W] cannot be removed because [src] is locked."))
		return FALSE
	new_location = new_location || get_turf(src)

	storage_ui?.on_pre_remove(usr, W)

	if(ismob(loc))
		W.dropped(usr)
	if(ismob(new_location))
		W.hud_layerise()
	else
		W.reset_plane_and_layer()
	W.forceMove(new_location)

	if(feedback)
		update_ui_after_item_removal()
		update_icon()
	W.on_exit_storage(src)
	return TRUE

// Only do ui functions for now; the obj is responsible for anything else.
/obj/item/storage/proc/on_item_pre_deletion(obj/item/W)
	storage_ui?.on_pre_remove(usr, W)

// Only do ui functions for now; the obj is responsible for anything else.
/obj/item/storage/proc/on_item_post_deletion()
	update_ui_after_item_removal()
	update_icon()

//Run once after using remove_from_storage with NoUpdate = TRUE
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
		for(var/obj/item/light/L in contents)
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
				to_chat(user, SPAN("warning", "\The [W] won't fit in \the [src]."))
				return
			else
				if(user.drop(W))
					to_chat(user, SPAN("warning", "You drop \the [W] trying to insert it into \the [src]. God damnit!"))
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
	if(loc == user)
		open(user)
		return
	..()
	storage_ui?.on_hand_attack(user)

/obj/item/storage/proc/gather_all(turf/T, mob/user)
	var/success = FALSE
	var/failure = FALSE

	for(var/obj/item/I in T)
		if(!can_be_inserted(I, user, feedback = FALSE))
			failure = TRUE
			continue
		success = TRUE
		handle_item_insertion(I, feedback = FALSE)
	if(success && !failure)
		to_chat(user, SPAN("notice", "You put everything into \the [src]."))
		if(use_sound)
			playsound(src, use_sound, 50, TRUE, -5)
		update_ui_after_item_insertion()
	else if(success)
		to_chat(user, SPAN("notice", "You put some things into \the [src]."))
		if(use_sound)
			playsound(src, use_sound, 50, TRUE, -5)
		update_ui_after_item_insertion()
	else
		to_chat(user, SPAN("notice", "You fail to pick anything up with \the [src]."))
	update_icon()

/obj/item/storage/verb/toggle_gathering_mode()
	set name = "Switch Gathering Method"
	set category = "Object"

	quick_gather = !quick_gather
	to_chat(usr, SPAN("notice", "\The [src] now picks up [quick_gather ? "all items in a tile at once." : "one item at a time"]."))

/obj/item/storage/verb/quick_empty()
	set name = "Empty Contents"
	set category = "Object"

	if((!ishuman(usr) && (loc != usr)) || usr.stat || usr.restrained())
		return

	var/turf/T = get_turf(src)
	hide_from(usr)
	for(var/obj/item/I in contents)
		// TODO(rufus): break the loop if removal failed
		remove_from_storage(I, T, TRUE)
	finish_bulk_removal()

/obj/item/storage/emp_act(severity)
	// TODO(rufus): invert the check
	// Mobs process EMP of their contents on their own by recursively fetching all the contents via get_contents()
	if(!istype(loc, /mob/living))
		for(var/obj/O in contents)
			O.emp_act(severity)
	..()

/obj/item/storage/attack_self(mob/user)
	//Clicking on itself will empty it, if it has the verb to do that.
	// TODO(rufus): replace redundant check
	if(user.get_active_hand() == src)
		// TODO(rufus): replace with allow_quick_empty check
		if(verbs.Find(/obj/item/storage/verb/quick_empty))
			quick_empty()
			return

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
