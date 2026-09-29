#!/bin/bash
# Starts the whole DevOps chain in WSL: Jenkins, SonarQube, Spring+MySQL+Angular, Prometheus+Grafana
cd "$(dirname "$0")/.." || exit 1

wait_for() {  # wait_for <name> <url> <max seconds>
    printf '  %-12s' "$1"
    for _ in $(seq 1 "$3"); do
        if curl -s -o /dev/null -f "$2"; then echo "OK"; return 0; fi
        sleep 2
    done
    echo "NOT READY (still starting? check later)"
}

echo "== DNS"
if grep -q '^nameserver 8.8.8.8' /etc/resolv.conf; then echo "  OK"; else
    echo "  WARNING: /etc/resolv.conf was reset, run:"
    echo "  sudo rm -f /etc/resolv.conf && printf 'nameserver 8.8.8.8\nnameserver 1.1.1.1\n' | sudo tee /etc/resolv.conf"
fi

echo "== Services (systemd)"
for s in docker jenkins; do printf '  %-12s%s\n' "$s" "$(systemctl is-active $s)"; done

echo "== Containers"
docker compose -f sonarqube/docker-compose.yml up -d 2>&1 | grep -E 'Started|Running|Error' | sed 's/^/  /'
docker compose up -d --no-build 2>&1 | grep -E 'Started|Running|Healthy|Error' | sed 's/^/  /'
docker compose -f monitoring/docker-compose.yml up -d 2>&1 | grep -E 'Started|Running|Error' | sed 's/^/  /'

echo "== Health checks"
wait_for Jenkins    http://localhost:8080/login 60
wait_for Spring     http://localhost:8089/actuator/health 60
wait_for Angular    http://localhost:4200 30
wait_for SonarQube  http://localhost:9000/api/system/status 90
wait_for Prometheus http://localhost:9090/-/ready 30
wait_for Grafana    http://localhost:3000/api/health 30

cat <<'EOF'

  Jenkins     http://localhost:8080
  Angular     http://localhost:4200
  Spring API  http://localhost:8089
  Adminer     http://localhost:8082   (server: mysqldb, user: root)
  SonarQube   http://localhost:9000
  Prometheus  http://localhost:9090
  Grafana     http://localhost:3000
EOF
