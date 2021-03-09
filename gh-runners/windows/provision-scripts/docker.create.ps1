$ErrorActionPreference = "Stop"

echo "> Installing Docker..."
choco install docker-desktop --version=3.1.0 -y

echo "> Restarting..."
shutdown.exe /r /t 5
