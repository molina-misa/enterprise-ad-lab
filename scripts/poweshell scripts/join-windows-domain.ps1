<#
.SYNOPSIS
    Configura dirección IP estática y une el cliente Windows 11 al dominio agmimo.local.
.NOTES
    Ejecutar en PowerShell con privilegios de Administrador.
#>

$ErrorActionPreference = "Stop"

$Domain = "agmimo.local"
$NewComputerName = "WINDOWS-HOST"
$IPAddress = "192.168.50.20"
$PrefixLength = 24
$Gateway = "192.168.50.1"
$DnsServer = "192.168.50.254"

Write-Host "[1/4] Obteniendo adaptador de red primario..." -ForegroundColor Cyan
$Adapter = Get-NetAdapter | Where-Status -Eq "Up" | Select-Object -First 1

if (-not $Adapter) {
    Throw "No se encontró un adaptador de red activo."
}

Write-Host "[2/4] Configurando IP Estática y DNS en $($Adapter.Name)..." -ForegroundColor Cyan
New-NetIPAddress -InterfaceAlias $Adapter.Name -IPAddress $IPAddress -PrefixLength $PrefixLength -DefaultGateway $Gateway -SkipAsSource $false -ErrorAction SilentlyContinue
Set-DnsClientServerAddress -InterfaceAlias $Adapter.Name -ServerAddresses $DnsServer

Write-Host "[3/4] Renombrando el equipo a $NewComputerName..." -ForegroundColor Cyan
Rename-Computer -NewName $NewComputerName -Force

Write-Host "[4/4] Uniendo el host al dominio $Domain..." -ForegroundColor Cyan
$Credential = Get-Credential -UserName "$Domain\Administrator" -Message "Ingrese credenciales de administrador de dominio"
Add-Computer -DomainName $Domain -Credential $Credential -Force

Write-Host "==============================================================================" -ForegroundColor Green
Write-Host " OK: Equipo unido al dominio $Domain correctamente." -ForegroundColor Green
Write-Host " El sistema se reiniciará en 10 segundos..." -ForegroundColor Yellow
Write-Host "==============================================================================" -ForegroundColor Green

Start-Sleep -Seconds 10
Restart-Computer -Force
