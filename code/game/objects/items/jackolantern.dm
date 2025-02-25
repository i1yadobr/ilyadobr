/obj/item/jackolantern
	name = "jack o'lantern"
	desc = "Spooky."
	icon = 'icons/obj/halloween/jackolantern.dmi'
	icon_state = "jackolantern-owo"
	w_class = ITEM_SIZE_NORMAL
	var/lit_up = FALSE

/obj/item/jackolantern/attackby(obj/item/W, mob/user)
	if(W.get_temperature_as_from_ignitor() && !lit_up)
		user.visible_message(SPAN("notice", "\The [user] lit up \the [src] with \the [W]."), SPAN("notice", "You lit up \the [src] with \the [W]."))
		lit_up = TRUE
		set_light(0.5, 0.1, 2, 2, COLOR_ORANGE)
		icon_state = "[initial(icon_state)]_lit_up"
		set_next_think(world.time + 1 SECOND)

/obj/item/jackolantern/attack_self(mob/user)
	if(lit_up)
		user.visible_message(SPAN("notice", "\The [user] put out \the [src]."), SPAN("notice", "You put out \the [src]."))
		lit_up = FALSE
		set_light(0)
		icon_state = "[initial(icon_state)]"
		set_next_think(0)

/obj/item/jackolantern/think()
	var/turf/place = get_turf(src)
	place.hotspot_expose(700, 5)

	set_next_think(world.time + 1 SECOND)

/obj/item/jackolantern/get_temperature_as_from_ignitor()
	if(lit_up)
		return 1500
	return 0

/obj/item/jackolantern/best
	name = "jack o'lantern"
	desc = "He looks awesome."
	icon_state = "jackolantern"

/obj/item/jackolantern/girl
	name = "jack o'lantern"
	desc = "Jack o'lantern-women were introduced after complaints of their masculinity.."
	icon_state = "jackolantern-girly"

/obj/item/jackolantern/scream
	name = "jack o'lantern"
	desc = "The creator of this pumpkin is clearly inspired by the great work."
	icon_state = "jackolantern-scream"

/obj/item/jackolantern/old
	name = "jack o'lantern"
	desc = "A classic that will never become obsolete."
	icon_state = "jackolantern-original"
