// Return value indicates if there were any gases.
// FALSE means there were no gases associated with object A, or A's turf if A doesn't implement gas storage
/obj/proc/analyze_gases(obj/A, mob/user, advanced)
	playsound(src.loc, 'sound/signals/processing21.ogg', 50)
	user.visible_message(SPAN("notice", "\The [user] has used \an [src] on \the [A]."))
	A.add_fingerprint(user)

	var/air_contents = A.return_air()
	if(!air_contents)
		to_chat(user, SPAN("warning", "Your [src] flashes a red light as it fails to analyze \the [A]."))
		return FALSE

	var/list/result = atmosanalyzer_scan(A, air_contents, advanced)
	print_atmos_analysis(user, result)
	return TRUE

/proc/print_atmos_analysis(user, list/result)
	for(var/line in result)
		to_chat(user, SPAN("notice", "[line]"))

/proc/atmosanalyzer_scan(atom/target, datum/gas_mixture/mixture, advanced)
	. = list()
	. += SPAN("notice", "Results of the analysis of \the [target]:")
	if(!mixture)
		mixture = target.return_air()

	if(mixture)
		var/pressure = mixture.return_pressure()
		var/total_moles = mixture.total_moles

		if (total_moles>0)
			if(abs(pressure - ONE_ATMOSPHERE) < 10)
				. += SPAN("notice", "Pressure: [round(pressure,0.1)] kPa")
			else
				. += SPAN("warning", "Pressure: [round(pressure,0.1)] kPa")
			for(var/mix in mixture.gas)
				var/percentage = round(mixture.gas[mix]/total_moles * 100, advanced ? 0.01 : 1)
				if(!percentage)
					continue
				. += SPAN("notice", "[gas_data.name[mix]]: [percentage]%")
				if(advanced)
					var/list/traits = list()
					if(gas_data.flags[mix] & XGM_GAS_FUEL)
						traits += "can be used as combustion fuel"
					if(gas_data.flags[mix] & XGM_GAS_OXIDIZER)
						traits += "can be used as oxidizer"
					if(gas_data.flags[mix] & XGM_GAS_CONTAMINANT)
						traits += "contaminates clothing with toxic residue"
					if(gas_data.flags[mix] & XGM_GAS_FUSION_FUEL)
						traits += "can be used to fuel fusion reaction"
					. += "\t"
					. += SPAN("notice", "Specific heat: [gas_data.specific_heat[mix]] J/(mol*K), Molar mass: [gas_data.molar_mass[mix]] kg/mol.[traits.len ? "\n\tThis gas [english_list(traits)]" : ""]")
			. += SPAN("notice", "Temperature: [round(CONV_KELVIN_CELSIUS(mixture.temperature))]&deg;C / [round(mixture.temperature)]K")
			return
	. += SPAN("warning", "\The [target] has no gases!")
