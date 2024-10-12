// TODO(rufus): currently only adds a random order to the "shopping list" with a null reason,
//   which is then quickly discarded by anyone with access because everyone understands it's a randomevent.
//   Consider adding random semi-realistic reasons, more possibilities like orders being automatically accepted,
//   maybe automatic shuttle calls, maybe ordering something with a negative price which would result in extra
//   points added to cargo balance, and so on. Anything to brigten up the current implementation.
/datum/event/shipping_error
	id = "shipping_error"
	name = "Shipping Error"
	description = "A random parcel will appear in the cargo department"

	mtth = 1 HOURS
	difficulty = 10

/datum/event/shipping_error/get_mtth()
	. = ..()
	. -= (SSevents.triggers.living_players_count * (4 MINUTES))
	. = max(1 HOUR, .)

/datum/event/shipping_error/on_fire()
	var/datum/supply_order/O = new /datum/supply_order()
	O.ordernum = SSsupply.ordernum
	O.object = pick(cargo_supply_packs)
	O.orderedby = random_name(pick(MALE,FEMALE), species = SPECIES_HUMAN)
	// TODO(rufus): add O.reason with some random reasons, potentially localized,
	//   as right now the reason is displayed as "null" in game, giving out the fakeness of the event
	SSsupply.shoppinglist += O
