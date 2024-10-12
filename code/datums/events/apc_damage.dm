// TODO(rufus): disabled event (unticked from .dme), not functional.
//   The event is quite minor and just messes with some APCs, but this is boring
//   routine for engineers to just click through and has to be reviewed for potential ways to improve.
//   Given that this is based on a landmark system currently and no maps actually have these landmarks,
//   disabling until this is refactored into some other approach e.g. area- or department-based.
/datum/event/apc_damage
	id = "apc_damage"
	name = "APC Damage"
	description = "Random APC will get damaged"

	mtth = 1 HOURS
	difficulty = 20

	var/apcSelectionRange = 25

/datum/event/apc_damage/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Engineer"] * (12 MINUTES))
	. = max(1 HOUR, .)

/datum/event/apc_damage/on_fire()
	var/obj/machinery/power/apc/A = acquire_random_apc()
	var/severity_range = pick(0, 7, 15)

	for(var/obj/machinery/power/apc/apc in range(severity_range, A))
		if(is_valid_apc(apc))
			apc.emagged = 1
			apc.update_icon()

/datum/event/apc_damage/proc/acquire_random_apc()
	var/list/possibleEpicentres = list()
	var/list/apcs = list()

	// TODO(rufus): refactor this epicentre-landmark-based system into something more dynamic and automated.
	//   Currently there are no landmarks named "lightsout" on any map.
	//   Comparing on name is also a very bad approach because of the possibility to mistype the name,
	//   as well as the necessity to place each such marker manually on each map.
	for(var/obj/effect/landmark/newEpicentre in GLOB.landmarks_list)
		if(newEpicentre.name == "lightsout")
			possibleEpicentres += newEpicentre

	if(!possibleEpicentres.len)
		return

	var/epicentre = pick(possibleEpicentres)
	for(var/obj/machinery/power/apc/apc in range(epicentre, apcSelectionRange))
		if(is_valid_apc(apc))
			apcs += apc
			// Greatly increase the chance for APCs in maintenance areas to be selected
			var/area/A = get_area(apc)
			if(istype(A,/area/maintenance))
				apcs += apc
				apcs += apc

	return safepick(apcs)

/datum/event/apc_damage/proc/is_valid_apc(obj/machinery/power/apc/apc)
	var/turf/T = get_turf(apc)
	return !apc.is_critical && !apc.emagged && T && (T.z in GLOB.using_map.get_levels_with_trait(ZTRAIT_STATION))
