#ifndef T_BOARD
#error T_BOARD macro is not defined but we need it!
#endif

// TODO(rufus): move all circuits under code/game/objects/items/circuitboards
//   there's absolutely no need for them to be near their machniery defines

/obj/item/circuitboard/aicore
	name = T_BOARD("AI core")
	origin_tech = list(TECH_DATA = 4, TECH_BIO = 2)
	board_type = "other"

/obj/item/circuitboard/refiner
	name = T_BOARD("ore processor")
	origin_tech = list(TECH_MAGNET = 2, TECH_ENGINEERING = 2)
	board_type = "other" // change this to machine if you want it to be buildable
	req_components = list(/obj/item/stock_parts/capacitor = 2,
						  /obj/item/stock_parts/scanning_module = 1,
						  /obj/item/stock_parts/matter_bin = 1,
						  /obj/item/stock_parts/micro_laser = 2)

/obj/item/circuitboard/machine/mining_equipment_vendor
	name = "circuit board (Mining Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor
	origin_tech = list(TECH_DATA = 1, TECH_ENGINEERING = 1)
	req_components = list(/obj/item/stock_parts/console_screen = 1,
						  /obj/item/stock_parts/matter_bin = 3)

/obj/item/circuitboard/machine/mining_equipment_vendor/prison
	name = "circuit board (Mining Prison Equipment Vendor)"
	build_path = /obj/machinery/mineral/equipment_vendor/prison
