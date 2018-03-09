<# This script will uninstall your VEGA drivers with a fresh installation via DDU, 
and then begin the process of performing the steps requried to make your Vega Frontier
graphics cards perform adequately for mining with maximum hash rates.
#> 

Param(
    [Parameter(Mandatory=$false,
    ParameterSetName="StartupParams",
    HelpMessage="Set the path to your mining executable to begin your miner after the operation has completed.")]
    [Alias("Miner")]
    [ValidateNotNullOrEmpty()]
    [string]
    $MinerPath)

# * This function will clean your AMD drivers from your system, without initiating a reboot.
# * The rebooting operation will be handled via a workflow job instead.
function CleanVegaDrivers {
    Param(
        [Parameter(Mandatory=$true,
            ParameterSetName="VegaParams",
            HelpMessage="Literal path to DDU executable...")]
    [Alias("PSPath")]
    [ValidateNotNullOREmpty()]
    [string]
    $DduExecutableFullPath)

    # Halt script execution if DDU could not be successfully executed
    if (!(test-path $DduExecutableFullPath)){
        throw 'Error --- could not locate DDU executable!'
    }

    # Get the parent folder name of the DDU executable
    $dduParentFolder = [System.IO.FileInfo]::new($DduExecutableFullPath).DirectoryName

    'Cleaning AMD drivers..' | Out-Host

    # Change current location to DDU executable path...
    Set-Location $dduParentFolder

    Start-Process -FilePath $DduExecutableFullPath -ArgumentList @('-silent', '-cleanamd') -Wait
   # (& $DduExecutableFullPath -silent -cleanamd) | Out-Null  #-restart
        
    'sleeping for 10 seconds before rebooting after DDU...' | Out-Host
    start-sleep -Seconds 10
    'rebooting...' | Out-Host
}

# * This function will install the AMD Adrenaline drivers 
function InstallAdrenalineDrivers {
    'Installing Adrenaline drivers....' | Out-Host

    # Grab only the last device
    $displays = (Get-PnpDevice | Where-Object {($_.friendlyname -like 'Microsoft Basic Display Adapter' -and $_.Present) -or $_.friendlyname -like 'Radeon Vega Frontier Edition'})[-1]
    
    # Initiate a new Powershell process to install the drivers using Devcon
    #Start-Process -Wait -FilePath 'C:\Program Files (x86)\Windows Kits\10\Tools\x64\devcon.exe' -ArgumentList @(("update C:\AMD\Win10-64Bit-Radeon-Software-Adrenalin-Edition-18.1.1-Jan4\Packages\Drivers\Display\WT6A_INF\C0322612.inf " + $displays.HardwareID[0])) | Out-Null
    Start-Process -Wait -FilePath 'C:\Program Files (x86)\Windows Kits\10\Tools\x64\devcon.exe' -ArgumentList @(("update C:\AMD\Win10-64Bit-Radeon-Software-Adrenalin-Edition-18.3.1-March5\Packages\Drivers\Display\WT6A_INF\C0325048.inf " + $displays.HardwareID[0])) | Out-Null

    # Pause for 2 minutes to allow for any back-end system operations to clean up
    'Installation of Adrenaline drivers complete.' | Out-Host
    'Pausing for 2 minutes before next operations...' | Out-Host
    Start-Sleep -Seconds 30
}

# * This function will install the AMD Blockchain drivers
function InstallBlockchainDrivers {

    'Installing Blockchain drivers...' | Out-Host
    
    # Grab only the last display
    $displays = (Get-PnpDevice | Where-Object {$_.friendlyname -like 'Radeon Vega Frontier Edition'})[-1]
    
    # Initiate a new Powershell process to install the drivers using Devcon
    Start-Process -Wait -FilePath 'C:\Program Files (x86)\Windows Kits\10\Tools\x64\devcon.exe' -ArgumentList @(("update C:\amd\Win10-64Bit-Crimson-ReLive-Beta-Blockchain-Workloads-Aug23\Packages\Drivers\Display\WT6A_INF\C0317304.inf " + $displays.HardwareID[0])) | Out-Null
    
    # Pause for 2 minutes to allow for any back-end system operations to clean up
    'Installation of Blockchain drivers complete.' | Out-Host
    'Pausing for 2 minutes before next operation...' | Out-Host
    start-sleep -Seconds 30
}

# * Disables all Vega Frontier devices on the system, or optionall to skip disabling the firt one.
# * Default is to disable; the function can be used to enable cards by specifying the EnableOperation switch.
function ChangeVegaState {
    Param(
       # Optional switch to instruct function to skip disabling / enabling the last Vega display adapter
       [Parameter(Mandatory = $false)]
       [switch]
       $SkipLastVega,
      # $SkiplastVega, 

       # Specify to perform enable operations instead
       [Parameter(Mandatory = $false)]
       [switch]
       $EnableOperation)

    # Set value for output display of either enable or disable operation
    $operationType = [string]::Empty
    if ($EnableOperation) {
        $operationType = 'Enable'
    }
    else {
        $operationType = 'Disable'
    }

     
    # Get all Vega frontier display adapters
	$displays = Get-PnpDevice | Where-Object {$_.friendlyname -like 'Radeon Vega Frontier Edition'}
    
    # Remove the last Vega display adapter from the list if the SkiplastVega switch was specified
    if ($SkipLastVega) {

    'Getting last Vega...' | Out-Host

    # Establish the primary Vega display adapter from index 0
    $lastVega = $displays[-1]
    
    'Last Vega identified as ' + $lastVega.HardwareID | Out-Host

    # Set the collection of all of the displays to equal itself minus the last display
    $displays = $displays | Where-Object {$_ -ne $lastVega}
    }

    # Initialize counter for console output
    $i = 1
    # Loop through each display adapter and change it's state
	foreach ($dev in $displays) {       
        "$operationType display adapter $i" | Out-Host
    
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
Start-Sleep -Seconds 30
}

#* This function will disable Crossfire and Ulps in your Windows registry on all display adapters
#* when called.
function DisableCrossfireUlps {

    'Disabling Crossfire and ULPS on all Vega...' | Out-Host

    # Set the path to your Vega Frontier registry keys here
    $regKeyPath = 'SYSTEM\CurrentControlSet\Control\Class\{4d36e968-e325-11ce-bfc1-08002be10318}'

    # Navigate to the Windows Registry
    Set-Location HKLM:\$regKeyPath

    # Get all registry key paths, ignore errors
    $keyPaths = Get-ChildItem -ErrorAction SilentlyContinue

    
    # Navigate to each Vega Frontier display adapter registry path, that ends with a numbered
    # display adapter, and disable Crossfire and Ulps.
    foreach ($k in $keyPaths | Where-Object {$_.name -match '\\[\d]{4}$' } ){

        # Set the location to the path of the adapter key
        Set-Location $k.PSPath | Out-Null    
        
        'Disabling Crossfire on ' + $k.PSPath | Out-Host
        Set-ItemProperty -Path. -Name 'EnableCrossFireAutoLink' -Value 0 | Out-Null
        
        'Disabling Ulps on ' + $k.PSPath | Out-Host
        Set-ItemProperty -Path. -Name 'EnableUlps' -Value 0 | Out-Null
        
        'Next...' | Out-Host
    }
}

#* This function will clean up the jobs and scheduled jobs that were created during the operation
#* of this script.

function CleanVegaJobs{

    # Cleanup Vega workflow jobs....
    'Cleaning up Vega workflows...' | Out-Host
    Get-Job | Where-Object {$_.Name -like '*vega*'} | Stop-Job
    Get-Job | Where-Object {$_.Name -like '*vega*'} | Remove-Job
    Get-ScheduledJob | Where-Object {$_.Name -like '*vega*'} | Unregister-ScheduledJob
    }

function CleanScheduledTask{
    # Remove any stray scheduled tasks from previous runs
    Get-ScheduledTask -TaskName ResumeWFJobTask -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

}

# Function to start the miner if a path is provided during startup
function StartMiner{
    Param(
    [Parameter(Mandatory=$true,
    ParameterSetName="StartupParams",
    HelpMessage="Set the path to your mining executable to begin your miner after the operation has completed.")]
    [Alias("Miner")]
    [ValidateNotNullOrEmpty()]
    [string]
    $MinerPath)

    # Get miner file info
    $minerFileInfo = [System.IO.FileInfo]::new($MinerPath)
    $minerDirectoryName = $minerFileInfo.DirectoryName

    # Change location to location of miner
    "Changing location to $minerDirectoryName ..." | Out-Host
    Set-Location $minerDirectoryName

    #! Sleep for 30 seconds to allow for time for display adapters to finish "setting up?..."
    Start-Sleep -Seconds 30

    # Execute miner...
    "Executing miner $MinerPath ..." | Out-Host
    Start-Process -Wait -FilePath $MinerPath
}


#* This is a workflow that will execute in the background after windows reboots to resume the Vega display adapter
#* repair process.
workflow VegaFixWorkflow {
    Param(
    [Parameter(Mandatory=$false,
    ParameterSetName="StartupParams",
    HelpMessage="Set the path to your mining executable to begin your miner after the operation has completed.")]
    [Alias("Miner")]
    [ValidateNotNullOrEmpty()]
    [string]
    $MinerPath)

    # * Set the Display Driver Uninstaller (DDU) full EXE path
    # Clean the Vega drivers from your system
    CleanVegaDrivers -ddu 'C:\crypto\ddu\Display Driver Uninstaller.exe'
    Restart-Computer -Wait

    # Install the Adrenaline drivers
    InstallAdrenalineDrivers

    # Disable Crossfire and Ulps on all cards
    DisableCrossfireUlps

    # Disable all Vega display adapters except for the last adapter
    ChangeVegaState -SkipLastVega

    # Disable Crossfire and Ulps on all cards again, just in case...
    DisableCrossfireUlps

    # Enable all Vega adapters except for the last adapter (should already been enabled)
    ChangeVegaState -EnableOperation -SkipLastVega

    # Install Blockchain drivers...
    InstallBlockchainDrivers

    # Disable Crossfire and Ulps on all cards again, just in case...
    DisableCrossfireUlps

    # Disable all Vega display adapters...
    ChangeVegaState

    # Enable all Vega dispay adapters...
    ChangeVegaState -EnableOperation

    # If the miner path was provided, start the miner in a new process.
    if ($MinerPath){
        StartMiner -MinerPath $MinerPath
    }

    # Clean up jobs and scheduled jobs / workflows...
    CleanVegaJobs
    
    # Remove teh scheduled task that runs the workflow on logon
    CleanScheduledTask

    # Finished!
    return
}

# Set the current execution path to the same folder that the script was exeuted from
#$commandPath = ($PSCommandPath | Out-String).Trim()
#Set-Location -LiteralPath [System.IO.FileInfo]::new($commandPath.Trim()).DirectoryName

# Ensure that the script is being executed with Administrator authority
If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    $dirName = (Get-Location).Path

    $argsString = ''
    
    if ($MinerPath){
        $argsString += '-MinerPath ' + $dirName + ' '

        'Miner path ' + $MinerPath + ' specified during script launch... miner will automatically launch upon process completion.' | Out-Host
    }
    
    # Start the process as administrator
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" $argsString" -Verb RunAs -Wait
    exit
    return
}

# Set script to enter the path where the .ps1 file was extracted to (and executed from).  Fixes problems encountered when right click + run with powershell
# is performed
$scriptDir = [System.IO.FileInfo]::new($PSCommandPath).DirectoryName
Set-Location -LiteralPath $scriptDir

# Validate path to miner parameter if it was entered as a command line parameter
if (!([string]::IsNullOrWhiteSpace($MinerPath))){
    if (!(test-path $MinerPath)){
        'Error - mining script provided does not exist...' | Out-Host
        Read-Host
        throw 'The path provided to your mining software was invalid.  Please fix or remove.'
    }
}
# Clean up any stray jobs before execution begins
CleanVegaJobs

# Make positive ID on ResumeWF-Job.ps1 and leverage FullName property to pass to -File attribute on resumeActionSCript
$resumeWFTaskScript = Get-ChildItem -File 'ResumeWF-Job.ps1'

if ($null -eq $resumeWFTaskScript -or $resumeWFTaskScript -isnot [System.IO.FileInfo]){
    throw 'Error:  was unable to locate the required script to resume workflow - ResumeWF-Job.ps1'
} 

# Create the scheduled job properties
$options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery

#$secpasswd = ConvertTo-SecureString "yourPasswordHere" -AsPlainText -Force

# Get the credentials of the current user to use for automatic workflow exceution
$credentials = Get-Credential -UserName ($env:COMPUTERNAME.ToString() + '\' + $env:USERNAME) -Message 'Enter your curren local machine credentials (hostname\Username)...'

# Define the script block text that will resume the workflow after reboot
$resumeWorkflowScriptString = '[System.Management.Automation.Remoting.PSSessionConfigurationData]::IsServerManager = $true
Import-Module PSWorkflow
Resume-Job -Name ResumeVegaFixWorkflow -Wait'

# Script block to execute responsible for resuming the workflow after rebooting.
$resumeWorkflowScriptblock = [scriptblock]::Create($resumeWorkflowScriptString)

#$credentials = New-Object System.Management.Automation.PSCredential ($env:COMPUTERNAME.ToString() +"\brand", $secpasswd)
$AtStartup = New-JobTrigger -AtLogOn

'registering job...' | Out-Host
# Register the scheduled job
Register-ScheduledJob  -Name VegaFixWorkflow -Trigger $AtStartup -Credential $credentials -ScriptBlock $resumeWorkflowScriptblock -ScheduledJobOption $options

# Schedule a task to resume the job
$resumeActionscript = '-WindowStyle Normal -NoLogo -NoProfile -File "' + $resumeWFTaskScript.FullName + '"'

'killing scheduled tasks...' | Out-Host
# Remove any stray scheduled tasks from previous runs
Get-ScheduledTask -TaskName ResumeWFJobTask -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false

'scheduling resume task...' | Out-Host
$act = New-ScheduledTaskAction -Execute "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -Argument $resumeActionscript
$trig = New-ScheduledTaskTrigger -RandomDelay 00:01:00 -AtLogOn
Register-ScheduledTask -TaskName ResumeWFJobTask -Action $act -Trigger $trig -RunLevel Highest


# Execute the workflow either with the miner auto-launch, or without depending on whether a path was provided
if ($MinerPath){
    # Execute the workflow as a new job with the miner path provided after
    VegaFixWorkflow -MinerPath $MinerPath -AsJob -JobName ResumeVegaFixWorkflow
}
else {
    # Execute the workflow as a new job
    VegaFixWorkflow -AsJob -JobName ResumeVegaFixWorkflow
}

'Powershell workflow initiated... will reboot and resume script operation' | Out-Host
'(remember, you can also execute this script with the -MinerPath parameter to ' | Out-Host
'also have this script restart your miner upon reboot! ie. ' | Out-Host
'fix_vega.ps1 -MinerPath c:\miner\miner.bat' | Out-Host 