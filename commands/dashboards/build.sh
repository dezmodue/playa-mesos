#!/usr/bin/env bash
echo "Logging in to grafana"
COOKIE_JAR=$(mktemp)
sleep 5
result=`curl -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary '{"user":"admin","email":"","password":"admin"}' \
    --cookie-jar "$COOKIE_JAR" \
    'http://localhost:3000/login' > /dev/null 2>&1`

echo "Adding the datasource prometheus"
sleep 3
result=`curl -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/datasources --data-binary @/vagrant/commands/dashboards/grafana_datasources.json -H "Content-Type: application/json"`
if [ $? -ne 0 ];then
  echo "Failed to update data sources"
fi


# TODO: This doesn't work:
#curl -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/dashboards/db --data-binary @/vagrant/commands/dashboards/grafana_cadvisor.json -H "Content-Type: application/json"
#curl -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/dashboards/db --data-binary @/vagrant/commands/dashboards/grafana_prometheus.json -H "Content-Type: application/json"
