var/const/CLICK_HANDLER_NONE                 = 0
var/const/CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT = 1
var/const/CLICK_HANDLER_ALL                  = (~0)

// Click handlers are strucutres that determine how a user click should be handled.
// Every mob keeps track of their click handlers in a `click_handlers` var which is operated as a stack.
// This means mob can have multiple click handlers, but only the last added one actually handles clicks.
//
// Default click handler (defined in this file) simply forwards click calls to a mob-specific ClickOn(atom)
// proc without any additional checks or handling.
//
// Unique click handlers are defined alongside their relevant modules/logic.
// Currently these are abilities, spells, and admin's build mode.
//
// See code/modules/mob/mob_defines.dm for the definition of mob's click handlers storage.
// See code/_onclick/click.dm for an overview of click handling in general.
/datum/click_handler
	var/mob/user
	var/flags = 0
	var/species
	var/mouse_icon
	var/handler_name

/datum/click_handler/New(mob/user)
	..()
	src.user = user
	if(flags & (CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT))
		register_signal(user, SIGNAL_LOGGED_OUT, nameof(.proc/OnMobLogout))

/datum/click_handler/Destroy()
	if(flags & (CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT))
		unregister_signal(user, SIGNAL_LOGGED_OUT, nameof(.proc/OnMobLogout))
	user = null
	. = ..()

/datum/click_handler/proc/Enter()
	return

/datum/click_handler/proc/Exit()
	return

/datum/click_handler/proc/OnMobLogout()
	user.RemoveClickHandler(src)

/datum/click_handler/proc/OnClick(atom/A, params)
	return

/datum/click_handler/proc/OnDblClick(atom/A, params)
	return

// Default click handlers simply forward the call to mob's ClickOn() proc.
//
// Since click handlers store a reference to their mob, the call is forwarded to the correct
// implementation automatically.
// For example:
// When /mob/living/silicon/ai clicks on anything, the call from /atom/Click() arrives here, and is then
// forwarded to AI-specific /mob/living/silicon/ai/ClickOn() where unique AI logic is applied.
//
// This means that this is the spot where clicks are split into logic appropriate for a specific mob type.
/datum/click_handler/default/OnClick(atom/A, params)
	user.ClickOn(A, params)

/datum/click_handler/default/OnDblClick(atom/A, params)
	user.DblClickOn(A, params)
