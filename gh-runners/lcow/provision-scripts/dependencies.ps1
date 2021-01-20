$ErrorActionPreference = "Stop"

echo "> Installing chocolatey..."
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

echo "> Installing dependencies..."
choco install docker-desktop git make cygwin -y

echo "> Configuring git..."
& "C:\Program Files\Git\cmd\git.exe" config --global core.autocrlf false

echo "> Adding cygwin binaries to PATH..."
[Environment]::SetEnvironmentVariable("PATH", "C:\tools\cygwin\bin;$ENV:PATH")

echo "> Done!"