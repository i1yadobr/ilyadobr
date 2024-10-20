// TODO(rufus): disabled event (unticked from .dme), annoying and impossible to deal with if there are no medics.
//   While it makes some sense from the realism perspective, in practice the viruses just make the gameplay
//   increasingly annoying and require some routine clicking to deal with.
//   There are also no conditions to check for the presence of medical crew, which makes lowpop rounds
//   unplayable as soon as something like a sleeping virus or gib virus triggers.
//   Disabling until at least medical crew check is implemented. Ideally viruses how to be rechecked
//   and this event should be overhauled together with virology.
/datum/event/virus_outbreak_base
	id = "virus_outbreak_base"
	name = "Virus Outbreak Incoming"
	description = "An unknown virus appears at the station"

	mtth = 3 HOURS
	difficulty = 65
	fire_only_once = TRUE

	options = newlist(
		/datum/event_option {
			id = "option_minor";
			name = "Minor Virus";
			description = "A not too strong virus will appear on the station";
			weight = 70;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION_R;
			event_id = "virus_outbreak_minor";
		},
		/datum/event_option {
			id = "option_major";
			name = "Major Virus";
			description = "A fairly powerful virus will appear on the station";
			weight = 30;
			weight_ratio = EVENT_OPTION_AI_AGGRESSION;
			event_id = "virus_outbreak_major";
		}
	)

/datum/event/virus_outbreak_base/get_mtth()
	. = ..()
	. -= (SSevents.triggers.roles_count["Medical"] * (12 MINUTES))
	. = max(1 HOUR, .)

/datum/event/virus_outbreak_minor
	id = "virus_outbreak_minor"
	name = "Virus Outbreak (minor)"

	hide = TRUE
	triggered_only = TRUE

/datum/event/virus_outbreak_minor/on_fire()
	var/next_outbreak = pick(
		/datum/ictus/retrovirus,
		/datum/ictus/cold9,
		/datum/ictus/flu,
		/datum/ictus/vulnerability,
		/datum/ictus/xeno,
		/datum/ictus/musclerace,
		/datum/ictus/hisstarvation,
		/datum/ictus/space_migraine)

	new next_outbreak

/datum/event/virus_outbreak_major
	id = "virus_outbreak_major"
	name = "Virus Outbreak (major)"

	hide = TRUE
	triggered_only = TRUE

/datum/event/virus_outbreak_major/on_fire()
	var/next_outbreak = pick(
		/datum/ictus/gbs,
		/datum/ictus/fake_gbs,
		/datum/ictus/nuclear,
		/datum/ictus/fluspanish,
		/datum/ictus/emp)

	new next_outbreak
