// We may wish to manually track ban expiration times if no tempban command exists, so we'll create a list of players (uuids) and timestamps so we know when to unban.
// First see if the list has already been created in persistant (hard drive) storage.
if(has_value('DeathBans.Expiry')){
    // If it exists, we should load this list into memory using export().
    export('DeathBans.Expiry',get_value('DeathBans.Expiry'));
}else{
    // If not, we can create an empty list and export() it.
    export('DeathBans.Expiry',associative_array());
}

// Next, lets set a task to run every five minutes or so to unban players on the list who are past their expiration.
// set interval runs a code block called a closure every specified amount of time.
// For legibility we're putting a small math equasion in instead of just an integer, but this will resolve to an integer.
// 1000 ms in a second times 60 seconds in a minute times 5 minutes.
set_interval(1000 * 60 * 5, closure(){
    // Set a save flag, this stays false unless the list changes, then we will know we need to save to the hard drive after our foreach ends.
    @save = false;
    // For every key:value pair in the exported 'DeathBans.Expiry' address in memory
    foreach(@uuid:@expiry in import('DeathBans.Expiry')){
        // If the expiry time is previous to the current time, as times are just integers they can be compared using math operators.
        if(@expiry < time()){
            // Unban the player
            set_pbanned(@uuid,false);

            // Remove the player from the list in memory and set that save flag so we know to save.
            array_remove(import('DeathBans.Expiry'),@uuid);
            @save = true;

            // Because the array we are iterating with foreach has changed shape, but our location in the array hasn't, we need to start re-iterate at the same location in the array.
            continue(0);
        }
    }

    // If our save flag has been set to true
    if(@save){
        // Save the newly changed list to the hard drive.
        store_value('DeathBans.Expiry',import('DeathBans.Expiry'));
    }
})

// When a player dies
bind('player_death',null,null,@e){
    @player = @e['player'];
    // We don't know if the server has a tempban plugin, but we want to utilize that if it exists, so first lets see if tempban is a registered command.
    if(array_index_exists(get_commands(),'tempban')){
        // In the case that tempban exists, we should just run it on the dead player.
        // Adjust the format of the time period and message here as needed.
        runas('~console','/tempban '.@player.' 24h You died and were banned from the server for 24 hours.');
    }else{
        // Let's get the UUID of the player so they can't circumvent by changing their name.
        @uuid = puuid(@player,true);

        // In the case that tempban doesn't exist, we'll assume no banning plugin exists, so we'll use the built in ban functions and create a schedule to unban the player in 24 hours.
        set_pbanned(@uuid,true,'You died and were banned from the server for 24 hours.');

        // Add an entry in the expiry list for the player so we know when to unban them.
        // 1000 ms in a second times 60 seconds in a minute times 60 minutes in an hour times 24 hours.
        import('DeathBans.Expiry')[@uuid] = time() + 1000 * 60 * 60 * 24;

        // Save the newly changed list to the hard drive.
        store_value('DeathBans.Expiry',import('DeathBans.Expiry'));
    }

    // In case banning the player hasn't kicked them from the server for whatever reason, let's make really sure they were removed.
    // If the player is online
    if(ponline(@player)){
        // Kick them!
        pkick(@player,'You died and were banned from the server for 24 hours.')
    }
}