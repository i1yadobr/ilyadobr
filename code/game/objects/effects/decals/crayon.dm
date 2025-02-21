/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."

	var/decal_icon = 'icons/effects/crayondecal.dmi'
	var/global/decal_icon_states = icon_states('icons/effects/crayondecal.dmi')
	var/graffiti_icon = 'icons/effects/crayongraffiti.dmi'
	var/global/graffiti_icon_states = icon_states('icons/effects/crayongraffiti.dmi')

/obj/effect/decal/cleanable/crayon/Initialize(mapload, main = "#ffffff", shade = "#000000", drawing = "rune1", visible_name = "drawing")
	. = ..()
	name = visible_name
	desc = "A [visible_name] drawn in crayon."

	if(drawing in decal_icon_states)
		icon = decal_icon
	else if(drawing in graffiti_icon_states)
		icon = graffiti_icon
	else
		CRASH("crayon drawing \"[drawing]\" not present in decal or graffiti icon states")

	icon_state = drawing
	// see https://www.byond.com/docs/ref/#/{notes}/color-matrix
	// 3 x ignore color transforms, 1 x keep alpha intact, 1 x add main color as constant
	color = list(rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,255), main)

	var/image/shade_overlay = image(icon, "[drawing]_s")
	shade_overlay.appearance_flags = RESET_COLOR
	// see https://www.byond.com/docs/ref/#/{notes}/color-matrix
	// 3 x ignore color transforms, 1 x keep alpha intact, 1 x add shade color as constant
	shade_overlay.color = list(rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,0), rgb(0,0,0,255), shade)
	overlays += shade_overlay

	add_hiddenprint(usr)

// get_graffiti_preview generates new icon files with crayon graffiti previews and uploads them to the user
// cache, as well as returns the filename of the newly generated icon.
// It is used by the crayon UI to allow users to select a drawing with dynamic image previews.
/proc/get_graffiti_preview(main_color = "#ffffff", shade_color = "#000000", icon_state = "rune1", mob/user)
	var/file = 'icons/effects/crayongraffiti.dmi'
	if(!(icon_state in icon_states(file)))
		CRASH("crayon graffiti '[icon_state]' doesn't exist")

	var/icon/main_icon = icon(file, icon_state)
	main_icon.Blend(main_color, ICON_ADD)

	var/shade_icon_state = "[icon_state]_s"
	if(!(shade_icon_state in icon_states(file)))
		CRASH("crayon graffiti shading '[shade_icon_state]' doesn't exist")
	var/icon/shade_overlay = icon(file, shade_icon_state)
	shade_overlay.Blend(shade_color, ICON_ADD)

	main_icon.Blend(shade_overlay, ICON_OVERLAY)

	var/preview_filename = "[icon_state]-crayon-[copytext(main_color, 2)]-[copytext(shade_color, 2)].png"
	// This uploads the icon to the user's cache without actually opening anything
	// and allows the crayon UI to reference this preview in the html using the specified filename.
	// See https://www.byond.com/docs/ref/#/proc/browse
	show_browser(user, main_icon, "file=[preview_filename];display=0")
	return preview_filename
