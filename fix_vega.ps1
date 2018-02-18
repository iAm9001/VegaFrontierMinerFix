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

#* This function will install the AMD Adrenaline drivers 
function installAdrenalineDrivers {
    'Installing Adrenaline drivers....' | Out-Host

    # Grab only the first device
    $displays = Get-PnpDevice | Where-Object {($_.friendlyname -like 'Microsoft Basic Display Adapter' -and $_.Present) -or $_.friendlyname -like 'Radeon Vega Frontier Edition'} | select -Index 0
    
    # Initiate a new Powershell process to install the drivers using Devcon
    Start-Process -Wait -FilePath 'C:\Program Files (x86)\Windows Kits\10\Tools\x64\devcon.exe' -ArgumentList @(("update C:\AMD\Win10-64Bit-Radeon-Software-Adrenalin-Edition-18.1.1-Jan4\Packages\Drivers\Display\WT6A_INF\C0322612.inf " + $displays.HardwareID[0])) | Out-Null
    
    # Pause for 2 minutes to allow for any back-end system operations to clean up
    'Installation of Adrenaline drivers complete.' | Out-Host
    'Pausing for 2 minutes before next operations...' | Out-Host
    Start-Sleep -Seconds 120
}

#* This function will install the AMD Blockchain drivers
function installBlockchainDrivers {

    'Installing Blockchain drivers...' | Out-Host
    # Grab only the first display
    $displays = Get-PnpDevice | Where-Object {$_.friendlyname -like 'Radeon Vega Frontier Edition'} | Select -Index 0
    
    # Initiate a new Powershell process to install the drivers using Devcon
    Start-Process -Wait -FilePath 'C:\Program Files (x86)\Windows Kits\10\Tools\x64\devcon.exe' -ArgumentList @(("update C:\amd\Win10-64Bit-Crimson-ReLive-Beta-Blockchain-Workloads-Aug23\Packages\Drivers\Display\WT6A_INF\C0317304.inf " + $displays.HardwareID[0])) | Out-Null
    
    # Pause for 2 minutes to allow for any back-end system operations to clean up
    'Installation of Blockchain drivers complete.' | Out-Host
    'Pausing for 2 minutes before next operation...' | Out-Host
    start-sleep -Seconds 120
}

#* Disables all Vega Frontier devices on the system, or optionall to skip disabling the firt one.
#* Default is to disable; the function can be used to enable cards by specifying the EnableOperation switch.
function ChangeVegaState {
    Param(
       # Optional switch to instruct function to skip disabling / enabling the first Vega display adapter
       [Parameter(Mandatory = $false)]
       [switch]
       $SkipFirstVega,

       # Specify to perform enable operations instead
       [Parameter(Mandatory = $false)]
       [switch]
       $EnableOperation)

    # Set value for output display of either enable or disable operation
    $operationType = [string]::Empty
    if ($EnableOperation){
        $operationType = 'Enable'
    }
    else {
        $operationType = 'Disable'
    }

     
    # Get all Vega frontier display adapters
	$displays = Get-PnpDevice| Where-Object {$_.friendlyname -like 'Radeon Vega Frontier Edition'}
    
    # Remove the first Vega display adapter from the list if the SkipFirstVega switch was specified
    if ($SkipFirstVega){

    'Getting primary Vega...' | Out-Host

    # Establish the primary Vega display adapter from index 0
    $mainVega = $displays[0]
    
    'Primary Vega identified as ' + $mainVega.HardwareID | Out-Host

    # Set the collection of all of the displays to equal itself minus the first display
    $displays = $displays| Where-Object {$_ -ne $mainVega}
    }

    # Initialize counter for console output
    $i = 1
    # Loop through each display adapter and change it's state
	foreach ($dev in $displays) {       
        "$operationType display adapter $i" | Out-Host
        
        # Define the operation type to perform...
        if ($EnableOperation){
            $displayCommand = Enable-PnpDevice
        }
        else {
            $displayCommand = Disable-PnpDevice
        }

        # Perform the display adapter state change operation
        if ($EnableOperation){
            Enable-PnpDevice -DeviceId $dev.DeviceID -ErrorAction Ignore -Confirm:$false | Out-Null
        }
        else {
            Disable-PnpDevice -DeviceId $dev.DeviceID -ErrorAction Ignore -Confirm:$false | Out-Null
        }
		
        "$operationType (ed) display adapter $i" | Out-Host

        # Sleep for 3 seconds in between each operation
        Start-Sleep -Seconds 3
        
        $i++
    }
    
"Finished $operationType (ing) Vegas..." | Out-Host
'Sleeping for 2 minutes before resuming script operation...' | Out-Host

# Sleep for 2 minutes before resuming script operation...
Start-Sleep -Seconds 120
}
