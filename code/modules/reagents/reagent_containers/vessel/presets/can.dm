///
/// Presets for /obj/item/reagent_containers/vessel/can
///

/obj/item/reagent_containers/vessel/can/cola
	name = "\improper Space Cola"
	desc = "Cola. In space."
	description_fluff = "Space Cola is the most popular drink made by Robust Industries LLC. \
	While it is only slightly different from traditional cola recipes, its blend of syrups and sugars is enticing to children and adults alike."
	icon_state = "cola"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/cola
	startswith = list(/datum/reagent/drink/space_cola = 40)

/obj/item/reagent_containers/vessel/can/colavanilla
	name = "\improper Vanilla Space Cola"
	desc = "Vanilla Cola. in space."
	icon_state = "colavanilla"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/colavanilla
	startswith = list(/datum/reagent/drink/space_cola = 30,
					  /datum/reagent/drink/milkshake = 10)

/obj/item/reagent_containers/vessel/can/colacherry
	name = "\improper Cherry Space Cola"
	desc = "Cherry Cola. in space."
	icon_state = "colacherry"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/colacherry
	startswith = list(/datum/reagent/drink/space_cola = 30,
					  /datum/reagent/nutriment/cherryjelly = 10)

/obj/item/reagent_containers/vessel/can/dopecola
	name = "\improper Dope Cola"
	desc = "Some sort of Cola. in space."
	icon_state = "dopecola"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/dopecola
	startswith = list(/datum/reagent/drink/space_cola = 30,
					  /datum/reagent/thc = 10)

/obj/item/reagent_containers/vessel/can/space_mountain_wind
	name = "\improper Space Mountain Wind"
	desc = "Blows right through you like a space wind."
	description_fluff = "This cola was allegedly made after Vasily Federov, the son of a Robust Industries executive, \
	who went on a climbing expedition to an arctic planet. Inspired by the crisp planetary atmosphere, he created this \
	refreshing citrus-flavored soft drink. \
	Scientists claim that it can eat through a block of styrofoam in a matter of weeks, but people drink it anyway."
	icon_state = "space_mountain_wind"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/space_mountain_wind
	startswith = list(/datum/reagent/drink/spacemountainwind = 40)

/obj/item/reagent_containers/vessel/can/thirteenloko
	name = "\improper Thirteen Loko"
	desc = "The CMO has advised crew members that consumption of Thirteen Loko may result in seizures, \
	blindness, drunkeness, or even death. Please Drink Responsibly."
	description_fluff = "A beverage much-loved by college students. This liver-tingling cocktail is a careful fusion of \
	energy drink and malt beverage. It is prohibited on many human colonies and habitats, but legislation adding the drink \
	to the Sol Central Government list of Controlled Substances has stalled thanks to strong corporate resistance \
	in the Colonial Assembly. Regardless, this drink has been regulated more heavily than most others in known space, \
	and doctors strongly advise not to drink it."
	icon_state = "thirteen_loko"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/thirteenloko
	startswith = list(/datum/reagent/ethanol/thirteenloko = 40)

/obj/item/reagent_containers/vessel/can/dr_gibb
	name = "\improper Dr. Gibb"
	desc = "A delicious mixture of 42 different flavors."
	description_fluff = "Originally made by a corporate scientist seeking to mix several different flavors, this soda has become \
	widely popular in the past decade. In 2555, Robust Industries changed the formula, and the name to 'Gibb Xtreme,' but due to \
	consumer outcry at the new taste, Gibb classic was returned to the market."
	icon_state = "dr_gibb"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/dr_gibb
	startswith = list(/datum/reagent/drink/dr_gibb = 40)

/obj/item/reagent_containers/vessel/can/starkist
	name = "\improper Star-kist"
	desc = "The taste of a star in liquid form. And, a bit of tuna...?"
	description_fluff = "Unable to make their own successful orange-flavored drink, Robust Industries purchased Sunshine Chemistry, \
	and the formula to their tangy Starkist soda. Advertised as a refreshing summer beverage, the company tries to paint it as one of \
	their more 'healthy' products due to its 'orange' and 'vitamins', including 'fish oil'."
	icon_state = "starkist"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/starkist
	startswith = list(/datum/reagent/drink/brownstar = 40)

/obj/item/reagent_containers/vessel/can/space_up
	name = "\improper Space-Up"
	desc = "Tastes like a hull breach in your mouth."
	description_fluff = "This drink is advertised as one of the most carbonated beverages on the market and is advertised \
	for its carbonation, not its flavor. Children will commonly make 'Space-Up Volcanoes' by dropping mints into a can of Space-Up \
	and causing it to create a long stream of fizz upward. Doctors advise that children do not attempt to become 'Space-Up Dragons'."
	icon_state = "space-up"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/space_up
	startswith = list(/datum/reagent/drink/space_up = 40)

/obj/item/reagent_containers/vessel/can/lemon_lime
	name = "\improper Lemon-Lime"
	desc = "You wanted ORANGE. It gave you Lemon Lime."
	description_fluff = "This is a Robust Industries-branded can of Lemon-Lime soda. Trumpeted as a 'natural' beverage, \
	it contains no fruit or fruit byproducts. It was never as popular as their now discontinued Oh-Range brand."
	icon_state = "lemon-lime"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/lemon_lime
	startswith = list(/datum/reagent/drink/lemon_lime = 40)

/obj/item/reagent_containers/vessel/can/iced_tea
	name = "\improper Vrisk Serket Iced Tea"
	desc = "That sweet, refreshing southern earthy flavor. That's where it's from, right? South Earth?"
	description_fluff = "Vrisk Iced Tea is named after it's creator, Penelope Vrisk. She was a canner for Robust Industries \
	who wanted to create an authentic-tasting Southern iced tea. After finishing her formula and managing to get it produced, \
	the tea became an instant hit."
	icon_state = "ice_tea_can"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/iced_tea
	startswith = list(/datum/reagent/drink/tea/icetea = 40)

/obj/item/reagent_containers/vessel/can/grape_juice
	name = "\improper Grapel Juice"
	desc = "500 pages of rules of how to appropriately enter into a combat with this juice!"
	description_fluff = "Made by the Robust Industries sub-corporation, Grape!, the product line claims that they use the same grapes \
	that this juice is made of to make their wine. Either way, it contains real fruit, imagine that."
	icon_state = "purple_can"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/grape_juice
	startswith = list(/datum/reagent/drink/juice/grape = 40)

/obj/item/reagent_containers/vessel/can/tonic
	name = "\improper T-Borg's Tonic Water"
	desc = "Quinine tastes funny, but at least it'll keep that Space Malaria away."
	description_fluff = "Endorsed by the popular positronic rapper, T-Borg, this beverage is advertised as a 'high class' drink. \
	Most people just use it to mix with their gin, and not much can be said about the quality."
	icon_state = "tonic"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/tonic
	startswith = list(/datum/reagent/drink/tonic = 40)

/obj/item/reagent_containers/vessel/can/sodawater
	name = "soda water"
	desc = "A can of soda water. Still water's more refreshing cousin."
	description_fluff = "Considered by many to be proof that Robust Industries sells no non-carbonated beverages, lack of sugar or \
	flavoring agents means this stuff isn't exactly flying off of the shelves."
	icon_state = "sodawater"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/sodawater
	startswith = list(/datum/reagent/drink/sodawater = 40)

/obj/item/reagent_containers/vessel/can/machpellabeer
	name = "\improper Machpella Dark Beer"
	desc = "A can of Machpella Dark Beer. Makes your feel like a real Space Ranger!"
	icon_state = "machpellabeer"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/machpellabeer
	startswith = list(/datum/reagent/ethanol/beer/dark/machpella = 40)

/obj/item/reagent_containers/vessel/can/applecider
	name = "\improper MeadBy Apple Cider"
	desc = "Name brand MeadBy sparkling alcoholic beverage product."
	icon_state = "applecider"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/applecider
	startswith = list(/datum/reagent/ethanol/cider/apple = 40)

/obj/item/reagent_containers/vessel/can/red_mule
	name = "\improper Red MULE"
	desc = "Contains high levels of caffeine. Prohibited for use by children, pregnant women, people sensitive to caffeine, people not sensitive to caffeine, tajaran, animals and medical bots."
	icon_state = "red_mule"
	center_of_mass = "x=16;y=10"
	trash = /obj/item/trash/cans/red_mule
	startswith = list(/datum/reagent/drink/energy = 40)
