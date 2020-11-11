#!/bin/bash

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi


if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]  || [ -z "$4" ]
then
    echo "Please provide four arguments"
    echo "$0 <spigot-release> <plugin-type> <plugin-release> <server-ram>"
    echo "Spigot-release:"
    echo "	- latest "
    echo "	- 1.12.2 "
    echo "	- ..."
    echo "plugin-type: "
    echo "	- MM"
    echo "	- VD"
    echo "	- BB"
    echo "plugin-release:"
    echo "	- latest"
    echo "	- beta"
    echo "	- stable"
    echo "server-ram:"
    echo "	- 512"
    echo "	- 256"
    exit
fi

version="$1" #Minecraft version
plugintype="$2" #Plugin type (MM, VD, BB)
pluginversion="$3" #latest, beta, stable
downloadlink="https://api.plugily.xyz/download/fetch.php" 
luckpermsdownloadlink=$(curl -s "https://metadata.luckperms.net/data/downloads" | ruby -rjson -e 'data = JSON.parse(STDIN.read); puts data["downloads"]["bukkit"]')
serverram="$4"

if  [ -x "$(ruby --help)" ];
then
    echo "Installing Ruby and screens"
    sudo apt-get update
    #Install ruby to acces Json data from website to get the latest LuckyPerms
    sudo apt-get install ruby -y
    #Install screens while we're at it
    sudo apt-get install screen
fi


if [[ ! -d ./BuildTools ]]
then
    mkdir ./BuildTools
fi
cd BuildTools

if [ -d ./spigot-*.jar ]
then
  rm ./spigot-.jar
fi

curl -z BuildTools.jar -o BuildTools.jar https://hub.spigotmc.org/jenkins/job/BuildTools/lastSuccessfulBuild/artifact/target/BuildTools.jar
chmod +x BuildTools.jar
java -jar BuildTools.jar --rev $version

cd ..
if [[ ! -d ./Plugins ]];
then
   echo "MAKING PLUGINS"	
   mkdir ./Plugins
   cd Plugins
   mkdir MurderMystery
   mkdir VillageDefense
   mkdir BuildBattle
   mkdir LuckPerms
   cd ..
fi

cd ./Plugins
cd ./LuckPerms
if [ -d ./LuckPerms.jar ];
then
   rm ./LuckPerms.jar
fi
wget "$luckpermsdownloadlink" -O LuckPerms.jar

cd ..
if [ $plugintype = "MM" ] || [ $plugintype = "mm" ];
then
   cd ./MurderMystery
   if [ -d ./MurderMystery$3.jar ]
   then
       rm ./MurderMystery$3.jar
   fi
    wget "$downloadlink?type=MurderMystery&version=$3" -O MurderMystery$3.jar -P ./Plugins/MurderMystery
fi
if [ $plugintype = "VD" ] || [ $plugintype = "vd" ];
then
   cd ./VillageDefense
   if [ -d ./VillageDefense$3.jar ]
   then
       rm ./VillageDefense$3.jar
   fi
    wget "$downloadlink?type=VillageDefense&version=$3" -O VillageDefense$3.jar
fi


if [ $plugintype = "BB" ] || [ $plugintype = "bb" ];
then
   cd ./BuildBattle
   if [ -d ./BuildBattle$3.jar ]
   then
       rm ./BuildBattle$3.jar
   fi
    wget "$downloadlink?type=BuildBattle&version=$3" -O BuildBattle$3.jar
fi
cd ..
cd ..
#Files are now all downloaded, server building starts here

if [[ ! -d ./Servers ]]
then
    mkdir ./Servers
fi
cd ./Servers

if [[ ! -d ./$version$serverram ]]
then
    mkdir ./$version$serverram
    mkdir ./$version$serverram/plugins
    cd ..
    cp -v ./BuildTools/spigot-*.jar ./Servers/$version$serverram
    if [ ! -e ./Servers/$version$serverram/start_server.sh ]; then
  	echo "java -Xms${serverram}M -Xmx${serverram}M -jar spigot.jar">> ./Servers/$version$serverram/start_server.sh
    fi
    if [ ! -e ./Servers/$version$serverram/eula.txt ];then
	    echo "eula=true" >> ./Servers/$version$serverram/eula.txt
    fi
    cp -v ./Plugins/LuckPerms/LuckPerms.jar ./Servers/$version$serverram/plugins
    cd ./Servers/$version$serverram
    mv ./spigot-*.jar ./spigot.jar
    chmod +x ./start_server.sh
    cd ..
    
fi

cd ./$version$serverram/plugins
rm -f ./BuildBattle*.jar
rm -f ./MurderMystery*.jar
rm -f ./VillageDefense*.jar

cd ..
cd ..
cd ..

cp -u ./Plugins/LuckPerms/LuckPerms.jar ./Servers/$version$serverram/plugins

if [ $plugintype = "MM" ] || [ $plugintype = "mm" ]
then
    cp -u ./Plugins/MurderMystery/MurderMystery$pluginversion.jar ./Servers/$version$serverram/plugins
fi
if [ $plugintype = "VD" ] || [ $plugintype = "vd" ]
then
   cp -u ./Plugins/VillageDefense/VillageDefense$pluginversion.jar ./Servers/$version$serverram/plugins
fi
if [ $plugintype = "BB" ] || [ $plugintype = "bb" ] 
then
  cp -u ./Plugins/BuildBattle/BuildBattle$pluginversion.jar ./Servers/$version$serverram/plugins
fi


sudo screen -S "minecraft$version$serverram" ./Servers/$version$serverram/start_server.sh
