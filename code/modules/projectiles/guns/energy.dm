GLOBAL_LIST_INIT(registered_weapons, list())

/obj/item/gun/energy
	name = "energy gun"
	desc = "A basic energy-based gun."
	description_info = "This is an energy weapon. To fire the weapon, ensure your intent is *not* set to 'help', have your gun mode set to 'fire', \
	then click where you want to fire. Most energy weapons can fire through windows harmlessly. To recharge this weapon, use a weapon recharger."
	icon_state = "energy"
	fire_sound_text = "laser blast"

	var/obj/item/cell/power_supply // Currently installed power cell
	var/charge_cost = 20 // How much energy is needed to fire
	var/cell_type = null // What type of power cell this uses, a new cell of this type will be created on initialization
	var/max_shots = 10 // Determines the capacity of a generic power cell that will be created if cell_type is not specificed
	var/projectile_type = /obj/item/projectile/beam/practice
	var/charge_meter = 1 // If set, the icon state will be chosen based on the current charge
	var/modifystate // String prefix that will be combined with the charge percentage to produce the correct icon state
	var/icon_rounder = 25 // Charge percentage will be rounded to this number to choose icon state for charge_meter

	// Self-recharging
	var/self_recharge = 0	// If set, the weapon will recharge itself
	var/use_external_power = 0 // If set, will try to recharge from cyborg, RIG etc, otherwise recharges magically
	var/recharge_time = 4 // How many "ticks" it takes to do one recharge iteration, by default 1 tick is 1 second
	var/charge_tick = 0 // Charge tick counter, see /obj/item/gun/energy/think()

	combustion = 1
	force = 8.5
	mod_weight = 0.7
	mod_reach = 0.5
	mod_handy = 1.0

/obj/item/gun/energy/Initialize()
	. = ..()
	if(cell_type)
		power_supply = new cell_type(src)
	else
		power_supply = new /obj/item/cell/device/variable(src, max_shots*charge_cost)
	if(self_recharge)
		set_next_think(world.time)
	update_icon()

/obj/item/gun/energy/_examine_text(mob/user)
	. = ..()
	if(!power_supply)
		. += "Doesn't have a power supply installed."
	else
		. += "\nHas [round(power_supply.charge / charge_cost)] shot\s remaining."

/obj/item/gun/energy/update_icon()
	if(charge_meter)
		var/charge_state = 0
		if(power_supply && power_supply.charge >= charge_cost)
			// display lowest non-zero state if there's at least one charge, as rounding to zero would be confusing
			charge_state = max(round(power_supply.percent(), icon_rounder), icon_rounder)

		if(modifystate)
			icon_state = "[modifystate][charge_state]"
		else
			icon_state = "[initial(icon_state)][charge_state]"
	..()

/obj/item/gun/energy/think()
	if(self_recharge)
		charge_tick++
		if(charge_tick < recharge_time)
			set_next_think(world.time + 1 SECOND)
			return
		charge_tick = 0

		if(!power_supply || power_supply.charge >= power_supply.maxcharge)
			set_next_think(world.time + 1 SECOND)
			return

		if(use_external_power)
			var/obj/item/cell/external = get_external_power_supply()
			if(!external || !external.use(charge_cost))
				set_next_think(world.time + 1 SECOND)
				return

		power_supply.give(charge_cost)
		update_icon()

	set_next_think(world.time + 1 SECOND)

/obj/item/gun/energy/consume_next_projectile()
	if(!power_supply)
		return null
	if(!ispath(projectile_type))
		return null
	if(!power_supply.checked_use(charge_cost))
		return null
	var/obj/item/projectile/BB = new projectile_type(src)
	if(BB.projectile_light)
		BB.layer = ABOVE_LIGHTING_LAYER
		BB.plane = EFFECTS_ABOVE_LIGHTING_PLANE
		BB.set_light(BB.projectile_max_bright, BB.projectile_inner_range, BB.projectile_outer_range, BB.projectile_falloff_curve, BB.projectile_brightness_color)
	return BB

/obj/item/gun/energy/proc/get_external_power_supply()
	if(isrobot(src.loc))
		var/mob/living/silicon/robot/R = src.loc
		return R.cell
	if(istype(src.loc, /obj/item/rig_module))
		var/obj/item/rig_module/module = src.loc
		if(module.holder && module.holder.wearer)
			var/mob/living/carbon/human/H = module.holder.wearer
			if(istype(H) && H.back)
				var/obj/item/rig/suit = H.back
				if(istype(suit))
					return suit.cell
	return null

/obj/item/gun/energy/switch_firemodes()
	. = ..()
	if(.)
		update_icon()
		playsound(src, 'sound/effects/weapons/energy/toggle_mode1.ogg', rand(50, 75), FALSE)

/obj/item/gun/energy/emp_act(severity)
	..()
	update_icon()


/obj/item/gun/energy/secure
	desc = "A basic energy-based gun with a secure authorization chip."
	req_access = list(access_brig)
	var/list/authorized_modes = list(ALWAYS_AUTHORIZED) // index of this list should line up with firemodes, unincluded firemodes at the end will default to unauthorized
	var/registered_owner
	var/emagged = 0

/obj/item/gun/energy/secure/Initialize()
	if(!authorized_modes)
		authorized_modes = list()

	for(var/i = authorized_modes.len + 1 to firemodes.len)
		authorized_modes.Add(UNAUTHORIZED)

	. = ..()

/obj/item/gun/energy/secure/_examine_text(mob/user)
	. = ..()

	if(!registered_owner)
		. += "\nA small screen on the side of the weapon displays a blinking icon of a red ID card, indicating that the weapon is not registered."
	else
		. += "\nA small screen on the side of the weapon displays the name \"[registered_owner]\", indicating it is registered."

/obj/item/gun/energy/secure/attackby(obj/item/W as obj, mob/user as mob)
	if(istype(W, /obj/item/card/id))
		if(emagged)
			to_chat(user, "You swipe your ID, but nothing happens.")
			return
		if(registered_owner)
			to_chat(user, "This weapon is already registered, you must reset it first.")
			return
		if(!allowed(user))
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return

		var/obj/item/card/id/id = W
		GLOB.registered_weapons += src
		registered_owner = id.registered_name
		user.visible_message("[user] swipes an ID through \the [src], registering it.", "You swipe an ID through \the [src], registering it.")

	..()

/obj/item/gun/energy/secure/verb/reset()
	set name = "Reset Registration"
	set category = "Object"
	set src in usr

	if(issilicon(usr))
		return

	if(allowed(usr))
		usr.visible_message("[usr] presses the reset button on \the [src], resetting its registration.", "You press the reset button on \the [src], resetting its registration.")
		registered_owner = null
		GLOB.registered_weapons -= src
		return

	audible_message("<span class='warning'>\The [src] buzzes, refusing unauthorized action.</span>", runechat_message = "*buzz*")
	playsound(loc, 'sound/signals/error1.ogg', 50, 0)

/obj/item/gun/energy/secure/Destroy()
	GLOB.registered_weapons -= src

	. = ..()

/obj/item/gun/energy/secure/proc/authorize(mode, authorization, authorized_by)
	if(emagged || mode < 1 || mode > authorized_modes.len || authorized_modes[mode] == authorization)
		return 0

	authorized_modes[mode] = authorization

	if(mode == sel_mode && authorization == UNAUTHORIZED)
		switch_firemodes()

	var/mob/M = get_holder_of_type(src, /mob)
	if(M)
		to_chat(M, "<span class='notice'>Your [src.name] has been [authorization ? "granted" : "denied"] [firemodes[mode]] fire authorization by [authorized_by].</span>")

	return 1

/obj/item/gun/energy/secure/proc/current_mode_authorized()
	return authorized_modes[sel_mode] != UNAUTHORIZED

/obj/item/gun/energy/secure/special_check()
	if(!emagged && (!current_mode_authorized() || !registered_owner))
		audible_message("<span class='warning'>\The [src] buzzes, refusing to fire.</span>", runechat_message = "*buzz*")
		playsound(loc, 'sound/signals/error1.ogg', 50, 0)
		return 0
	// TODO(rufus): refactor special check, as besides checking it also does shooting on clumsy mutation.
	//   Special check is not following single responsibility principle which causes issues. Also the name is non-descriptive and it's impossible to tell
	//   What "special" check does without reading through the code.
	//   1. If parent call is done at the end, when a user has hulk mutation, their finger size shouldn't even allow them to try triggering the gun,
	//      yet this override function will trigger first and give unauthorized mode feedback.
	//   2. If parent call is done at the beginning, clown with no access will be able to shoot themselves in the foot, overriding the authorization.
	//   One possible solution is to add a pre-trigger check function (e.g. "check_trigger"), which will catch hulk-like cases, and post-trigger one,
	//   happening after the authorization check was passed and redirecting clown shots into their feet.
	. = ..()

/obj/item/gun/energy/secure/switch_firemodes()
	var/next_mode = get_next_authorized_mode()
	if(next_mode == null || firemodes.len <= 1 || sel_mode == next_mode)
		return null

	sel_mode = next_mode
	var/datum/firemode/new_mode = firemodes[sel_mode]
	new_mode.apply_to(src)
	update_icon()
	playsound(src, 'sound/effects/weapons/energy/toggle_mode1.ogg', rand(50, 75), FALSE)

	return new_mode

/obj/item/gun/energy/secure/proc/get_next_authorized_mode()
	var/current_mode = sel_mode
	while(TRUE)
		current_mode++
		if (current_mode > authorized_modes.len)
			current_mode = 1
		if (current_mode == sel_mode) // looped back to the start and found no authorized modes
			return null
		if (emagged || authorized_modes[current_mode])
			return current_mode

/obj/item/gun/energy/secure/emag_act(charges, mob/user)
	if(emagged || !charges)
		return NO_EMAG_ACT
	else
		emagged = 1
		registered_owner = null
		GLOB.registered_weapons -= src
		to_chat(user, "The authorization chip fries, giving you full access to \the [src].")
		return 1
