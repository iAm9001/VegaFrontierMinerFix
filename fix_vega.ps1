<# This script will uninstall your VEGA drivers with a fresh installation via DDU,
and then begin the process of performing the steps requried to make your Vega Frontier
graphics cards perform adequately for mining with maximum hash rates.
#>
Param(
[Parameter(Mandatory = $false, 
           
           ParameterSetName = "VegaParams", 
           ValueFromPipeline = $false, 
           ValueFromPipelineByPropertyName = $false, 
           HelpMessage = "Sets the script to intiate DDU removal")]
[ValidateNotNullOrEmpty()]
[switch]
$ParameterName)

#* This function will clean your AMD drivers from your system, without initiating a reboot.
#* The rebooting operation will be handled via a workflow job instead.
function cleanVegaDrivers {
    'Cleaning AMD drivers..'| Out-Host
    Set-Location C:\crypto\ddu 
    (& '.\Display Driver Uninstaller.exe' -silent -cleanamd) | Out-Null  # - restart
    Start-Sleep -Seconds 15
    
    'sleeping for 10 seconds before rebooting after DDU...' | Out - Host
    start-sleep - s 10
    'rebooting...' | Out-Host
}
