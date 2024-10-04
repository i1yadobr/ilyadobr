/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "plating"

/turf/unsimulated/floor/bluespace //non-doomsday version of bluespace for transit and wizden
	name = "\improper bluespace"
	icon = 'icons/turf/space.dmi'
	icon_state = "bluespace"
	desc = "Looks like infinity."

// NOTE(rufus): currently these only exist for the convenience of mappers,
//   but could very well be replaced with a single mask and a bunch of mapping prefabs
//   with respecitve icon states and variables defining what the mask should be replaced with
// TODO(rufus): these masks need to be properly organized in terms of theri .dmi files,
//   right now these are part of walls.dmi, yet asteroid.dmi exists for some reason
/turf/unsimulated/mask
	name = "asteroid cave system mask"
	icon = 'icons/turf/walls.dmi'
	icon_state = "asteroid_mask"

/turf/unsimulated/mask/air
	name = "asteroid cave air mask"
	icon_state = "asteroid_air_mask"

/turf/unsimulated/mask/air/prison
	name = "asteroid cave prison air mask"
	icon_state = "asteroid_prison_air_mask"

/turf/unsimulated/floor/rescue_base
	icon_state = "asteroidfloor"

/turf/unsimulated/floor/shuttle_ceiling
	icon_state = "reinforced"
