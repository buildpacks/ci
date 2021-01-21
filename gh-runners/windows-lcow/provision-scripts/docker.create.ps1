$ErrorActionPreference = "Stop"

echo "> Installing Docker..."
choco install docker-desktop -y

echo "> Configuring Docker..."
# $DAEMON_EXE="${ENV:ProgramFiles}\Docker\Docker\resources\dockerd.exe"
# Stop-Service -Name "com.docker.service"
# & sc.exe delete com.docker.service
# & $DAEMON_EXE -H npipe:////./pipe/docker_engine --service-name=com.docker.windows --register-service
# Stop-Service -Name "com.docker.windows"

echo "> Setting Engine to Linux..."
& "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchLinuxEngine

# echo "> Restarting..."
# shutdown.exe /r /t 5
# sleep 5