#* This is the script that will initiate the workflow upon the computer restarting

$job = Get-Job -Name 'ResumeVegaFixWorkflow' | Where-Object {$_.State -eq 'Suspended'} | select -Index 0
Resume-Job $job.id
Start-Sleep -Seconds 15

#! Execute task removal code one more time for the sake of redundancy, will figure out where the
#! best place to remove the task is later

#* Remove any stray scheduled tasks from previous runs
Get-ScheduledTask -TaskName ResumeWFJobTask -ErrorAction SilentlyContinue | Unregister-ScheduledTask -Confirm:$false