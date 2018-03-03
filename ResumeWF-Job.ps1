#* This is the script that will initiate the workflow upon the computer restarting

# Sleep for 30 seconds before beginning... 
Start-Sleep -Seconds 30

# Acquire the job to wait on ....

$job = Get-Job -Name ResumeVegaFixWorkflow | Where-Object {$_.State -eq 'Suspended'} | select -Index 0
Resume-Job $job.id


# Set the counter for visual display of seconds spent after reboot....
$x = 0

# Wrap code in try / finally block to gracefully exit once finished.
try {

# While the scheduled task that initiated the workflow hasn't been deleted....
while ((Get-ScheduledTask -TaskName ResumeWFJobTask -ErrorAction stop) -ne $null){
    'Vega Frontier script is running... ' + $x + 's...' | Out-Host
    Start-Sleep -Seconds 10
    $x += 10
}
}
# Notify the user that the entire operation has completed!  All scheduled tasks, workflows and jobs
# should have already been cleaned up by this code block.
finally {
    $x = 20
    'Detected that the final task has completed; your VEGA rigs should now' | Out-Host
    'be able to mine at apx. 2kh/s each.  Happy mining!' | Out-Host
}