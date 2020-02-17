// This binds code to the 'player_spawn' event.
bind('player_spawn',null,null,@e){
    // Just for legibility, lets get the player out of @e the event data and assign it to @player.
    @player = @e['player'];
    // This permission will keep players from being sent to the nether on death. Note that perm nodes are not case sensitive.
    // ! makes this opposites day so this reads as:
    // if NOT @player has permission 'RandomRespawnWorld.Safety', do the following
    if(!has_permission(@player,'RandomRespawnWorld.Safety')){
        // Generate a random number between 0 and 1. Rand takes two args, the minimum and max, and spits out a number between min and max - 1
        // "Returns a random number from 0 to max, or min to max, depending on usage. Max is exclusive."
        @coin = rand(0,2);
        // @coin now is either 0 or 1.
        // Integers when used in place of a boolean return true unless the value is zero, so we can use this in an if statement. 1 will be true, 0 will be false.
        if(@coin){
            // Now we set the respawn location in the event to whatever the spawn of the Nether is.
            // Change the value 'world_nether' to the code name of the world you want such as 'world_the_end' to change the world the player ends up in.
            modify_event('location',get_spawn('world_nether'));
        }
    }
}