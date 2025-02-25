/obj/item/rig/attackby(obj/item/W as obj, mob/user as mob)

	if(!istype(user,/mob/living)) return 0

	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return

	// Pass repair items on to the chestpiece.
	if(chest && (istype(W,/obj/item/stack/material) || isWelder(W)))
		return chest.attackby(W,user)

	// Lock or unlock the access panel.
	if(W.get_id_card())
		if(subverted)
			locked = 0
			to_chat(user, SPAN("danger", "It looks like the locking system has been shorted out."))
			return

		if((!req_access || !req_access.len) && (!req_one_access || !req_one_access.len))
			locked = 0
			to_chat(user, SPAN("danger", "\The [src] doesn't seem to have a locking mechanism."))
			return

		if(security_check_enabled && !src.allowed(user))
			to_chat(user, SPAN("danger", "Access denied."))
			return

		locked = !locked
		to_chat(user, "You [locked ? "lock" : "unlock"] \the [src] access panel.")
		return

	else if(isCrowbar(W))

		if(!open && locked)
			to_chat(user, "The access panel is locked shut.")
			return

		open = !open
		to_chat(user, "You [open ? "open" : "close"] the access panel.")
		return

	if(open)

		// Hacking.
		if(isWirecutter(W) || isMultitool(W))
			if(open)
				wires.Interact(user)
			else
				to_chat(user, "You can't reach the wiring.")
			return
		// Air tank.
		if(istype(W,/obj/item/tank)) //Todo, some kind of check for suits without integrated air supplies.

			if(air_supply)
				to_chat(user, "\The [src] already has a tank installed.")
				return

			if(!user.drop(W, src))
				return
			air_supply = W
			to_chat(user, "You slot [W] into [src] and tighten the connecting valve.")
			return

		// Check if this is a powersuit upgrade or a modification.
		else if(istype(W,/obj/item/rig_module))

			if(istype(src.loc,/mob/living/carbon/human))
				var/mob/living/carbon/human/H = src.loc
				if(H.back == src)
					to_chat(user, SPAN("danger", "You can't install a powersuit module while the suit is being worn."))
					return 1

			if(!installed_modules) installed_modules = list()
			if(installed_modules.len)
				for(var/obj/item/rig_module/installed_mod in installed_modules)
					if(!installed_mod.redundant && istype(installed_mod,W))
						to_chat(user, "The powersuit already has a module of that class installed.")
						return 1

			var/obj/item/rig_module/mod = W
			to_chat(user, "You begin installing \the [mod] into \the [src].")
			if(!do_after(user,40,src))
				return
			if(!user || !W)
				return
			if(!user.drop(mod, src))
				return
			to_chat(user, "You install \the [mod] into \the [src].")
			installed_modules |= mod
			mod.installed(src)
			update_icon()
			return 1

		else if(!cell && istype(W,/obj/item/cell))

			if(!user.drop(W, src))
				return
			to_chat(user, "You jack \the [W] into \the [src]'s battery mount.")
			cell = W
			return

		else if(isWrench(W))

			if(!air_supply)
				to_chat(user, "There is not tank to remove.")
				return

			if(loc != user)
				air_supply.dropInto(loc)
			else
				user.pick_or_drop(air_supply)

			to_chat(user, "You detach and remove \the [air_supply].")
			air_supply = null
			return

		else if(isScrewdriver(W))

			var/list/current_mounts = list()
			if(cell) current_mounts   += "cell"
			if(installed_modules && installed_modules.len) current_mounts += "system module"

			var/to_remove = input("Which would you like to modify?") as null|anything in current_mounts
			if(!to_remove)
				return

			if(istype(src.loc,/mob/living/carbon/human) && to_remove != "cell")
				var/mob/living/carbon/human/H = src.loc
				if(H.back == src)
					to_chat(user, "You can't remove an installed device while the powersuit is being worn.")
					return

			switch(to_remove)

				if("cell")

					if(cell)
						to_chat(user, "You detach \the [cell] from \the [src]'s battery mount.")
						for(var/obj/item/rig_module/module in installed_modules)
							module.deactivate()
						if(loc != user)
							cell.dropInto(loc)
						else
							user.pick_or_drop(cell)
						cell = null
					else
						to_chat(user, "There is nothing loaded in that mount.")

				if("system module")

					var/list/possible_removals = list()
					for(var/obj/item/rig_module/module in installed_modules)
						if(module.permanent)
							continue
						possible_removals[module.name] = module

					if(!possible_removals.len)
						to_chat(user, "There are no installed modules to remove.")
						return

					var/removal_choice = input("Which module would you like to remove?") as null|anything in possible_removals
					if(!removal_choice)
						return

					var/obj/item/rig_module/removed = possible_removals[removal_choice]
					to_chat(user, "You detach \the [removed] from \the [src].")

					if(loc != user)
						removed.dropInto(loc)
					else
						user.pick_or_drop(removed)

					removed.removed()
					installed_modules -= removed
					update_icon()

		return

	// If we've gotten this far, all we have left to do before we pass off to root procs
	// is check if any of the loaded modules want to use the item we've been given.
	for(var/obj/item/rig_module/module in installed_modules)
		if(module.accepts_item(W,user)) //Item is handled in this proc
			return
	..()


/obj/item/rig/attack_hand(mob/user)

	if(electrified != 0)
		if(shock(user)) //Handles removing charge from the cell, as well. No need to do that here.
			return
	..()

/obj/item/rig/emag_act(remaining_charges, mob/user)
	if(!subverted)
		req_access.Cut()
		req_one_access.Cut()
		locked = 0
		subverted = 1
		to_chat(user, SPAN("danger", "You short out the access protocol for the suit."))
		return 1
