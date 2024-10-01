// setup_discord_verification is an idempotent function that fills in connected_accounts["discord"]
// from the database. If discord account is already recorded in the client, this function is a no-op.
// If no connected account is found in the database and give_verb is true, client will be granted a Discord Verification verb.
/client/proc/setup_discord_verification(give_verb=TRUE)
	if(connected_accounts && connected_accounts["discord"])
		return
	if(!establish_db_connection())
		return
	var/DBQuery/query = sql_query("SELECT discord_user_id FROM player_discord WHERE ckey = $ckey", dbcon, list(ckey=src.ckey))
	if(!query)
		return
	if(!query.NextRow())
		if(give_verb)
			src.verbs |= /client/proc/discord_verification
		return
	var/results = query.GetRowData()
	var/discord_user_id = results["discord_user_id"]
	if(!connected_accounts)
		connected_accounts = list("discord"=discord_user_id)
		return
	connected_accounts["discord"]=discord_user_id


/client/proc/discord_verification()
	set name = "Discord Verification"
	set category = "OOC"

	var/const/verification_unavailable_msg = SPAN_DANGER("Discord verification is not available without a connected database. Please report via adminhelp if this is an error!")

	if(!establish_db_connection())
		to_chat(src, verification_unavailable_msg)
		return

	setup_discord_verification(give_verb=FALSE)
	if(connected_accounts && connected_accounts["discord"])
		to_chat(src, "Your discord account was successfully verified!")
		src.verbs -= /client/proc/discord_verification
		return

	var/code = ""

	var/DBQuery/query = sql_query("SELECT code FROM verification WHERE ckey = $ckey", dbcon, list(ckey=src.ckey))
	if(!query)
		to_chat(src, verification_unavailable_msg)
		return

	if(query.NextRow())
		var/results = query.GetRowData()
		code = results["code"]
	else
		query = sql_query("DELETE FROM verification WHERE ckey = $ckey", dbcon, list(ckey=src.ckey))
		if(!query)
			to_chat(src, verification_unavailable_msg)
			return
		for(var/i = 1 to 20)
			// uppercase-only alphanumeric
			code += pick(ascii2text(rand(65,90)),ascii2text(rand(48,57)))
		query = sql_query("INSERT INTO verification(ckey, display_key, code) VALUES ($ckey, $display_key, $code)", dbcon, list(ckey=src.ckey, display_key=src.key, code=code))
		if(!query)
			to_chat(src, verification_unavailable_msg)
			return

	if(!code)
		to_chat(src, verification_unavailable_msg)
		return
	to_chat(src, "Your one-time Discord verification code is: <b>[code]</b>")
