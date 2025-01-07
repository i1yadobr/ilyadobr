/obj/item/gun/launcher/net
	name = "net gun"
	desc = "Specially made-to-order by Xenonomix, the XX-1 \"Varmint Catcher\" is designed to trap even the most unruly of creatures for safe transport."
	icon_state = "netgun"
	item_state = "netgun"
	fire_sound = 'sound/weapons/empty.ogg'
	fire_sound_text = "a metallic thunk"

	var/obj/item/net_shell/chambered

/obj/item/net_shell
	name = "net gun shell"
	desc = "A casing containing an autodeploying net for use in a net gun. Kind of looks like a flash light."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "netshell"

/obj/item/gun/launcher/net/_examine_text(mob/user)
	. = ..()
	if(get_dist(src, user) <= 2 && chambered)
		. += "\n\A [chambered] is chambered."

/obj/item/gun/launcher/net/proc/load(obj/item/net_shell/S, mob/user)
	if(chambered)
		to_chat(user, SPAN("warning", "\The [src] already has a shell loaded."))
		return

	user.drop(S, src)
	chambered = S
	user.visible_message("\The [user] inserts \a [S] into \the [src].", SPAN("notice", "You insert \a [S] into \the [src]."))

/obj/item/gun/launcher/net/proc/unload(mob/user)
	if(chambered)
		user.visible_message("\The [user] removes \the [chambered] from \the [src].", SPAN("notice", "You remove \the [chambered] from \the [src]."))
		user.pick_or_drop(chambered, loc)
		chambered = null
	else
		to_chat(user, SPAN("warning", "\The [src] is empty."))

/obj/item/gun/launcher/net/attackby(obj/item/I, mob/user)
	if((istype(I, /obj/item/net_shell)))
		load(I, user)
	else
		..()

/obj/item/gun/launcher/net/attack_hand(mob/user)
	if(user.get_inactive_hand() == src)
		unload(user)
	else
		..()

/obj/item/gun/launcher/net/consume_next_projectile()
	if(chambered)
		qdel(chambered)
		chambered = null
		return new /obj/item/energy_net/safari(src)

	return null
