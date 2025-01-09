// Utility procs to operate click_handlers of the mob.
// See mob's click_handlers definition in code/modules/mob/mob_defines.dm for more information.
// See code/_onclick/click_handler.dm for more information on click_handlers in general.
// See code/_onclick/click.dm for a general overview of how clicks are handled.
/mob/proc/GetClickHandler(datum/click_handler/popped_handler)
	if(!click_handlers)
		click_handlers = new()
	if(click_handlers.is_empty())
		PushClickHandler(/datum/click_handler/default)
	return click_handlers.Top()

/mob/proc/RemoveClickHandler(datum/click_handler/click_handler)
	if(!click_handlers)
		return

	var/was_top = click_handlers.Top() == click_handler

	if(was_top)
		click_handler.Exit()
	click_handlers.Remove(click_handler)
	qdel(click_handler)

	if(!was_top)
		return
	click_handler = click_handlers.Top()
	if(click_handler)
		click_handler.Enter()

/mob/proc/PopClickHandler()
	if(!click_handlers)
		return
	RemoveClickHandler(click_handlers.Top())

/mob/proc/PushClickHandler(datum/click_handler/new_click_handler_type)
	if((initial(new_click_handler_type.flags) & CLICK_HANDLER_REMOVE_ON_MOB_LOGOUT) && !client)
		return FALSE
	if(!click_handlers)
		click_handlers = new()
	var/datum/click_handler/click_handler = click_handlers.Top()
	if(click_handler)
		click_handler.Exit()

	click_handler = new new_click_handler_type(src)
	click_handler.Enter()
	click_handlers.Push(click_handler)

	return click_handler
