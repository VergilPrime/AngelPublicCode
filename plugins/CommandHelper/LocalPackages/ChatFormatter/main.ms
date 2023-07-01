# Make sure you have Vault and PlaceholderAPI installed in your plugins folder.
# Make sure to grab CHVault and CHPlaceholderAPI from https://letsbuild.net/jenkins/ and put it in plugins/CommandHelper/extensions.
# Run '/papi ecloud download Gradient' to get gradients working with PlaceholderAPI


bind("async_player_chat",null,null,@e){
    // Here async_player_chat is the event name.
    // The first null is the event options, we don't need to mess with those.
    // The second null is the prefilter. We're handling all chat so we'll leave it null.
    // The @e is a variable with all kinds of event data. We'll be using that a lot.
    // @e consists of "message", "recipients", and "format".
    // "player" should be in there too but I don't see it in the documentation, so if that throws an error, just use player().
    // We can modify the format to change how the message looks.

    @player = @e["player"];
    // @player = player();

    // Here we get the prefix and suffix from Vault as defined in the permissions plugin.
    // If we're using different formats in different worlds, we should specify the player's world with pworld() and pass in the player @player.
    // @prefix = vault_user_prefix(pworld(@player),@player);
    // @suffix = vault_user_suffix(pworld(@player),@player);
    // Otherwise we'll specify the main world.
    @prefix = vault_user_prefix("world",@player);
    @suffix = vault_user_suffix("world",@player);
    
    // Here we stick together the prefix, player name, and suffix and then PlaceholderAPI applies color codes and gradients.
    @formattedname = set_placeholders(@player, @prefix.@player.@suffix);

    // Using the ecloud PlaceholderAPI extension, we can use PlaceholderAPI placeholders around the name in the prefix and suffix.
    // https://api.extendedclip.com/expansions/gradient/
    // So for example we might set the prefix to '%gradient_message_{000000}_{00ff00}_' and the suffix to '%' so the full string becomes '%gradient_message_{000000}_{00ff00}_playername%'

    // Lastly, we modify the event to use our new format.
    modify_event("format",@formattedname.color(7).': %2$s');
}
