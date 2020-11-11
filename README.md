# TestScript
Script to test our plugins with ease


Start it up with ./initserver.sh

The scripts will create a
  - plugins folder with all the plugins
  - BuildTools folder
  - Server folder
 
Run it as ./initserver.sh <server-version> <plugin-type> <plugin-version> <server-ram>
  So for example, do ./initserver.sh latest BB latest 512 to startup a server with 512MB RAM with the latest spigot version and the latest version of BuildBattle.
  
The script will also automatically install LuckPerms in the plugins folder of the server.
