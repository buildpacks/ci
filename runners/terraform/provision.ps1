# Install chocolatey (https://chocolatey.org/install)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
choco install docker-desktop git make cygwin -y

# Set up Github Actions Runner Process
## IMPORTANT:
## Each runner is specific to only one git repository. To reuse the same VM, you must run a service per repo.
## Convention is to install each runner in a directory named after the repo. eg. `\actions-runners\pack\`
Set-Variable -Name REPO -Value pack
mkdir \actions-runners\$REPO
Push-Location \actions-runners\$REPO
  curl.exe -Lo actions-runner-win-x64-2.168.0.zip https://github.com/actions/runner/releases/download/v2.168.0/actions-runner-win-x64-2.168.0.zip
  Expand-Archive actions-runner-win-x64-2.168.0.zip
Pop-Location

# Disable automatic CRLF
& "C:\Program Files\Git\cmd\git.exe" config --global core.autocrlf false

# Add cygwin binaries path
[Environment]::SetEnvironmentVariable("PATH", "$ENV:PATH;C:\tools\cygwin\bin", "USER")