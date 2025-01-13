// TODO(rufus): move this file out of the _onclick folder as it defines functions widely
//   used outside of _onclick code.
/*
	Adjacency proc for determining touch range

	This is mostly to determine if a user can enter a square for the purposes of touching something.
	Examples include reaching a square diagonally or reaching something on the other side of a glass window.

	This is calculated by looking for border items, or in the case of clicking diagonally from yourself, dense items.
	This proc will NOT notice if you are trying to attack a window on the other side of a dense object in its turf.  There is a window helper for that.

	Note that in all cases the neighbor is handled simply; this is usually the user's mob, in which case it is up to you
	to check that the mob is not inside of something
*/
/atom/proc/Adjacent(atom/neighbor, atom/target) // basic inheritance, unused
	return FALSE


// Not a sane use of the function and indicative of an error elsewhere
/area/Adjacent(atom/neighbor, atom/target)
	CRASH("Call to /area/Adjacent(), unimplemented proc")


/*
	Adjacency (to anything else):
	* Must be on a turf
	* In the case of a multiple-tile object, all valid locations are checked for adjacency.

	Note: Multiple-tile objects are created when the bound_width and bound_height are greater than the tile size.
*/
/atom/movable/Adjacent(atom/neighbor, atom/target)
	if(neighbor == loc || neighbor.loc == loc)
		return TRUE
	if(!isturf(loc))
		return FALSE
	for(var/turf/T in locs)
		if(isnull(T))
			continue
		if(T.Adjacent(neighbor, target = neighbor))
			return TRUE
	return FALSE


// This is necessary for storage items not on your person.
/obj/item/Adjacent(atom/neighbor, atom/target, recurse = 1)
	if(neighbor == loc)
		return TRUE
	if(istype(loc, /obj/item))
		if(recurse > 0)
			return loc.Adjacent(neighbor, target, recurse - 1)
		return FALSE
	return ..()


// TurfAdjacent of base mob type checks if mob is 1 or less tiles away from turf T and returns a boolean.
/mob/proc/TurfAdjacent(turf/T)
	return T.AdjacentQuick(src)

// TurfAdjacent of observer ghosts checks if turf T is withing the view range of the ghost client and returns a boolean.
/mob/observer/ghost/TurfAdjacent(turf/T)
	if(!isturf(loc) || !client)
		return FALSE
	return z == T.z && (get_dist(loc, T) <= client.view)

// TurfAdjacent of AI checks if turf is visible on any cameras and returns a boolean.
/mob/living/silicon/ai/TurfAdjacent(turf/T)
	return (cameranet && cameranet.is_turf_visible(T))


// AdjacentQuick of turfs checks if atom A is 1 or less tiles away from the turf and returns a boolean.
/turf/proc/AdjacentQuick(atom/A)
	var/turf/T = get_turf(A)
	if(T == src || (get_dist(src, T) <= 1))
		return TRUE
	return FALSE

/*
	Adjacency (to turf):
	* If you are in the same turf, always true
	* If you are vertically/horizontally adjacent, ensure there are no border objects
	* If you are diagonally adjacent, ensure you can pass through at least one of the mutually adjacent square.
		* Passing through in this case ignores anything with the throwpass flag, such as tables, racks, and morgue trays.
*/
/turf/Adjacent(atom/neighbor, atom/target)
	var/turf/T0 = get_turf(neighbor)
	if(T0 == src)
		return TRUE
	if(!T0 || T0.z != z)
		return FALSE
	if(get_dist(src, T0) > 1)
		return FALSE

	if(T0.x == x || T0.y == y)
		// Check for border blockages
		return T0.ClickCross(get_dir(T0, src), TRUE, target) && ClickCross(get_dir(src, T0), TRUE, target)

	// Not orthagonal
	var/in_dir = get_dir(neighbor,src) // eg. northwest (1+8)
	var/d1 = in_dir&(in_dir-1)		// eg west		(1+8)&(8) = 8
	var/d2 = in_dir - d1			// eg north		(1+8) - 8 = 1

	for(var/d in list(d1,d2))
		if(!T0.ClickCross(d, TRUE, target))
			continue // could not leave T0 in that direction

		var/turf/T1 = get_step(T0, d)
		if(!T1 || T1.density)
			continue

		if(!T1.ClickCross(get_dir(T1, src), FALSE, target) || !T1.ClickCross(get_dir(T1, T0), FALSE, target))
			continue // couldn't enter or couldn't leave T1

		if(!ClickCross(get_dir(src, T1), TRUE, target))
			continue // could not enter src

		return TRUE // we don't care about our own density
	return FALSE

/*
	This checks if you there is uninterrupted airspace between that turf and this one.
	This is defined as any dense ATOM_FLAG_CHECKS_BORDER object, or any dense object without throwpass.
	The border_only flag allows you to not objects (for source and destination squares)
*/
/turf/proc/ClickCross(target_dir, border_only, atom/target)
	for(var/obj/O in src)
		if(!O.density || O == target || O.throwpass)
			continue // throwpass is used for anything you can click through

		if(O.atom_flags & ATOM_FLAG_CHECKS_BORDER) // windows have throwpass but are on border, check them first
			if(O.dir & target_dir || O.dir & (O.dir-1)) // full tile windows are just diagonals mechanically
				var/obj/structure/window/W = target
				if(istype(W) && (W.is_fulltile() || W.dir == O.dir)) //exception for breaking full tile windows on top of single pane windows
					return TRUE
				if(istype(target, /obj/structure/window_frame)) // the same as full tile windows exception, but for the new ones
					return TRUE
				if(target && (target.atom_flags & ATOM_FLAG_ADJACENT_EXCEPTION)) // exception for atoms that should always be reachable
					return TRUE
				else
					return FALSE

		else if(!border_only) // dense, not on border, cannot pass over
			return FALSE
	return TRUE
/*
	Aside: throwpass does not do what I thought it did originally, and is only used for checking whether or not
	a thrown object should stop after already successfully entering a square.  Currently the throw code involved
	only seems to affect hitting mobs, because the checks performed against objects are already performed when
	entering or leaving the square.  Since throwpass isn't used on mobs, but only on objects, it is effectively
	useless.  Throwpass may later need to be removed and replaced with a passcheck (bitfield on movable atom passflags).

	Since I don't want to complicate the click code rework by messing with unrelated systems it won't be changed here.
*/
