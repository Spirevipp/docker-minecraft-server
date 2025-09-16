# Fork
This fork removes some features of the original, mainly making java version management manual, and removing features for easier usage for me

## Changes
Mount folder `/runtime` to a java linux build, such that the `java` executable exists at `/runtime/bin/java` in the container
This `/runtime` folder can be overriden with `RUNTIME_DIR` env var

No longer uses GAME_V and RUNTIME_NAME env vars

Auto download of java has been removed

Auto download of Minecraft has been removed. It is expected that the jar file or custom launch command will handle this.
For modded servers, this is done by forge/fabric etc... Just point the launch command to correct server jar, or use the `CUSTOM_LAUNCH_SCRIPT` env var

Env var `CUSTOM_LAUNCH_SCRIPT` has been added. This should be the name of a script in the `SERVER_DIR` that will handle launching the server. The mounted runtime will be available using the mounted path, or at `$RUNTIME_DIR/bin/java`. You will likely need to edit the script to use that path for java

## Env params
**Bold** env vars are required.
*Italics* env vars are required if custom script or custom launch command arent specified

| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefile | /serverdata/serverfiles |
| RUNTIME_DIR | Folder for java runtime | /runtime |
| **JAR_NAME** | Executable jar file (Minecraft Serverfile) without the .jar extension. | server |
| GAME_PARAMS | Extra startup Parameters for server jar file | empty |
| GAME_PORT | TCP Gameport for the server | 25565 |
| *XMX_SIZE* | Enter your XMX size in MB (XMX=The maximum heap size. The performance will decrease if the max heap value is set lower than the amount of live data. It will force frequent garbage collections in order to free up space). | 1024 |
| *XMS_SIZE* | Enter your XMS size in MB (XMS=The initial and minimum heap size. It is recommended to set the minimum heap size equivalent to the maximum heap size in order to minimize the garbage collection). | 1024 |
| EXTRA_JVM_PARAMS | Extra JVM startup Parameters if needed (leave empty if not needed) | empty |
| JVM_CUSTOM_COMMAND | Overrides all startup parameters for JVM like it is required for Forge v1.18+ | empty |
| CUSTOM_LAUNCH_SCRIPT | Overrides most settings to instead use a custom supplied start script | empty |
| **ACCEPT_EULA** | Head over to: https://account.mojang.com/documents/minecraft_eula to read the EULA. (If you accept the EULA change the value to 'true' without quotes). | true |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name MinecraftBasicServer -d \
	-p 25565:25565 -p 9011:8080 \
	--env 'JAR_NAME=server' \
	--env 'GAME_PORT=25565' \
	--env 'XMX_SIZE=4096' \
	--env 'XMS_SIZE=4096' \
	--env 'ACCEPT_EULA=true' \
	--env 'UID=99' \
	--env 'GID=100' \
	--volume /mnt/user/data/java/graalvm8:/runtime \
	--volume /mnt/user/appdata/minecraftbasicserver:/serverdata/serverfiles \
	ich777/minecraftbasicserver
```

# Old readme

# Minecraft Basic Server in Docker optimized for Unraid
This is a Basic Minecraft Server, with the basic configuration it will download and install a Vanilla Minecraft Server. You can also install a FTB (FeedTheBeast), Bukkit, Spigot,... server.
If you want to copy over your favorite server executable (don't forget to set the Serverfile name to the same as you copied over without the '.jar' extension) and start the container again or simply start the server if you wait for it to completely start if you want to play Minecraft Vanilla.

UPDATE: If you set the variable GAME_V to 'latest' the container will check on every restart if there is a newer version available (if set to 'latest' the variable JAR_NAME has to be 'server').

JAVA RUNTIME: Enter your prefered Runtime 'basicjre'=jre8, 'jre11'=jre11, 'jre15'=jre15 Don't change unless you are knowing what you are doing! Please keep in mind if you change the runtime you have to delete the old runtime before!

ATTENTION: Don't forget to accept the EULA down below and don't forget to edit the 'server.properties' file the server is by default configured to be a LAN server and to be not snooped.

>**WEB CONSOLE:** You can connect to the Minecraft console by opening your browser and go to HOSTIP:9011 (eg: 192.168.1.1:9011) or click on WebUI on the Docker page within Unraid.

## Env params
| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefile | /serverdata/serverfiles |
| RUNTIME_NAME | Enter your prefered Runtime 'basicjre'=jre8, 'jre11'=jre11, 'jre15'=jre15 Don't change unless you are knowing what you are doing! Please keep in mind if you change the runtime you have to delete the old runtime before! | basicjre |
| JAR_NAME | Executable jar file (Minecraft Serverfile) withouat the .jar extension. | server |
| GAME_PARAMS | Extra startup Parameters if needed (leave empty if not needed) | empty |
| GAME_PORT | TCP Gameport for the server | 25565 |
| GAME_V | If set to 'latest' the JAR_NAME must be 'server' valid options are 'latest', 'custom' or simply leave empty | latest |
| XMX_SIZE | Enter your XMX size in MB (XMX=The maximum heap size. The performance will decrease if the max heap value is set lower than the amount of live data. It will force frequent garbage collections in order to free up space). | 1024 |
| XMS_SIZE | Enter your XMS size in MB (XMS=The initial and minimum heap size. It is recommended to set the minimum heap size equivalent to the maximum heap size in order to minimize the garbage collection). | 1024 |
| EXTRA_JVM_PARAMS | Extra JVM startup Parameters if needed (leave empty if not needed) | empty |
| JVM_CUSTOM_COMMAND | Overrides all startup parameters for JVM like it is required for Forge v1.18+ | empty |
| ACCEPT_EULA | Head over to: https://account.mojang.com/documents/minecraft_eula to read the EULA. (If you accept the EULA change the value to 'true' without quotes). | true |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

## Run example
```
docker run --name MinecraftBasicServer -d \
	-p 25565:25565 -p 9011:8080 \
	--env 'RUNTIME_NAME=basicjre' \
	--env 'JAR_NAME=server' \
	--env 'GAME_V=latest' \
	--env 'GAME_PORT=25565' \
	--env 'XMX_SIZE=1024' \
    --env 'XMS_SIZE=1024' \
    --env 'ACCEPT_EULA=true' \
	--env 'UID=99' \
	--env 'GID=100' \
	--volume /mnt/user/appdata/minecraftbasicserver:/serverdata/serverfiles \
	ich777/minecraftbasicserver
```
>**NOTE** You can also forward port the TCP port 25575 if you want to connect to the RCON console.


This Docker was mainly edited for better use with Unraid, if you don't use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/
