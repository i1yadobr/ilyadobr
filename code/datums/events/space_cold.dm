// TODO(rufus): disabled event (unticked from .dme), annoying, unbalanced mtth,
//   and impossible to deal with if there are no medics.
//   While it makes some sense from the realism perspective, in practice it's just an annoying spam
//   of snot decals and slightly inconvenient symptoms. Needs total overhaul together with virology.
/datum/event/space_cold
	id = "space_cold"
	name = "Space Cold Outbreak"
	description = "An epidemic of the space cold"

	mtth = 1 HOURS
	difficulty = 30

/datum/event/space_cold/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Medical"] * (3 MINUTE))
	. = max(1 HOUR, .)

/datum/event/space_cold/on_fire()
	var/list/candidates = list()

	for(var/mob/living/carbon/human/G in GLOB.player_list)
		if(G.client && G.stat != DEAD && !G.species.get_virus_immune(G))
			candidates += G

	if(!candidates.len)
		return

	var/datum/disease2/disease/sniffle = new
	sniffle.max_stage = 3
	sniffle.makerandom(1)
	sniffle.spreadtype = "Airborne"

	var/victims = min(rand(1,3), candidates.len)
	while(victims)
		infect_virus2(pick_n_take(candidates), sniffle, 1)
		victims--
