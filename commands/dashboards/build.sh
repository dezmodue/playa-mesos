#!/usr/bin/env bash
IP=`ip addr show eth1 | grep inet\  | awk '{print $2}' | cut -d/ -f1`
echo "Logging in to grafana"
COOKIE_JAR=$(mktemp)
sleep 5
result=`curl -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary '{"user":"admin","email":"","password":"admin"}' \
    --cookie-jar "$COOKIE_JAR" \
    'http://localhost:3000/login' > /dev/null 2>&1`

echo "Adding the datasource prometheus"
sleep 3
result=`curl -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/datasources --data-binary @/vagrant/commands/dashboards/datasources.json -H "Content-Type: application/json"`
if [ $? -ne 0 ];then
  echo "Failed to update data sources"
fi

for i in /vagrant/commands/dashboards/grafana*; do
  result=`curl -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/dashboards/db --data-binary @"$i" -H "Content-Type: application/json"`
  if [ $? -ne 0 ];then
    echo "Failed to add dashboard $i"
  fi
done

echo
echo "***********************************"
echo "***********************************"
echo
echo "Login to grafana (http://${IP}:3000) as admin/admin and import the dashboards in 'commands/dashboards/*.json'"
echo
echo "***********************************"
echo "***********************************"


