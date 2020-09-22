#ps1

# Install/Enable SSH (for subsequent provisioning steps)
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

# Install Hyper-V for Docker; NOTE: This will restart the machine.
Install-WindowsFeature -Name Hyper-V -IncludeManagementTools -Restart