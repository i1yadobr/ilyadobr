/datum/click_handler/spiders/charge/OnClick(atom/target)
	if(!istype(user,/mob/living/simple_animal/hostile/giant_spider))
		CRASH("spider charge click_handler used by non-spider mob, got: '[user.type]'")
	var/mob/living/simple_animal/hostile/giant_spider/spider = user
	var/datum/action/cooldown/charge/action = locate() in spider.actions
	spider.PopClickHandler()
	action.ActivateOnClick(target)
	action.active = FALSE

/datum/click_handler/spiders/wrap/OnClick(atom/target)
	if(!istype(user,/mob/living/simple_animal/hostile/giant_spider))
		CRASH("spider wrap click_handler used by non-spider mob, got: '[user.type]'")
	var/mob/living/simple_animal/hostile/giant_spider/spider = user
	var/datum/action/innate/spider/wrap/action = locate() in spider.actions
	spider.PopClickHandler()
	action.ActivateOnClick(target)
