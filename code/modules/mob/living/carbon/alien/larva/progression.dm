#define DESC_EVOLVE SPAN("notice", "<b>You are growing into a beautiful alien! It is time to choose a caste.</b>\nThere are three to choose from:")
#define DESC_HUNTER "\n<B>Hunters</B> [SPAN("notice", " are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves.")]"
#define DESC_SENTINEL "\n<B>Sentinels</B> [SPAN("notice", " are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters, but regenerate faster.")]"
#define DESC_DRONE "\n<B>Drones</B> [SPAN("notice", " are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen.")]"
#define DESC_HUNTER_FERAL "\n<B>Feral Hunters</B> [SPAN("notice", " are strong and agile, able to hunt away from the hive and rapidly move through ventilation shafts. Hunters generate plasma slowly and have low reserves. <B>Tajaran genome further improves their claws and tails structure, making them much sharper.</B>")]"
#define DESC_SENTINEL_PRIMAL "\n<B>Primal Sentinels</B> [SPAN("notice", " are tasked with protecting the hive and are deadly up close and at a range. They are not as physically imposing nor fast as the hunters, but regenerate faster. <B>Unathi genome slightly increases their thermal resistance and drastically improves regenerative abilities.</B>")]"
#define DESC_DRONE_VILE "\n<B>Vile Drones</B> [SPAN("notice", " are the working class, offering the largest plasma storage and generation. They are the only caste which may evolve again, turning into the dreaded alien queen. <B>Skrellian genome improves their intelligence, as well as the plasma secretion rate.</B>")]"

/mob/living/carbon/alien/larva/confirm_evolution()
	to_chat(src, DESC_EVOLVE + DESC_HUNTER + DESC_SENTINEL + DESC_DRONE)
	var/alien_caste = alert(src, "Please choose which alien caste you shall belong to.",,"Hunter","Sentinel","Drone")
	return alien_caste ? "Xenomorph [alien_caste]" : null

/mob/living/carbon/alien/larva/show_evolution_blurb()
	return
