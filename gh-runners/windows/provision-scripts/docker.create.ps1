$ErrorActionPreference = "Stop"

echo "> Installing Docker..."
# http://disq.us/p/2j8w5a4: Docker-Desktop v 3.1.0 has a broken checksum
choco install docker-desktop --version=3.1.0 -y --ignore-checksums

echo "> Restarting..."
shutdown.exe /r /t 5

# https://github.com/docker/for-win/issues/11899#issuecomment-905413951
attrib c:\programdata\docker\panic.log -r
