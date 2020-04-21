#!/bin/bash

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Ensuring Geoserver can acess data directory"
chown -R tomcat:tomcat /var/local/geoserver

export CATALINA_OPTS="-server -Djava.awt.headless=true \
	-Xms768m -Xmx1560m -XX:+UseConcMarkSweepGC -XX:NewSize=48m \
	-DGEOSERVER_DATA_DIR=/var/local/geoserver"


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
su tomcat -c "nohup /usr/local/tomcat/bin/catalina.sh run > /tmp/tomcat.log 2>&1" &
pid="$!"


echo "[$(date '+%Y-%m-%d %H:%M:%S')] Started Geoserver with PID: ${pid} "

echo "Displaying logs: "
while true; do
    tail -f /tmp/tomcat.log & wait ${!}
done
