# Set PowerShell execution policy to RemoteSigned for the current user
$ExecutionPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($ExecutionPolicy -eq "RemoteSigned") {
    Write-Verbose "Execution policy is already set to RemoteSigned for the current user, skipping..." -Verbose
}
else {
    Write-Verbose "Setting execution policy to RemoteSigned for the current user..." -Verbose
    Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
}

# Install chocolatey
if ([bool](Get-Command -Name 'choco' -ErrorAction SilentlyContinue)) {
    Write-Verbose "Chocolatey is already installed, skip installation." -Verbose
}
else {
    Write-Verbose "Installing Chocolatey..." -Verbose
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install OpenSSH Server
if ([bool](Get-Service -Name sshd -ErrorAction SilentlyContinue)) {
    Write-Verbose "OpenSSH is already installed, skip installation." -Verbose
}
else {
    Write-Verbose "Installing OpenSSH..." -Verbose
    $openSSHpackages = Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Select-Object -ExpandProperty Name

    foreach ($package in $openSSHpackages) {
        Add-WindowsCapability -Online -Name $package
    }

    # Start the sshd service
    Write-Verbose "Starting OpenSSH service..." -Verbose
    Start-Service sshd
    Set-Service -Name sshd -StartupType 'Manual'

    # Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
    Write-Verbose "Confirm the Firewall rule is configured..." -Verbose
    if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
        Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
        New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
    }
    else {
        Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
    }
}

# Check if WSL is installed
$wslFeature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux
if ($wslFeature.State -eq 'Enabled') {
    Write-Host "WSL is already installed."
} else {
    Write-Host "WSL is not installed. Installing WSL..."
    wsl --set-default-version 2
    wsl --install
}

# Install Docker Desktop using Chocolatey
if ([bool](Get-Command -Name 'docker' -ErrorAction SilentlyContinue)) {
    Write-Verbose "Docker Desktop is already installed, skip installation." -Verbose
} else {
    Write-Verbose "Installing Docker Desktop using Chocolatey..." -Verbose
    choco install docker-desktop -y
}

# TODO: Try to add an automation here
# Function to close SSH port, should be run after the setup is complet
function Close-SSHPort {
    Write-Verbose "Stopping OpenSSH service..." -Verbose
    Stop-Service sshd
    
    Write-Verbose "Disabling OpenSSH firewall rule..." -Verbose
    Set-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -Enabled False
    
    Write-Output "SSH service stopped and port 22 closed."
}