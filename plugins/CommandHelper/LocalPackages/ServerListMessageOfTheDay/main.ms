// Bind the server_ping event, meaning this code will happen every time a player who has your server saved looks at their server list.
// Arguements: 1: the event to bind, 2: options, we don't need any. 3: prefilters, we don't need any. 4: a variable for the event data to attach to.
// This code will run between when the server list ping is recieved by the server and when the server responds, so we can replace the data that the server responds with on a case by case basis!
bind('server_ping',null,null,@e){
    // @e is a variable associative_array which contains all the data associated with the event.
    // Check out https://methodscript.com/docs/3.3.4/Event_API.html to see what data is available with any event.

    // Here we read the file motds.yml which contains a yml formatted list of string values which will populate our server list motd.
    // yml_decode changes the data from one long yml formatted string to an array of strings within CommandHelper.
    @motds = yml_decode(read('motds.yml'));

    // Here we get a random entry from our motds array. array_rand() reduces the list to one random value, then [0] pulls the first value in the resulting list.
    // [0] is the first value because arrays start at zero. If there were two items, the second would be at [1].
    @motd = array_rand(@motds,1,false)[0];

    // get_server_info() returns an array of data. We want the server name as defined in server.properties which is the first value in that array.
    // The whole list is here: https://methodscript.com/docs/3.3.4/API/functions/get_server_info.html
    @server_name = get_server_info()[0];

    // This replaces any instance of %server% inside the string with the server name we got above. The results of replace() get assigned back to @motd, overwriting it.
    @motd = replace(@motd,'%server%',@server_name);

    // This replaces any '&a' type color codes with coded colors that Minecraft will understand and display in most instances.
    @motd = colorize(@motd);

    // This alters the event data, replacing the motd which was going to be sent to the player with our own.
    modify_event('motd',@motd);

}