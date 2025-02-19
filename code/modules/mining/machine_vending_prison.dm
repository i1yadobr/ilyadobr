// TODO(rufus): make this dispenser randomly break, requiring an engineer to come to the location,
//   thus giving inmates a chance to mug the engineer and revolt against seccies.
// TODO(rufus): make this dispenser spit out worthless trash or just wrong items occassionally and
//   adjust the description to further reflect that this machine is a cheap, broken, overused refurbish.
//   If you're feeling creative, feel free to adjust the sprite too, making it look more broken and dirty.
// TODO(rufus): make this dispenser get "stuck". Fairly often too, 20% maybe?, prison must be frustrating.
//   For implementation example by https://github.com/igorsaux from Chaotic Onyx team, see:
//   https://github.com/ChaoticOnyx/OnyxBay/commit/549674fb78e67496e494e56a1d280ce23403219b
// TODO(rufus): make this dispenser randomly spit out machine oil at the user and stain their clothes
//   spilled oil is /obj/effect/decal/cleanable/blood/oil, staining is *probably* /atom/proc/add_blood
// TODO(rufus): review the list of equipment and see if more junk could be added to it.
//   Ideally there should be a separate list of stuff that can drop randomly but is not on the main list,
//   see the "refurbished" reference in the description. The prices might need adjustment, depending on the mapgen amount of ore.
/obj/machinery/mineral/equipment_vendor/prison
	name = "prison mining gear dispenser"
	desc = "A dusty refurbished vending machine. Originally developed for the prison labor program, this \"Old Betsy\" is now full of mining equipment, occasional junk, and frequent disappointment. Points earned from ore processing can be exchanged here for tools, gear, and some questionable consumables."
	icon_state = "mining-prison"
	equipment_list = list(  //keep formatted and ordered by price
	new /datum/data/mining_equipment("Soy Dope",                           /obj/item/reagent_containers/food/soydope,                         20,     5),
	new /datum/data/mining_equipment("Match",                              /obj/item/flame/match,                                             -1,    10),
	new /datum/data/mining_equipment("Cigarette Trans-Stellar Duty-frees", /obj/item/clothing/mask/smokable/cigarette,                        30,    15),
	new /datum/data/mining_equipment("Cigarette Jerichos",                 /obj/item/clothing/mask/smokable/cigarette/jerichos,               20,    20),
	new /datum/data/mining_equipment("Cigarette Professional 120s",        /obj/item/clothing/mask/smokable/cigarette/professionals,          15,    25),
	new /datum/data/mining_equipment("Boiled rice",                        /obj/item/reagent_containers/food/boiledrice,                      30,    25),
	new /datum/data/mining_equipment("Synthetic meat",                     /obj/item/reagent_containers/food/meat/syntiflesh,                 30,    30),
	new /datum/data/mining_equipment("Space Cola",                         /obj/item/reagent_containers/vessel/can/cola,                      30,    30),
	new /datum/data/mining_equipment("Thermostabilizine Pill",             /obj/item/reagent_containers/pill/leporazine,                      15,    35),
	new /datum/data/mining_equipment("Dexalin Pill",                       /obj/item/reagent_containers/pill/dexalin,                         15,    35),
	new /datum/data/mining_equipment("Radfi-X",                            /obj/item/reagent_containers/hypospray/autoinjector/antirad/mine,  15,    35),
	new /datum/data/mining_equipment("Breath mask",                        /obj/item/clothing/mask/breath/emergency,                          -1,    30),
	new /datum/data/mining_equipment("Basic oxygen tank",                  /obj/item/tank/emergency/oxygen,                                   -1,    30),
	new /datum/data/mining_equipment("Oxygen tank",                        /obj/item/tank/emergency/oxygen/engi,                              -1,    50),
	new /datum/data/mining_equipment("Double oxygen tank",                 /obj/item/tank/emergency/oxygen/double,                            -1,    70),
	new /datum/data/mining_equipment("5 Red Flags",                        /obj/item/stack/flag/red,                                          10,    50),
	new /datum/data/mining_equipment("Meat Pizza",                         /obj/item/pizzabox/meat,                                           25,    60),
	new /datum/data/mining_equipment("Ore-bag",                            /obj/item/storage/ore,                                             25,    60),
	new /datum/data/mining_equipment("Ore Scanner Pad",                    /obj/item/ore_radar,                                               10,    60),
	new /datum/data/mining_equipment("Lantern",                            /obj/item/device/flashlight/lantern,                               10,    75),
	new /datum/data/mining_equipment("Wrench",                             /obj/item/wrench,                                                   5,    80),
	new /datum/data/mining_equipment("Screwdriver",                        /obj/item/screwdriver,                                              5,    80),
	new /datum/data/mining_equipment("Shovel",                             /obj/item/shovel,                                                  15,   100),
	new /datum/data/mining_equipment("Meson HUD goggles",                  /obj/item/clothing/glasses/hud/standard/meson,                     10,   100),
	new /datum/data/mining_equipment("Silver Pickaxe",                     /obj/item/pickaxe/silver,                                          10,   100),
	new /datum/data/mining_equipment("Work gloves",                        /obj/item/clothing/gloves/thick,                                   10,   110),
	new /datum/data/mining_equipment("Workboots",                          /obj/item/clothing/shoes/workboots,                                10,   110),
	new /datum/data/mining_equipment("Hard hat",                           /obj/item/clothing/head/hardhat/orange,                            10,   150),
	new /datum/data/mining_equipment("Ore Box",                            /obj/structure/ore_box,                                            -1,   150),
	new /datum/data/mining_equipment("Emergency Floodlight",               /obj/item/floodlight_diy,                                          -1,   150),
	new /datum/data/mining_equipment("Premium Cigar",                      /obj/item/clothing/mask/smokable/cigarette/cigar/havana,           30,   150),
	new /datum/data/mining_equipment("Lottery Chip",                       /obj/item/spacecash/ewallet/lotto,                                 50,   200),
	new /datum/data/mining_equipment("Mining Drill",                       /obj/item/pickaxe/drill,                                                 10,   200),
	new /datum/data/mining_equipment("Deep Ore Scanner",                   /obj/item/mining_scanner,                                          10,   250),
	new /datum/data/mining_equipment("Autochisel",                         /obj/item/autochisel,                                              10,   400),
	new /datum/data/mining_equipment("The advanced power cell",            /obj/item/cell/high,		                                           3,   450),
	new /datum/data/mining_equipment("Industrial Drill Brace",             /obj/machinery/mining/brace,                                       -1,   500),
	new /datum/data/mining_equipment("Point Transfer Card",                /obj/item/card/mining_point_card,                                  -1,   500),
	new /datum/data/mining_equipment("The gas mask",	                   /obj/item/clothing/mask/gas/clear,                                 10,   500),
	new /datum/data/mining_equipment("Explorer's Belt",                    /obj/item/storage/belt/mining,                                     10,   500),
	new /datum/data/mining_equipment("First-Aid Kit",                      /obj/item/storage/firstaid/regular,                                30,   600),
	new /datum/data/mining_equipment("Ore Magnet",                         /obj/item/oremagnet,                                               10,   600),
	new /datum/data/mining_equipment("Minecart",                           /obj/structure/closet/crate/miningcar,                             -1,   600),
	new /datum/data/mining_equipment("Sonic Jackhammer",                   /obj/item/pickaxe/jackhammer,                                       2,   700),
	new /datum/data/mining_equipment("Ore Summoner",                       /obj/item/oreportal,                                                3,   800),
	new /datum/data/mining_equipment("Heavy-duty cell charger",            /obj/machinery/cell_charger,                                        1,   800),
	new /datum/data/mining_equipment("Lazarus Injector",                   /obj/item/lazarus_injector,                                        25,  1000),
	new /datum/data/mining_equipment("Industrial Drill Head",              /obj/machinery/mining/drill,                                       -1,  1000),
	new /datum/data/mining_equipment("Diamond Pickaxe",                    /obj/item/pickaxe/diamond,                                         10,  1500)
)
