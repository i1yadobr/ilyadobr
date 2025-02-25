/mob/living/simple_animal/hostile/syndicate
	name = "\improper Syndicate operative"
	desc = "Death to the Company."
	icon_state = "syndicate"
	icon_living = "syndicate"
	icon_dead = "syndicate_dead"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	speed = 4
	stop_automated_movement_when_pulled = 0
	maxHealth = 100
	health = 100
	harm_intent_damage = 5
	melee_damage_lower = 10
	melee_damage_upper = 10
	can_escape = 1
	attacktext = "punched"
	a_intent = I_HURT
	bodyparts = /decl/simple_animal_bodyparts/humanoid
	var/corpse = /obj/effect/landmark/corpse/syndicate
	var/weapon1
	var/weapon2
	unsuitable_atoms_damage = 15
	environment_smash = 1
	faction = "syndicate"
	status_flags = CANPUSH

/mob/living/simple_animal/hostile/syndicate/death(gibbed, deathmessage, show_dead_message)
	..(gibbed, deathmessage, show_dead_message)
	if(corpse)
		new corpse (src.loc)
	if(weapon1)
		new weapon1 (src.loc)
	if(weapon2)
		new weapon2 (src.loc)
	qdel(src)
	return

///////////////Sword and shield////////////

/mob/living/simple_animal/hostile/syndicate/melee
	melee_damage_lower = 20
	melee_damage_upper = 25
	icon_state = "syndicatemelee"
	icon_living = "syndicatemelee"
	weapon1 = /obj/item/melee/energy/sword/one_hand/red
	weapon2 = /obj/item/shield/energy
	attacktext = "slashed"
	status_flags = 0

/mob/living/simple_animal/hostile/syndicate/melee/attackby(obj/item/O as obj, mob/user as mob)
	if(O.force)
		if(prob(80))
			var/damage = O.force
			if (O.damtype == PAIN)
				damage = 0
			health -= damage
			visible_message(SPAN("danger", "\The [src] has been attacked with \the [O] by \the [user]."))
		else
			visible_message(SPAN("danger", "\The [src] blocks the [O] with its shield!"))
		//user.do_attack_animation(src)
	else
		to_chat(usr, SPAN("warning", "This weapon is ineffective, it does no damage."))
		visible_message(SPAN("warning", "\The [user] gently taps \the [src] with \the [O]."))


/mob/living/simple_animal/hostile/syndicate/melee/bullet_act(obj/item/projectile/Proj)
	if(!Proj)	return
	if(prob(65))
		src.health -= Proj.damage
	else
		visible_message(SPAN("danger", "\The [src] blocks \the [Proj] with its shield!"))
	return 0

/mob/living/simple_animal/hostile/syndicate/melee/weaponless
	weapon1 = null
	weapon2 = null

/mob/living/simple_animal/hostile/syndicate/melee/space
	min_gas = null
	max_gas = null
	minbodytemp = 0
	icon_state = "syndicatemeleespace"
	icon_living = "syndicatemeleespace"
	name = "Syndicate Commando"
	corpse = /obj/effect/landmark/corpse/syndicate
	speed = 0

/mob/living/simple_animal/hostile/syndicate/ranged
	ranged = 1
	rapid = 1
	icon_state = "syndicateranged"
	icon_living = "syndicateranged"
	casingtype = /obj/item/ammo_casing/a10mm/used
	projectilesound = 'sound/effects/weapons/gun/fire_generic_smg.ogg'
	projectiletype = /obj/item/projectile/bullet/pistol/medium

	weapon1 = /obj/item/gun/projectile/automatic/c20r

/mob/living/simple_animal/hostile/syndicate/ranged/weaponless
	weapon1 = null

/mob/living/simple_animal/hostile/syndicate/ranged/space
	icon_state = "syndicaterangedpsace"
	icon_living = "syndicaterangedpsace"
	name = "Syndicate Commando"
	min_gas = null
	max_gas = null
	minbodytemp = 0
	corpse = /obj/effect/landmark/corpse/syndicate/commando
	speed = 0

/mob/living/simple_animal/hostile/viscerator
	name = "viscerator"
	desc = "A small, twin-bladed machine capable of inflicting very deadly lacerations."
	icon = 'icons/mob/critter.dmi'
	icon_state = "viscerator_attack"
	icon_living = "viscerator_attack"
	pass_flags = PASS_FLAG_TABLE
	health = 15
	maxHealth = 15
	melee_damage_lower = 15
	melee_damage_upper = 15
	attacktext = "cut"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = "syndicate"
	min_gas = null
	max_gas = null
	minbodytemp = 0

/mob/living/simple_animal/hostile/viscerator/death(gibbed, deathmessage, show_dead_message)
	..(null,"is smashed into pieces!", show_dead_message)
	qdel(src)
