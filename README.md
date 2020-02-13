# AngelPublicCode
Free CommandHelper scripts for Spigot Minecraft servers.

## Structure
This is going to be structured like a Minecraft server root directory, so the majority of the code will be found at plugins/CommandHelper/LocalPackages which is where you should copy your scripts. I'll list the scripts here along with documentation including what the script does, what extensions, plugins, or other scripts are required for it to work, and links to those resources.

## Contributors
Please follow the above format and make sure to document your additions here, furthermore try to comment your code as much as possible to help admins adapting your scripts and for the sake of transparency!

## Scripts/LocalPackages
### start.sh start.bat
This is an example startup script for your Spigot server. Use the sh file for linux, bat file for windows. In order for /restart to successfully start your server up, you need to configure spigot.yml to point to this script.

`settings:
  restart-on-crash: true
  restart-script: ./start.sh`

Linux users: Make sure you make the script executable before use. `chmod +x start.sh` From here you can run the script by running `./start.sh` and /restart should shut down the server and immediately run this script again.

Windows users: Just double click the bat file and it should run!

Source: https://www.spigotmc.org/wiki/spigot-installation/