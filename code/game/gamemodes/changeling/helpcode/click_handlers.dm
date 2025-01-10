// sting click_handler for changelings verifies that user is a changeling, allows the click to
// fall through if clicked target is not another human, and calls sting logic if it is.
// It is up to caller to remove this click handler from the user after the sting is performed.
/datum/click_handler/changeling/sting
	var/datum/changeling_power/toggled/sting/sting = null

/datum/click_handler/changeling/sting/OnClick(atom/target)
	if(!sting)
		return
	if(!user?.mind?.changeling)
		return
	if(!ishuman(target) || (target == user))
		target.Click()
		return
	sting.sting_target(target)
	return

// infest click_handler calls infest logic of the little_changeling user and pops itself from the
// click_handler stack.
// It is intended to only be used by little_changelings in their out-of-host form, but does not perform
// any checks in this regard.
/datum/click_handler/changeling/infest
	handler_name = "Infest"

/datum/click_handler/changeling/infest/OnClick(atom/target)
	var/mob/living/simple_animal/hostile/little_changeling/L = user
	user.PopClickHandler() // Executing it earlier since user gets lost during successful infest()
	L.infest(target)
	return

// paralyse click_handler calls paralysis sting logic of the little_changeling user and pops itself from the
// click_handler stack.
// It is intended to only be used by little_changelings in their out-of-host form, but does not perform
// any checks in this regard.
/datum/click_handler/changeling/paralyse
	handler_name = "Paralyse"

/datum/click_handler/changeling/paralyse/OnClick(atom/target)
	var/mob/living/simple_animal/hostile/little_changeling/L = user
	L.paralyse_sting(target)
	user.PopClickHandler()
	return
