// TODO(rufus): rename to something more descriptive that dumbfire, for example "untargeted"
// dumbfire is a projectile spell that fires a projectile in the direction user is facing
/datum/spell/targeted/projectile/dumbfire
	name = "dumbfire spell"

// choose_targets for dumbfire spells returns the furthest turf in user's view direction within spell range.
// If edge of the map is encountered, the turf just before the end of the map is returned.
// The return value is a /list(turf) if turf is found.
// Otherwise this process crashes as it must not be reachable when it's not possible to determine a turf target.
/datum/spell/targeted/projectile/dumbfire/choose_targets(mob/user = usr)
	var/turf/current_turf = get_turf(user)
	if(!istype(current_turf))
		CRASH("can't find a valid turf under the user for dumbfire spell targeting, got: '[current_turf]'")
	for(var/i = 1; i <= range; i++)
		var/turf/next_turf = get_step(current_turf, user.dir)
		if(!istype(next_turf))
			return list(current_turf)
		current_turf = next_turf
	return list(current_turf)
