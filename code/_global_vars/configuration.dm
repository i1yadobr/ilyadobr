// Bomb cap!
GLOBAL_VAR_INIT(max_explosion_range, 14)

var/game_version        = "ZeroOnyx"
var/game_year           = (text2num(time2text(world.realtime, "YYYY")) + 544)
var/join_motd = null

var/secret_force_mode = "secret"   // if this is anything but "secret", the secret rotation will forceably choose this mode.

var/Debug2 = 0

// NOTE(rufus): connection has been observed to close after being idle overnight, this needs reconnect mechanism
// A connection is established on world creation.
var/DBConnection/dbcon     = new() // Main Database

// For FTP requests. (i.e. downloading runtime logs.)
// However it'd be ok to use for accessing attack logs and such too, which are even laggier.
var/fileaccess_timer = 0
var/custom_event_msg = null

GLOBAL_VAR_INIT(visibility_pref, FALSE)
 // Used for admin shenanigans.
GLOBAL_VAR_INIT(random_players, 0)
GLOBAL_VAR_INIT(triai, 0)
