/mob/living/MiddleClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/powersuit_activation) == GLOB.PREF_MIDDLE_CLICK)
		if(PowersuitClickOn(A))
			return
	..()

/mob/living/AltClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/powersuit_activation) == GLOB.PREF_ALT_CLICK)
		if(PowersuitClickOn(A))
			return
	..()

/mob/living/CtrlClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/powersuit_activation) == GLOB.PREF_CTRL_CLICK)
		if(PowersuitClickOn(A))
			return
	..()

/mob/living/CtrlShiftClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/powersuit_activation) == GLOB.PREF_CTRL_SHIFT_CLICK)
		if(PowersuitClickOn(A))
			return
	..()

/mob/living/ShiftMiddleClickOn(atom/A)
	if(get_preference_value(/datum/client_preference/powersuit_activation) == GLOB.PREF_SHIFT_MIDDLE_CLICK)
		if(PowersuitClickOn(A))
			return
	..()


/mob/living/proc/can_use_rig()
	return FALSE

/mob/living/carbon/human/can_use_rig()
	return TRUE

/mob/living/carbon/brain/can_use_rig()
	return istype(loc, /obj/item/device/mmi)

/mob/living/silicon/ai/can_use_rig()
	return carded

/mob/living/silicon/pai/can_use_rig()
	return loc == card

// Return value determines if click was handled by the powersuit module.
// If not, the click falls through to regular click handling of the mob.
/mob/living/proc/PowersuitClickOn(atom/A)
	if(!can_use_rig() || !canClick())
		return FALSE
	var/obj/item/rig/rig = get_rig()
	if(istype(rig) && !rig.offline && rig.selected_module)
		if(src != rig.wearer)
			if(rig.ai_can_move_suit(src, check_user_module = TRUE))
				message_admins("[key_name_admin(src, include_name = TRUE)] is trying to force \the [key_name_admin(rig.wearer, include_name = TRUE)] to use a powersuit module.")
			else
				return FALSE
		rig.selected_module.engage(A)
		if(ismob(A)) // No instant mob attacking - though modules have their own cooldowns
			setClickCooldown(DEFAULT_ATTACK_COOLDOWN)
		return TRUE
	return FALSE
