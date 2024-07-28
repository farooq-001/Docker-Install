# Docker Desktop Installation Script

# Ensure Chocolatey is installed
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

# Install Docker Desktop
choco install docker-desktop -y

# Switch Docker Daemon to Windows containers
Start-Sleep -Seconds 10
& "C:\Program Files\Docker\Docker\DockerCli.exe" -SwitchDaemon

Write-Host "Docker Desktop installation complete."
