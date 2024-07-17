/datum/configuration_section/mapping
	name = "mapping"

	var/preferred_engine = MAP_ENG_SINGULARITY
	var/preferred_biodome = MAP_BIO_FOREST
	var/preferred_bar = MAP_BAR_CLASSIC

/datum/configuration_section/mapping/load_data(list/data)
	CONFIG_LOAD_STR(preferred_engine,  data["preferred_engine"])
	CONFIG_LOAD_STR(preferred_biodome, data["preferred_biodome"])
	CONFIG_LOAD_STR(preferred_bar, 	data["preferred_bar"])

	if(!(preferred_engine in list(MAP_ENG_RANDOM, MAP_ENG_SINGULARITY, MAP_ENG_MATTER)))
		preferred_engine = MAP_ENG_SINGULARITY
	if(!(preferred_biodome in list(MAP_BIO_RANDOM, MAP_BIO_FOREST, MAP_BIO_WINTER, MAP_BIO_BEACH, MAP_BIO_CONCERT)))
		preferred_biodome = MAP_BIO_FOREST
	if(!(preferred_bar in list(MAP_BAR_RANDOM, MAP_BAR_CLASSIC, MAP_BAR_MODERN)))
		preferred_bar = MAP_BAR_CLASSIC
