#* This is the script that will initiate the workflow upon the computer restarting

#Import-Module –Name PSWorkflow
$jobs = Get-Job -state Suspended | Where-Object {$_.name -like '*vega*'}
$resumedJobs = $jobs | resume-job