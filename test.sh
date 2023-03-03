#!/bin/bash

CEFConnector_start() {
    echo "Starting Akamai CEF Connector"
    echo "Starting CEF Connector function called"
    java -Dfile.encoding=UTF-8 -Xmx2048m -Xms2048m \
            -DCEFConnector.kill.mark.dummy=CEFCONNECTOR.KILL.MARK \
            -jar CEFConnector-1.7.5.jar >> /tmp/cefconnector.log 2>&1 &
    echo "Akamai CEF Connector started"
    echo "CEF Connector started successfully"

}

CEFConnector_stop() {
    echo "Stopping Akamai CEF Connector"
    echo "Stopping CEF Connector function called"
    [ -z "$PID" ] && { echo "Akamai CEF Connector is not running"; exit 1; }
    echo "Stopping Akamai CEF Connector, pid: $PID..."
    kill -9 $PID 1>/dev/null 2>/dev/null && { echo "Akamai CEF Connector killed"; } || { echo "Could not kill Akamai CEF Connector"; }
    echo "CEF Connector stopped successfully"
}

CEFConnector_pid() {
    echo "Getting PID of Akamai CEF Connector"
    echo "Getting PID function called"
    PID=`ps ax | grep -e"CEFCONNECTOR.KILL.MARK" | grep -v "grep" | awk '{printf(substr($0,1,6))}'`
    [ -z "$PID" ] && return 1;
    echo "PID found: $PID"
    return 0;
}
CEFConnector_reset() {
    echo "Resetting Akamai CEF Connector database"
    echo "Resetting function called"
    [ -e "cefconnector.db" ] && rm "cefconnector.db"
    echo "CEF Connector database reset successfully"
}

SCRIPT_NAME=`basename $0`

echo "Running script $SCRIPT_NAME with argument $1"

case "$1" in
   start)
        CEFConnector_pid
        [ -z "$PID" ] || { echo "Akamai CEF Connector is already running, pid: $PID"; exit 1; }
        CEFConnector_start
        sleep 1
        CEFConnector_pid
        [ -z "$PID" ] && { echo "Akamai CEF Connector is not running"; exit 1; }
        echo "Akamai CEF Connector is running, pid: $PID"
        exit $?
    ;;

    stop)
        CEFConnector_pid
        CEFConnector_stop
        exit $?
    ;;
    
    status)
        CEFConnector_pid
        [ -z "$PID" ] && { echo "Akamai CEF Connector is not running"; exit 1; }
        echo "Akamai CEF Connector is running, pid: $PID"
    ;;

    resetdb)
        CEFConnector_pid
        [ -z "$PID" ] || { echo "Akamai CEF Connector is running, pid: $PID"; echo "Please stop the connector before resetting the db"; exit 1; }
        CEFConnector_reset
        echo "Akamai CEF Connector db has been reset"
    ;;
    *)
        echo "Usage: $SCRIPT_NAME { start | stop | status | resetdb }"
        exit 1;;
esac

