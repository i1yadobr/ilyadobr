
/obj/machinery/atmospherics/pipe/simple/heat_exchanging
	icon = 'icons/atmos/heat.dmi'
	icon_state = "intact"
	description_info = "This radiates heat from the pipe's gas to space, cooling it down."
	pipe_icon = "hepipe"
	color = "#404040"
	level = 2
	connect_types = CONNECT_TYPE_HE
	var/initialize_directions_he
	var/surface = 2	//surface area in m^2
	var/icon_temperature = 20 CELSIUS //stop small changes in temperature causing an icon refresh
	var/is_wall_radiator = FALSE

	minimum_temperature_difference = 20
	thermal_conductivity = OPEN_HEAT_TRANSFER_COEFFICIENT

	maximum_pressure = 360*ONE_ATMOSPHERE
	fatigue_pressure = 300*ONE_ATMOSPHERE
	alert_pressure = 360*ONE_ATMOSPHERE

	can_buckle = 1
	buckle_lying = 1

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/New()
	..()
	initialize_directions_he = initialize_directions	// The auto-detection from /pipe is good enough for a simple HE pipe
	color = "#404040" //we don't make use of the fancy overlay system for colours, use this to set the default.

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/atmos_init()
	..()
	normalize_dir()
	var/node1_dir
	var/node2_dir

	for(var/direction in GLOB.cardinal)
		if(direction&initialize_directions_he)
			if (!node1_dir)
				node1_dir = direction
			else if (!node2_dir)
				node2_dir = direction

	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node1_dir))
		if(target.initialize_directions_he & get_dir(target,src))
			node1 = target
			break
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,node2_dir))
		if(target.initialize_directions_he & get_dir(target,src))
			node2 = target
			break
	if(!node1 && !node2)
		qdel(src)
		return

	update_icon()

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/Process()
	if(!parent)
		..()
	else
		var/datum/gas_mixture/pipe_air = return_air()
		if(istype(loc, /turf/simulated/))
			var/environment_temperature = 0
			if(loc:blocks_air)
				environment_temperature = loc:temperature
			else
				var/datum/gas_mixture/environment = loc.return_air()
				environment_temperature = environment.temperature
			if(abs(environment_temperature-pipe_air.temperature) > minimum_temperature_difference)
				parent.temperature_interact(loc, volume, thermal_conductivity)
		else if(istype(loc, /turf/space/))
			parent.radiate_heat_to_space(surface, 1)

		if(buckled_mob)
			var/hc = pipe_air.heat_capacity()
			var/avg_temp = (pipe_air.temperature * hc + buckled_mob.bodytemperature * 3500) / (hc + 3500)
			pipe_air.temperature = avg_temp
			buckled_mob.bodytemperature = avg_temp

			var/heat_limit = 1000

			var/mob/living/carbon/human/H = buckled_mob
			if(istype(H) && H.species)
				heat_limit = H.species.heat_level_3

			if(pipe_air.temperature > heat_limit + 1)
				buckled_mob.apply_damage(4 * log(pipe_air.temperature - heat_limit), BURN, BP_CHEST, used_weapon = "Excessive Heat")

		//fancy radiation glowing
		if(pipe_air.temperature && (icon_temperature > 500 || pipe_air.temperature > 500)) //start glowing at 500K
			if(abs(pipe_air.temperature - icon_temperature) > 10)
				icon_temperature = pipe_air.temperature

				var/h_r = heat2color_r(icon_temperature)
				var/h_g = heat2color_g(icon_temperature)
				var/h_b = heat2color_b(icon_temperature)

				if(icon_temperature < 2000) //scale up overlay until 2000K
					var/scale = (icon_temperature - 500) / 1500
					h_r = 64 + (h_r - 64)*scale
					h_g = 64 + (h_g - 64)*scale
					h_b = 64 + (h_b - 64)*scale

				animate(src, color = rgb(h_r, h_g, h_b), time = 20, easing = SINE_EASING)




/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction
	icon = 'icons/atmos/junction.dmi'
	icon_state = "intact"
	pipe_icon = "hejunction"
	level = 2
	connect_types = CONNECT_TYPE_REGULAR|CONNECT_TYPE_HE

// Doubling up on initialize_directions is necessary to allow HE pipes to connect
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/New()
	.. ()
	switch (dir)
		if (SOUTH)
			initialize_directions_he = SOUTH
			initialize_directions = NORTH|SOUTH
		if (NORTH)
			initialize_directions_he = NORTH
			initialize_directions = NORTH|SOUTH
		if (EAST)
			initialize_directions_he = EAST
			initialize_directions = EAST|WEST
		if (WEST)
			initialize_directions_he = WEST
			initialize_directions = EAST|WEST

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/atmos_init()
	..()
	// Only check back side for normal pipes
	for(var/obj/machinery/atmospherics/target in get_step(src,GLOB.flip_dir[src.dir]))
		if(target.initialize_directions & get_dir(target,src))
			// Snowflake check; keeps back from connecting to HE pipes
			if(!istype(target,/obj/machinery/atmospherics/pipe/simple/heat_exchanging))
				node1 = target
				break
	// Only check front side for HE pipes
	for(var/obj/machinery/atmospherics/pipe/simple/heat_exchanging/target in get_step(src,initialize_directions_he))
		if(target.initialize_directions_he & get_dir(target,src))
			node2 = target
			break

	if(!node1 && !node2)
		qdel(src)
		return

	update_icon()

/* WALL RADIATORS */
/obj/machinery/atmospherics/pipe/simple/heat_exchanging/proc/set_wall_radiator_dirs()
	return is_wall_radiator


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/wall_radiator
	color = null
	icon='icons/atmos/wall_radiator.dmi'
	pipe_icon = "hewall"

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/wall_radiator/New()
	..()
	set_wall_radiator_dirs()
	color=null
	plane = DEFAULT_PLANE
	is_wall_radiator = TRUE

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/set_wall_radiator_dirs()
	.=..()
	if(!.)
		return

	switch (dir)
		if (SOUTH)
			initialize_directions_he = WEST
			initialize_directions = EAST|WEST
			pixel_y=-13
		if (NORTH)
			initialize_directions_he = WEST
			initialize_directions = EAST|WEST
			pixel_y=13
		if (EAST)
			initialize_directions_he = SOUTH
			initialize_directions = SOUTH|NORTH
			pixel_x=2
		if (WEST)
			initialize_directions_he = SOUTH
			initialize_directions = SOUTH|NORTH
			pixel_x=-2


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/wall_radiator/left
	icon='icons/atmos/wall_radiator_junction_left.dmi'
	pipe_icon = "hewalljunction_left"
	color=null

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/wall_radiator/left/New()
	.. ()
	set_wall_radiator_dirs()
	color=null
	plane = DEFAULT_PLANE
	is_wall_radiator = TRUE

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/wall_radiator/left/set_wall_radiator_dirs()
	.=..()
	if(!.)
		return

	switch (dir)
		if (SOUTH)
			initialize_directions_he = WEST
			initialize_directions = EAST|WEST
			pixel_y=-13
		if (NORTH)
			initialize_directions_he = WEST
			initialize_directions = EAST|WEST
			pixel_y=13
		if (EAST)
			initialize_directions_he = NORTH
			initialize_directions = SOUTH|NORTH
			pixel_x=2
		if (WEST)
			initialize_directions_he = SOUTH
			initialize_directions = SOUTH|NORTH
			pixel_x=-2


/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/wall_radiator/right
	icon='icons/atmos/wall_radiator_junction_right.dmi'
	pipe_icon = "hewalljunction_right"
	color=null

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/wall_radiator/right/New()
	.. ()
	set_wall_radiator_dirs()
	color=null
	plane = DEFAULT_PLANE
	is_wall_radiator = TRUE

/obj/machinery/atmospherics/pipe/simple/heat_exchanging/junction/wall_radiator/right/set_wall_radiator_dirs()
	.=..()
	if(!.)
		return

	switch (dir)
		if (SOUTH)
			initialize_directions_he = EAST
			initialize_directions = EAST|WEST
			pixel_y=-13
		if (NORTH)
			initialize_directions_he = EAST
			initialize_directions = EAST|WEST
			pixel_y=13
		if (EAST)
			initialize_directions_he = SOUTH
			initialize_directions = SOUTH|NORTH
			pixel_x=2
		if (WEST)
			initialize_directions_he = NORTH
			initialize_directions = SOUTH|NORTH
			pixel_x=-2
