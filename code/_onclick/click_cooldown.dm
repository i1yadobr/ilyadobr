// setClickCooldown sets a secondary cooldown on the user actions and may be used to limit user clicks for a certain time
// after an action.
//
// This is not called automatically in any way and is intended to be used by atoms/objects code
// to apply custom delay.
//
// The delay is shared with all other objects, so setting click cooldown on one object will block
// the mob from clicking anything else until the cooldown is over.
/mob/proc/setClickCooldown(timeout)
	next_move = max(world.time + timeout, next_move)

/mob/proc/canClick()
	// NOTE: this checks for next_move, which is different from next_click used by
	//   mob/proc/OnClick() to enforce a 1 decisecond limit
	if(config.misc.no_click_cooldown || next_move <= world.time)
		return TRUE
	return FALSE
