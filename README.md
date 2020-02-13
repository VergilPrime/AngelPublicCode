# AngelPublicCode
Free CommandHelper scripts for Spigot Minecraft servers.

## Structure
This is going to be structured like a Minecraft server root directory, so the majority of the code will be found at plugins/CommandHelper/LocalPackages which is where you should copy your scripts. I'll list the scripts here along with documentation including what the script does, what extensions, plugins, or other scripts are required for it to work, and links to those resources.

## Contributors
Please follow the above format and make sure to document your additions here, furthermore try to comment your code as much as possible to help admins adapting your scripts and for the sake of transparency!

## CommandHelper
CommandHelper is a plugin originally by Sk89q and now maintained by a collective of talented programmers which allows you to register commands, attach code to events, send plugin messages across bungeecord and more. CommandHelper uses [MethodScript](https://methodscript.com/) and has a massive [API](https://methodscript.com/docs/3.3.4/API.html), [Event API](https://methodscript.com/docs/3.3.4/Event_API.html), and several [extensions](https://letsbuild.net/jenkins/) to extend it's functionality and pair with other plugins. Grab the latest version [here](https://builds.enginehub.org/). By default CommandHelper generates aliases.msa, main.ms and auto_include.ms in it's plugin directory. You may wish to empty out main.ms and aliases.ms, saving the empty files before you begin. Use `/reloadaliases` to reload all scripts. Unlike `/reload` which is very not recommended, this only touches CommandHelper's scripts and is safe.

## Scripts/LocalPackages
### start.sh start.bat
This is an example startup script for your Spigot server. Use the sh file for linux, bat file for windows. In order for /restart to successfully start your server up, you need to configure spigot.yml to point to this script.

```
settings:
  restart-on-crash: true
  restart-script: ./start.sh
```

Linux users: Make sure you make the script executable before use. `chmod +x start.sh` From here you can run the script by running `./start.sh` and /restart should shut down the server and immediately run this script again.

Windows users: Just double click the bat file and it should run!

Everyone: If you need more memory, you change the arguments `-Xms1G -Xmx1G`. Here are some examples of valid replacements.
- Two Gigabytes: `-Xms2G -Xmx2G`
- 512 Megabytes: `-Xms512M -Xmx512M`

-Xms is the starting allocated pool of memory that your Java instance will reserve, where -Xmx is the maximum it will use. If you have out of memory errors, increase the Xmx value.

Source: https://www.spigotmc.org/wiki/spigot-installation/

### ServerListMessageOfTheDay (MOTD)
This is a two part script including a methodscript (.md) and yml file.
This selects a string from the yml file at random, does some magic, and returns the new MOTD to players who view your server in their list.
By default this uses the server name from your server.properties file, so make sure that's configured or edit motds.yml and replace %server% with your server's name.
Simply drop the entire ServerListMessageOfTheDay folder into /plugins/CommandHelper/LocalPackages and then run /reloadaliases in game or console to load the scripts. You do not have to /reloadaliases after editing the yml file as it is read when the ping occures, not at startup.