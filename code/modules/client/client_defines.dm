/client
	// * Black magic things *
	parent_type = /datum

	// * Admin things *
	var/datum/admins/holder = null
	var/datum/admins/deadmin_holder = null
	var/adminobs = null
	var/adminhelped = 0
	var/watchlist_warn = null

	// void is a list of /obj/screen/click_catcher's used to capture user clicks on areas outside their mob's view.
	// It is initialized by create_click_catcher() proc and reused for every client (global).
	// This list contains 225 (15*15, based on view radius of 7) special invisible screen objects residing on the lowest
	// view plane that silently handle mouse actions or redirect the Click() call to turfs.
	//
	// This is needed because current click code relies on something actually being clicked, either an atom in the world
	// or a screen (HUD) object. Some actions in the game are triggered on mouse click regardless of where the click
	// happened, for example switching active hand or activating a RIG ability on middle mouse button click.
	// The darkness system simulates darkness by removing everything present on a tile from
	// the mob's view, including the turf. The darkness system does not remove screen objects, however.
	// Invisible click_catchers use this to make dark areas still clickable, which allows players to utilize middle
	// mouse button anywhere on the viewport.
	//
	// See code/_onclick/hud/click_catcher.dm for more information about how this is set up.
	// See code/_onclick/click.dm for an overview of click handling in general.
	var/global/list/void

	var/datum/preferences/prefs = null
	var/species_ingame_whitelisted = FALSE

	/*
	As of byond 512, due to how broken preloading is, preload_rsc MUST be set to 1 at compile time if resource URLs are *not* in use,
	BUT you still want resource preloading enabled (from the server itself). If using resource URLs, it should be set to 0 and
	changed to a URL at runtime (see client_procs.dm for procs that do this automatically). More information about how goofy this broken setting works at
	http://www.byond.com/forum/post/1906517?page=2#comment23727144
	*/
	preload_rsc = 1

	// * Sound stuff *
	var/ambience_playing = null
	var/played = 0
	// Start playing right from the start.
	var/last_time_ambient_music_played = -AMBIENT_MUSIC_COOLDOWN

	// Prevents people from being spammed about multikeying every time their mob changes.
	var/warned_about_multikeying = 0

	var/datum/eams_info/eams_info = new
	var/list/topiclimiter

	// * Database related things *

	// So admins know why it isn't working - Used to determine how old the account is - in days.
	var/player_age = "Requires database"

	// So admins know why it isn't working - Used to determine what other accounts previously logged in from this ip
	var/related_accounts_ip = "Requires database"

	// So admins know why it isn't working - Used to determine what other accounts previously logged in from this computer id
	var/related_accounts_cid = "Requires database"

	// used for initial centering of saywindow
	var/first_say = TRUE

	// For tracking shift key (world.time)
	var/shift_released_at = 0

	// Settings window.
	var/datum/player_settings/settings = null

	// Messages currently seen by this client
	var/list/seen_messages

	// connected external accounts e.g. discord
	var/list/connected_accounts
