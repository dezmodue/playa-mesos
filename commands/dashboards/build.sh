#!/usr/bin/env bash

COOKIE_JAR=$(mktemp)
curl -H 'Content-Type: application/json;charset=UTF-8' \
    --data-binary '{"user":"admin","email":"","password":"admin"}' \
    --cookie-jar "$COOKIE_JAR" \
    'http://localhost:3000/login' > /dev/null 2>&1

curl -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/datasources --data-binary @/vagrant/commands/dashboards/grafana_datasources.json -H "Content-Type: application/json"

# TODO: This doesn't work:
curl -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/dashboards/db --data-binary @/vagrant/commands/dashboards/grafana_cadvisor.json -H "Content-Type: application/json"
curl -XPOST -i --cookie "$COOKIE_JAR" http://localhost:3000/api/dashboards/db --data-binary @/vagrant/commands/dashboards/grafana_prometheus.json -H "Content-Type: application/json"
