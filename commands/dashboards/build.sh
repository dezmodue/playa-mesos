#!/usr/bin/env bash
IP=`ip addr show eth1 | grep inet\  | awk '{print $2}' | cut -d/ -f1`
echo "Logging in to grafana"
COOKIE_JAR=$(mktemp)
sleep 5
result=`curl -s -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary '{"user":"admin","email":"","password":"admin"}' \
    --cookie-jar "$COOKIE_JAR" \
    'http://localhost:3000/login' > /dev/null 2>&1`
echo $result

echo "Adding the datasource prometheus"
sleep 3
result=`curl -s -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/datasources --data-binary @/vagrant/commands/dashboards/datasources.json -H "Content-Type: application/json"`
echo $result
if [ $? -ne 0 ];then
  echo "Failed to update data sources"
fi

for i in /vagrant/commands/dashboards/grafana*; do
  echo "Adding dashboard $i"
  echo '{"overwrite": false, "dashboard":' > /tmp/dashie.json
  cat $i | jq '.id = null' >> /tmp/dashie.json
  echo '}' >> /tmp/dashie.json
  result=`curl -s -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/dashboards/db --data-binary @/tmp/dashie.json -H "Content-Type: application/json"`
  echo $result
  if [ $? -ne 0 ];then
    echo "Failed to add dashboard $i"
  fi
done

echo
echo "***********************************"
echo "***********************************"
echo
echo "Login to grafana (http://${IP}:3000) as admin/admin'"
echo
echo "Other resources:"
echo "################"
echo
echo "Marathon:       http://${IP}:8080/ui/#/apps"
echo "Mesos:          http://${IP}:5050/#/"
echo "CG Mesos-UI:    http://${IP}:5000/#/"
echo "Prometheus:     http://${IP}:9090/graph"
echo "Alert manager:  http://${IP}:9093/#/alerts"
echo "Cadvisor:       http://${IP}:8081/metrics"
echo "Node exporter:  http://${IP}:9100/metrics"
echo "Container-exp:  http://${IP}:9104/metrics" 
echo "Queue-exporter: http://${IP}:4567/metrics"
echo "Alert Webhook:  http://${IP}:4568/metrics"
echo "Grafana:        http://${IP}:3000"
echo "Queue dash:     http://${IP}:3000/dashboard/db/important-queue"
echo  
echo
echo "***********************************"
echo "To trigger queue backing up and scaling up event run 'echo ko > /tmp/queue'"
echo "To trigger queue recovery and scaling down event run 'rm /tmp/queue'"
echo
echo "Dashboard for queue metrics and autoscaling events 'Important queue'"
echo
echo "***********************************"
echo "***********************************"


