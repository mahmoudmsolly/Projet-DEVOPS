@echo off
title DevOps - Projet 5ERPBI1-Msolly
echo ============================================
echo   Demarrage de la chaine DevOps (WSL)
echo ============================================
echo.

wsl -d Ubuntu-24.04 -u mahmoud -- bash /home/mahmoud/Projet-DEVOPS/scripts/start-all.sh

echo.
echo Ouverture des interfaces dans le navigateur...
start "" http://localhost:8080
start "" http://localhost:4200
start "" http://localhost:9000
start "" http://localhost:3000

echo.
echo ============================================
echo   LAISSEZ CETTE FENETRE OUVERTE (reduisez-la)
echo   Fermer la fenetre = WSL peut s'arreter.
echo   Pour tout arreter : DevOps-Stop.bat
echo ============================================
wsl -d Ubuntu-24.04 -u mahmoud -- sleep infinity
