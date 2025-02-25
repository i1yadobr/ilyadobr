/*
	Badges are worn on the belt or neck, and can be used to show the user's credentials.
	The user' details can be imprinted on holobadges with the relevant ID card,
	or they can be emagged to accept any ID for use in disguises.
*/

/obj/item/clothing/accessory/badge
	name = "badge"
	desc = "A leather-backed badge, with gold trimmings."
	icon_state = "detectivebadge"
	slot_flags = SLOT_BELT | SLOT_TIE
	slot = ACCESSORY_SLOT_INSIGNIA
	var/badge_string = "Detective"
	var/stored_name

/obj/item/clothing/accessory/badge/proc/set_name(new_name)
	stored_name = new_name
	name = "[initial(name)] ([stored_name])"

/obj/item/clothing/accessory/badge/attack_self(mob/user)
	if(!stored_name)
		to_chat(user, "You inspect your [src.name]. Everything seems to be in order and you give it a quick cleaning with your hand.")
		set_name(user.real_name)
		return

	if(isliving(user))
		if(stored_name)
			user.visible_message(SPAN("notice", "[user] displays their [src.name].\nIt reads: [stored_name], [badge_string]."),SPAN("notice", "You display your [src.name].\nIt reads: [stored_name], [badge_string]."))
		else
			user.visible_message(SPAN("notice", "[user] displays their [src.name].\nIt reads: [badge_string]."),SPAN("notice", "You display your [src.name]. It reads: [badge_string]."))

/obj/item/clothing/accessory/badge/attack(mob/living/carbon/human/M, mob/living/user)
	if(isliving(user))
		user.visible_message(SPAN("danger", "[user] invades [M]'s personal space, thrusting \the [src] into their face insistently."),SPAN("danger", "You invade [M]'s personal space, thrusting \the [src] into their face insistently."))

/obj/item/clothing/accessory/badge/PI
	name = "private investigator's badge"
	badge_string = "Private Investigator"

/*
 *Holobadges
 */
/obj/item/clothing/accessory/badge/holo
	name = "holobadge"
	desc = "This glowing blue badge marks the holder as a member of security."
	color = COLOR_PALE_BLUE_GRAY
	icon_state = "holobadge"
	item_state = "holobadge"
	badge_string = "Security"
	var/badge_access = access_security
	var/emagged //emag_act removes access requirements

/obj/item/clothing/accessory/badge/holo/NT
	name = "\improper NT holobadge"
	desc = "This glowing red badge marks the holder as a member of NanoTrasen corporate security."
	color = "#b7310b" //brighter COLOR_NT_RED
	badge_string = "NanoTrasen Security"
	badge_access = access_research

/obj/item/clothing/accessory/badge/holo/cord
	icon_state = "holobadge-cord"
	item_state = "holobadge-cord"
	slot_flags = SLOT_MASK | SLOT_TIE
/obj/item/clothing/accessory/badge/holo/NT/cord
	icon_state = "holobadge-cord"
	item_state = "holobadge-cord"
	slot_flags = SLOT_MASK | SLOT_TIE

/obj/item/clothing/accessory/badge/holo/attack_self(mob/user)
	if(!stored_name)
		to_chat(user, "Waving around a holobadge before swiping an ID would be pretty pointless.")
		return
	..()

/obj/item/clothing/accessory/badge/holo/emag_act(remaining_charges, mob/user)
	if (emagged)
		to_chat(user, SPAN("danger", "\The [src] is already cracked."))
		return
	else
		emagged = 1
		to_chat(user, SPAN("danger", "You crack the holobadge security checks."))
		return 1

/obj/item/clothing/accessory/badge/holo/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/card/id) || istype(O, /obj/item/device/pda))

		var/obj/item/card/id/id_card = null

		if(istype(O, /obj/item/card/id))
			id_card = O
		else
			var/obj/item/device/pda/pda = O
			id_card = pda.id

		if(!id_card)
			return

		if((badge_access in id_card.access) || emagged)
			to_chat(user, "You imprint your ID details onto the badge.")
			set_name(user.real_name)
		else
			to_chat(user, "[src] rejects your ID, and flashes 'Insufficient access!'")
		return
	..()

/obj/item/storage/box/holobadge
	name = "holobadge box"
	desc = "A box containing security holobadges."
	startswith = list(/obj/item/clothing/accessory/badge/holo = 4,
					  /obj/item/clothing/accessory/badge/holo/cord = 2)

/obj/item/storage/box/holobadgeNT
	name = "\improper NT holobadge box"
	desc = "A box containing NanoTrasen security holobadges."
	startswith = list(/obj/item/clothing/accessory/badge/holo/NT = 4,
					  /obj/item/clothing/accessory/badge/holo/NT/cord = 2)

/obj/item/clothing/accessory/badge/old
	name = "faded badge"
	desc = "A faded badge, backed with leather. Looks crummy."
	icon_state = "badge_round"
	badge_string = "Unknown"

/obj/item/clothing/accessory/badge/defenseintel
	name = "\improper DIA investigator's badge"
	desc = "A leather-backed silver badge bearing the crest of the Defense Intelligence Agency."
	icon_state = "diabadge"
	badge_string = "Defense Intelligence Agency"

/obj/item/clothing/accessory/badge/interstellarintel
	name = "\improper OII agent's badge"
	desc = "A synthleather holographic badge bearing the crest of the Office of Interstellar Intelligence."
	icon_state = "intelbadge"
	badge_string = "Office of Interstellar Intelligence"

/obj/item/clothing/accessory/badge/nanotrasen
	name = "\improper NanoTrasen badge"
	desc = "A leather-backed plastic badge with a variety of information printed on it. Belongs to a NanoTrasen corporate executive."
	icon_state = "ntbadge"
	badge_string = "NanoTrasen Corporate"

/obj/item/clothing/accessory/badge/marshal
	name = "colonial marshal's badge"
	desc = "A leather-backed gold badge displaying the crest of the Colonial Marshals."
	icon_state = "marshalbadge"
	slot_flags = SLOT_BELT | SLOT_TIE
	slot = ACCESSORY_SLOT_INSIGNIA
	badge_string = "Colonial Marshal Bureau"

/obj/item/clothing/accessory/badge/press
	name = "press badge"
	desc = "A leather-backed plastic badge displaying that the owner is certified press personnel."
	icon_state = "pressbadge"
	badge_string = "Journalist"

/obj/item/clothing/accessory/badge/military_dogtag
	name = "military dog tag"
	desc = "A standard-issue metal dog tag engraved with the wearer's identification details. \
	        Used by military personnel for identification in case of injury or death, or as a memento of service."
	icon_state = "military_dogtag"
	slot_flags = SLOT_TIE
	var/blood_type
	var/religion

/obj/item/clothing/accessory/badge/military_dogtag/_examine_text(mob/user)
	var/text = ..()
	if(stored_name && blood_type && religion)
		text += "\nName: [stored_name], Blood Type: [blood_type], Religion: [religion]"
	return text

/obj/item/clothing/accessory/badge/military_dogtag/attack_self(mob/user)
	var/info
	if(stored_name && blood_type && religion)
		info = "Name: [stored_name], Blood Type: [blood_type], Religion: [religion]"
	else
		info = "As you examine the dog tag closely, you notice that some of the crucial details are worn \
		        away, making them difficult to make out. The metal is scratched and tarnished, \
		        obscuring the information that once identified its owner."
	to_chat(user, "You inspect \the [src].\n[info]")
