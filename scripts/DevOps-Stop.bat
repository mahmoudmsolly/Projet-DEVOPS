@echo off
title DevOps - Arret
echo Arret des conteneurs...
wsl -d Ubuntu-24.04 -u mahmoud -- bash -c "cd ~/Projet-DEVOPS && docker compose -f monitoring/docker-compose.yml stop; docker compose stop; docker compose -f sonarqube/docker-compose.yml stop"
echo Arret de WSL...
wsl --terminate Ubuntu-24.04
echo.
echo Tout est arrete. Les donnees (MySQL, SonarQube, Grafana, Jenkins) sont conservees.
pause
