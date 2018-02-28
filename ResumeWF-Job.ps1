#* This is the script that will initiate the workflow upon the computer restarting

$job = Get-Job -Name 'ResumeVegaFixWorkflow' | Where-Object {$_.State -eq 'Suspended'} | select -Index 0
Resume-Job $job.id
Start-Sleep -Seconds 15