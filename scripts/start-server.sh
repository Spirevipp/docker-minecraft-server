#!/bin/bash
echo "---Checking if specified RUNTIME_DIR exists---"
if [ ! -f "${RUNTIME_DIR}/bin/java" ]; then
	echo "---Runtime not found, add a valid path mapping such that RUNTIME_DIR points to a valid java version---"
	sleep infinity
else
	echo "---Found the runtime---"
	echo "RUNTIME_DIR = ${RUNTIME_DIR}"
	$RUNTIME_DIR/bin/java --version
fi

echo "---Checking for Minecraft Server executable ---"
if [ -n "${CUSTOM_LAUNCH_SCRIPT}" ]; then
	echo "---Detected CUSTOM_LAUNCH_SCRIPT: ${CUSTOM_LAUNCH_SCRIPT} skipping Check for Minecraft Server executable!---"
elif [ -n "${JVM_CUSTOM_COMMAND}" ]; then
	echo "---Detected JVM_CUSTOM_COMMAND: ${JVM_CUSTOM_COMMAND} skipping Check for Minecraft Server executable!---"
else
	echo "---Please make sure that '${JAR_NAME}.jar' is in the main directory!---"
	if [ ! -f $SERVER_DIR/${JAR_NAME}.jar ]; then
		echo "---Can't find '${JAR_NAME}.jar' please make sure that it's in the main directory, putting server into sleep mode!---"
		sleep infinity
	fi
	echo "---Executable '${JAR_NAME}.jar' in main directory found, continuing!---"
fi

echo "---Preparing Server---"
if [ ! -f ~/.screenrc ]; then
	echo "defscrollback 30000
bindkey \"^C\" echo 'Blocked. Please use to command \"stop\" to shutdown the server or close this window to exit the terminal.'" >~/.screenrc
fi
echo "---Checking for 'server.properties'---"
if [ ! -f ${SERVER_DIR}/server.properties ]; then
	cp /tmp/server.properties ${SERVER_DIR}/
else
	echo "---'server.properties' found..."
fi
chmod -R ${DATA_PERM} ${DATA_DIR}

echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
screen -wipe 2 &>/dev/null

if [ "${ACCEPT_EULA}" == "true" ]; then
	if [ ! -f "$SERVER_DIR/eula.txt" ]; then
		echo "---Accepting EULA---"
		echo "eula=true" >"$SERVER_DIR/eula.txt"
	elif grep -rq 'eula=false' ${SERVER_DIR}/eula.txt; then
		sed -i '/eula=false/c\eula=true' ${SERVER_DIR}/eula.txt
		echo "---EULA accepted---"
	fi
elif [ "${ACCEPT_EULA}" == "false" ]; then
	if [ ! -f "$SERVER_DIR/eula.txt" ]; then
		echo "eula=false" >"$SERVER_DIR/eula.txt"
	elif grep -rq 'eula=true' ${SERVER_DIR}/eula.txt; then
		sed -i '/eula=true/c\eula=false' ${SERVER_DIR}/eula.txt
	fi
	echo
	echo "-------------------------------------------------------"
	echo "------EULA not accepted, you must accept the EULA------"
	echo "---to start the Server, putting server in sleep mode---"
	echo "-------------------------------------------------------"
	sleep infinity
else
	echo "---Something went wrong, please check EULA variable---"
fi

echo "---Starting Server---"
cd ${SERVER_DIR}
if [ -n "${CUSTOM_LAUNCH_SCRIPT}" ]; then
	echo "---Starting server using custom launch script---"
	echo "CUSTOM_LAUNCH_SCRIPT = ${CUSTOM_LAUNCH_SCRIPT}"
	screen -S Minecraft -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/${CUSTOM_LAUNCH_SCRIPT}
elif [ -n "${JVM_CUSTOM_COMMAND}" ]; then
	echo "---Starting server using custom JVM command---"
	echo "JVM_CUSTOM_COMMAND = ${JVM_CUSTOM_COMMAND}"
	screen -S Minecraft -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${RUNTIME_DIR}/bin/java ${JVM_CUSTOM_COMMAND}
else
	echo "---Starting server using standard launch method---"
	echo "EXTRA_JVM_PARAMS = ${EXTRA_JVM_PARAMS}"
	echo "XMX_SIZE = ${XMX_SIZE}"
	echo "XMS_SIZE = ${XMS_SIZE}"
	echo "JAR_NAME = ${JAR_NAME}"
	echo "GAME_PARAMS = ${GAME_PARAMS}"
	screen -S Minecraft -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${RUNTIME_DIR}/bin/java ${EXTRA_JVM_PARAMS} -Xmx${XMX_SIZE}M -Xms${XMS_SIZE}M -jar ${SERVER_DIR}/${JAR_NAME}.jar nogui ${GAME_PARAMS}
fi
sleep 2
echo "---Waiting for logs, please stand by...---"
if [ "${ENABLE_WEBCONSOLE}" == "true" ]; then
	/opt/scripts/start-gotty.sh 2>/dev/null &
fi
sleep 30
if [ -f ${SERVER_DIR}/logs/latest.log ]; then
	screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
	tail -F ${SERVER_DIR}/logs/latest.log
else
	screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
	tail -f ${SERVER_DIR}/masterLog.0
fi
