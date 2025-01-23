/datum/guncase_spawn_option
	// name is user friendly name of the option that will be presented in the UI.
	var/name
	// codename is a shortened name of the spawn option that will be used in topic calls.
	var/codename
	// desc is the full description that will be presented in the UI when this option is selected.
	var/desc
	// spawn_items is list of type paths of items to spawn.
	// An optional assoc value may be specified to spawn multiple copies of the item.
	var/list/spawn_items

// Detective guncase

/datum/guncase_spawn_option/m1911
	name = "M1911"
	codename = "m1911"
	desc = "A cheap Martian knock-off of a Colt M1911. Uses .45 rounds. \
	        Extremely popular among space detectives nowadays.<br>\
	        Comes with six .45 seven-round magazines: two rubber, two stun, and two live ammo."
	spawn_items = list(
		/obj/item/gun/projectile/pistol/colt/detective,
		/obj/item/ammo_magazine/c45m/rubber = 2,
		/obj/item/ammo_magazine/c45m/stun = 2,
		/obj/item/ammo_magazine/c45m = 2
	)

/datum/guncase_spawn_option/sw_legacy
	name = "S&W Legacy"
	codename = "sw_legacy"
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 10. Uses .38 rounds. \
	        Used to be NanoTrasen's service weapon for detectives.<br>\
	        Comes with four .38 six-round speedloaders: two rubber and two live ammo."
	spawn_items = list(
		/obj/item/gun/projectile/revolver/detective,
		/obj/item/ammo_magazine/c38/rubber = 2,
		/obj/item/ammo_magazine/c38 = 2
	)

/datum/guncase_spawn_option/sw620
	name = "S&W 620"
	codename = "sw620"
	desc = "A cheap Martian knock-off of a Smith & Wesson Model 620. Uses .38 rounds. \
	        Quite popular among professionals.<br>\
	        Comes with four .38 six-round speedloaders: two rubber and two live ammo."
	spawn_items = list(
		/obj/item/gun/projectile/revolver/detective/saw620,
		/obj/item/ammo_magazine/c38/rubber = 2,
		/obj/item/ammo_magazine/c38 = 2
	)

/datum/guncase_spawn_option/m2019
	name = "M2019 Detective Special"
	codename = "m2019"
	desc = "Quite a controversial weapon. Combining both pros and cons of revolvers and railguns, \
	        it's extremely versatile, yet requires a lot of care.<br>\
	        Comes with an extra power cell and five .38 five-round speedloaders: three SPEC-type and two CHEM-type.<br><br>\
	        Brief instructions:<br>\
	        - M2019 Detective Special can be loaded with any type .38 rounds, yet works best with .38 CHEM and .38 SPEC.<br>\
	        - With a powercell installed, M2019 can be used in two modes: non-lethal and lethal.<br>\
	        - .38 SPEC no cell - acts like rubber ammunition.<br>\
	        - .38 SPEC non-lethal - stuns the target.<br>\
	        - .38 SPEC lethal - accelerates the bullet, improving its stopping power and piercing properties.<br>\
	        - .38 CHEM no cell - acts like flash ammunition.<br>\
	        - .38 CHEM non-lethal - emits a weak electromagnetic impulse.<br>\
	        - .38 CHEM lethal - not intended for use, the cartridge quickly melts under high temperatures."
	spawn_items = list(
		/obj/item/gun/projectile/revolver/m2019/detective,
		/obj/item/ammo_magazine/c38/spec = 3,
		/obj/item/ammo_magazine/c38/chem = 2,
		/obj/item/cell/device/high
	)

/datum/guncase_spawn_option/t9
	name = "T9 Patrol"
	codename = "t9"
	desc = "A relatively cheap and reliable knock-off of a Beretta M9. Uses 9mm rounds. \
	        Used to be a standart-issue gun in almost every security company.<br>\
	        Comes with five 9mm ten-round magazines: two flash and three live ammo."
	spawn_items = list(
		/obj/item/gun/projectile/pistol/det_m9,
		/obj/item/ammo_magazine/mc9mm/flash = 2,
		/obj/item/ammo_magazine/mc9mm = 3
	)

// Security guncase

/datum/guncase_spawn_option/taser_pistol
	name = "Taser Pistol"
	codename = "taser_pistol"
	desc = "A taser pistol. The smallest of all the tasers. It only has a single fire mode, but each shot wields power.<br>\
	        Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts."
	spawn_items = list(
		/obj/item/gun/energy/security/pistol,
		/obj/item/shield/barrier,
		/obj/item/melee/baton/loaded,
		/obj/item/handcuffs = 2,
		/obj/item/reagent_containers/food/donut/normal = 2
	)

/datum/guncase_spawn_option/taser_smg
	name = "Taser SMG"
	codename = "taser_smg"
	desc = "A taser SMG. This model is not as powerful as pistols, but is capable of \
	        launching electrodes left and right with its remarkable rate of fire.<br>\
	        Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts."
	spawn_items = list(
		/obj/item/gun/energy/security/smg,
		/obj/item/shield/barrier,
		/obj/item/melee/baton/loaded,
		/obj/item/handcuffs = 2,
		/obj/item/reagent_containers/food/donut/normal = 2
	)

/datum/guncase_spawn_option/taser_rifle
	name = "Taser Rifle"
	codename = "taser_rifle"
	desc = "A taser rifle. Bulky and heavy, it must be wielded with both hands. \
	        Although its rate of fire is way below average, it is capable of shooting stun beams.<br>\
	        Comes with a baton, a handheld barrier, a couple of handcuffs, and a pair of donuts."
	spawn_items = list(
		/obj/item/gun/energy/security/rifle,
		/obj/item/shield/barrier,
		/obj/item/melee/baton/loaded,
		/obj/item/handcuffs = 2,
		/obj/item/reagent_containers/food/donut/normal = 2
	)

/datum/guncase_spawn_option/taser_classic
	name = "Rusty Classic"
	codename = "classic"
	desc = "A rusty-and-trusty taser. It's overall worse than the modern baseline tasers, but it still \
	        does its job. Useful for those who want to assert their robust dominance. Or, maybe, for old farts.<br>\
	        Comes with a baton, a couple of handcuffs, a pair of donuts, and a drink to stay cool."
	spawn_items = list(
		/obj/item/gun/energy/classictaser,
		/obj/item/melee/baton/loaded,
		/obj/item/handcuffs = 2,
		/obj/item/reagent_containers/food/donut/normal = 2
	)

/datum/guncase_spawn_option/taser_classic/New()
	if(prob(70))
		spawn_items += /obj/item/reagent_containers/vessel/bottle/small/darkbeer
	else
		spawn_items += /obj/item/reagent_containers/vessel/bottle/whiskey
