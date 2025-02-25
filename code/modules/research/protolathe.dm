/obj/machinery/r_n_d/protolathe
	name = "\improper Protolathe"
	icon_state = "protolathe"
	atom_flags = ATOM_FLAG_OPEN_CONTAINER

	layer = BELOW_OBJ_LAYER

	idle_power_usage = 30 WATTS
	active_power_usage = 5 KILO WATTS

	var/max_material_storage = 100000

	var/list/datum/design/queue = list()
	var/progress = 0

	var/mat_efficiency = 1
	var/speed = 1

	var/list/item_type = list("Stock Parts", "Bluespace", "Data", "Engineering", "Medical", "Surgery",
	"Mining", "Robotics", "Weapons", "Misc", "Device", "PDA", "RIG")

/obj/machinery/r_n_d/protolathe/Initialize()
	materials = default_material_composition.Copy()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/circuitboard/protolathe(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/matter_bin(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/stock_parts/manipulator(src)
	component_parts += new /obj/item/reagent_containers/vessel/beaker(src)
	component_parts += new /obj/item/reagent_containers/vessel/beaker(src)
	RefreshParts()

/obj/machinery/r_n_d/protolathe/Process()
	..()
	if(stat)
		update_icon()
		return
	if(queue.len == 0)
		busy = 0
		update_icon()
		return
	var/datum/design/D = queue[1]
	if(canBuild(D))
		busy = 1
		progress += speed
		if(progress >= D.time)
			build(D)
			progress = 0
			removeFromQueue(1)
			if(linked_console)
				linked_console.updateUsrDialog()
		update_icon()
	else
		if(busy)
			visible_message(SPAN("notice", "\icon [src] flashes: insufficient materials: [getLackingMaterials(D)]."))
			busy = 0
			update_icon()

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/reagent_containers/vessel/G in component_parts)
		T += G.reagents.maximum_volume
	create_reagents(T)
	max_material_storage = 0
	for(var/obj/item/stock_parts/matter_bin/M in component_parts)
		max_material_storage += M.rating * 75000
	T = 0
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		T += M.rating
	mat_efficiency = 1 - (T - 2) / 8
	speed = T / 2


/obj/machinery/r_n_d/protolathe/update_icon()
	if(panel_open)
		icon_state = "protolathe_t"
	else if(busy)
		icon_state = "protolathe_n"
	else
		icon_state = "protolathe"

/obj/machinery/r_n_d/protolathe/attackby(obj/item/O as obj, mob/user as mob)
	if(busy)
		to_chat(user, SPAN("notice", "\The [src] is busy. Please wait for completion of previous operation."))
		return 1
	if(default_deconstruction_screwdriver(user, O))
		if(linked_console)
			linked_console.linked_lathe = null
			linked_console = null
		return
	if(default_deconstruction_crowbar(user, O))
		return
	if(default_part_replacement(user, O))
		return
	if(O.is_open_container())
		return 1
	if(panel_open)
		to_chat(user, SPAN("notice", "You can't load \the [src] while it's opened."))
		return 1
	if(!linked_console)
		to_chat(user, SPAN("notice", "\The [src] must be linked to an R&D console first!"))
		return 1
	if(is_robot_module(O))
		return 0
	if(!istype(O, /obj/item/stack/material))
		to_chat(user, SPAN("notice", "You cannot insert this item into \the [src]!"))
		return 0
	if(stat)
		return 1

	if(TotalMaterials() + SHEET_MATERIAL_AMOUNT > max_material_storage)
		to_chat(user, SPAN("notice", "\The [src]'s material bin is full. Please remove material before adding more."))
		return 1

	var/obj/item/stack/material/stack = O
	var/amount = min(stack.get_amount(), round((max_material_storage - TotalMaterials()) / SHEET_MATERIAL_AMOUNT))

	var/t = stack.material.name
	overlays += "protolathe_[t]"
	spawn(10)
		overlays -= "protolathe_[t]"

	busy = 1
	use_power_oneoff(max(1000, (SHEET_MATERIAL_AMOUNT * amount / 10)))
	if(t)
		if(do_after(user, 16,src))
			if(stack.use(amount))
				to_chat(user, SPAN("notice", "You add [amount] sheet\s to \the [src]."))
				materials[t] += amount * SHEET_MATERIAL_AMOUNT
	busy = 0
	updateUsrDialog()
	return

/obj/machinery/r_n_d/protolathe/proc/addToQueue(datum/design/D)
	queue += D
	return

/obj/machinery/r_n_d/protolathe/proc/removeFromQueue(index)
	if(index  == -1)
		queue.Cut()
		return

	queue.Cut(index, index + 1)
	return

/obj/machinery/r_n_d/protolathe/proc/canBuild(datum/design/D, amount_build)
	for(var/M in D.materials)
		if(materials[M] < D.materials[M] * mat_efficiency * amount_build)
			return 0
	for(var/C in D.chemicals)
		if(!reagents.has_reagent(C, D.chemicals[C] * mat_efficiency * amount_build))
			return 0
	return 1

/obj/machinery/r_n_d/protolathe/proc/build(datum/design/D)
	var/power = active_power_usage
	for(var/M in D.materials)
		power += round(D.materials[M] / 5)
	power = max(active_power_usage, power)
	use_power_oneoff(power)
	for(var/M in D.materials)
		materials[M] = max(0, materials[M] - D.materials[M] * mat_efficiency)
	for(var/C in D.chemicals)
		reagents.remove_reagent(C, D.chemicals[C] * mat_efficiency)

	if(D.build_path)
		var/obj/new_item = D.Fabricate(loc, src)
		if(mat_efficiency != 1) // No matter out of nowhere
			if(new_item.matter && new_item.matter.len > 0)
				for(var/i in new_item.matter)
					new_item.matter[i] = new_item.matter[i] * mat_efficiency
