/obj/screen/gun
	name = "gun"
	icon = 'icons/mob/screen1.dmi'
	master = null
	dir = 2

// Return value used by subtypes to determine if Click should be processed
/obj/screen/gun/Click(location, control, params)
	if(!usr)
		return FALSE
	return TRUE

/obj/screen/gun/move
	name = "Allow Movement"
	icon_state = "no_walk0"
	screen_loc = ui_gun2

/obj/screen/gun/move/Click(location, control, params)
	if(!..())
		return
	var/mob/living/user = usr
	if(istype(user))
		if(!user.aiming)
			user.aiming = new(user)
		user.aiming.toggle_permission(TARGET_CAN_MOVE)

/obj/screen/gun/item
	name = "Allow Item Use"
	icon_state = "no_item0"
	screen_loc = ui_gun1

/obj/screen/gun/item/Click(location, control, params)
	if(!..())
		return
	var/mob/living/user = usr
	if(istype(user))
		if(!user.aiming)
			user.aiming = new(user)
		user.aiming.toggle_permission(TARGET_CAN_CLICK)

/obj/screen/gun/mode
	name = "Toggle Gun Mode"
	icon_state = "gun0"
	screen_loc = ui_gun_select

/obj/screen/gun/mode/Click(location, control, params)
	if(!..())
		return
	var/mob/living/user = usr
	if(istype(user))
		if(!user.aiming)
			user.aiming = new(user)
		user.aiming.toggle_active()

/obj/screen/gun/radio
	name = "Disallow Radio Use"
	icon_state = "no_radio1"
	screen_loc = ui_gun4

/obj/screen/gun/radio/Click(location, control, params)
	if(!..())
		return
	var/mob/living/user = usr
	if(istype(user))
		if(!user.aiming)
			user.aiming = new(user)
		user.aiming.toggle_permission(TARGET_CAN_RADIO)
