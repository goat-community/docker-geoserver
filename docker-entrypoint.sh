#!/bin/bash

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Templating files"

if [[ -z ${GEOSERVER_CORS_ENABLE+x} ]]; then
    export GEOSERVER_CORS_ENABLE=false
fi

confd -backend env -onetime

# Setting handlers
term_handler() {
    if [[ $pid != 0 ]]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Sending SIGTERM to geoserver PID: ${pid}"
        kill -SIGTERM "${pid}"
        wait "${pid}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Tomcat Stopped"
    fi
}

trap 'kill ${!}; term_handler' SIGTERM

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting geoserver.. "
nohup /usr/local/tomcat/bin/catalina.sh run > /tmp/tomcat.log 2>&1 &
pid="$!"


echo "[$(date '+%Y-%m-%d %H:%M:%S')] Started Geoserver with PID: ${pid} "

echo "Displaying logs: "
while true; do
    tail -f /tmp/tomcat.log & wait ${!}
done