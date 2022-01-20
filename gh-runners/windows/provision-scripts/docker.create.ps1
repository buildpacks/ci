$ErrorActionPreference = "Stop"

echo "> Installing Docker..."
choco install docker-desktop --version=4.4.3 -y

echo "> Restarting..."
shutdown.exe /r /t 5
