// click_catcher is a special invisible screen object that handles darkness clicks, so anything outside of the mob's view.
// A 15x15 tile grid of click catchers is created for every player on /mob/Login(), which by default means
// the entier player screen.
// Click catcher system expects mob view to be 15x15 (`view` radius of 7), and doesn't scale as view changes.
//
// Click cathers are placed on a special CLICKCATCHER_PLANE with value -500, the lowest of all planes in the game.
// This results in click catchers always being below everything else on the user's screen.

// Current darkness system removes all atoms on a tile from the mob's view, so a fully dark tile doesn't have anything on it.
// However, since click catchers are screen objects perfectly aligned to the mobs 15x15 tile view, they don't disappear in
// the darkness. Similarly to HUD elements, but with a fully transparent texture, they silently catch every click that
// didn't land on any other object in the mob's viewport.
// `mouse_opacity` 2 makes the click catcher clickable even though its texture is fully transparent.
//
// This is currently only used to handle middle mouse button clicks on darkness to swaps active hand.
// All other clicks fall through to a turf Click().
// TODO(rufus): the above has an unintended effect of allowing players to click darkness. This is currently
//   used by experienced vampire players to ability-click on a turf they can't see to teleport (Veil Step ability).
//   Determine if it's better to leave this as an unintended secret feature or to fix this and add a proper
//   hidden functionality that would allow for a similar effect.
// To view and debug click catchers:
//  - set `plane` to a visible one, e.g. DEFAULT_PLANE
//  - set `icon_state` to "click_catcher_dbg" so becomes visible
//  - set `name` to any text string, e.g. "click catcher debug", otherwise it's not clickable or viewable with the context menu
//
// See the `void` variable on /client in code/modules/client/client_defines.dm for the variable that uses click_catchers.
/obj/screen/click_catcher
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "blank"
	plane = CLICKCATCHER_PLANE
	mouse_opacity = 2
	screen_loc = "CENTER-7,CENTER-7"

/obj/screen/click_catcher/Destroy()
	..()
	return QDEL_HINT_LETMELIVE

// create_click_catcher creates a 15x15 tile grid of click catchers and assigns correct screen_loc positions to them.
// It currently is hardcoded to a 15x15 size, relying on the fact that mob view range is 7 tiles.
// TODO(rufus): update click catcher system to dynamically resize with the mob's view.
/proc/create_click_catcher()
	var/grid = list()
	for(var/i = 0, i<15, i++)
		for(var/j = 0, j<15, j++)
			var/obj/screen/click_catcher/CC = new()
			CC.screen_loc = "NORTH-[i],EAST-[j]"
			grid += CC
	return grid

/obj/screen/click_catcher/Click(location, control, params)
	var/list/modifiers = params2list(params)
	if(modifiers["middle"] && istype(usr, /mob/living/carbon))
		var/mob/living/carbon/C = usr
		C.swap_hand()
		return
	var/turf/T = screen_loc2turf(screen_loc, get_turf(usr))
	if(T)
		T.Click(location, control, params)

// TODO(rufus): move to mob folder as this is a mob proc
// add_click_catcher is used to add click cather grid to the mob's view.
// It is called on every /mob/Login() in code/modules/mob/login.dm.
// It creates a new click_catcher grid the first time it's called. All consecutive calls reuse the same
// click catcher grid because `void` variable on /client is defined as global.
/mob/proc/add_click_catcher()
	if(!client.void)
		client.void = create_click_catcher()
	if(!client.screen)
		client.screen = list()
	client.screen |= client.void

/mob/new_player/add_click_catcher()
	return
