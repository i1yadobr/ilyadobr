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

// Returns icon if receiver is not specified, or name of created .png file otherwise
/proc/get_crayon_preview(main = "#ffffff",shade = "#000000", drawing = "rune1", mob/receiver)
	var/icon_file
	for(var/file in list('icons/effects/crayondecal.dmi', 'icons/effects/crayongraffiti.dmi'))
		if(drawing in icon_states(file))
			icon_file = file
			break
	if(!icon_file)
		CRASH("Crayon drawing named '[drawing]' doesn't exist")

	var/icon/mainOverlay = new /icon(icon_file, drawing, 2.1)
	mainOverlay.Blend(main,ICON_ADD)

	var/shade_drawing = "[drawing]_s"
	if(shade_drawing in icon_states(icon_file))
		var/icon/shadeOverlay = new /icon(icon_file, shade_drawing, 2.1)
		shadeOverlay.Blend(shade,ICON_ADD)
		mainOverlay.Blend(shadeOverlay, ICON_OVERLAY)

	if(!receiver)
		return mainOverlay
	else
		var/resourse_name = "[drawing]-crayon-[copytext(main,2)]-[copytext(shade,2)].png"
		show_browser(receiver, mainOverlay, "file=[resourse_name];display=0")
		return resourse_name
