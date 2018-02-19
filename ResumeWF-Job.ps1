#* This is the script that will initiate the workflow upon the computer restarting

Import-Module –Name PSWorkflow
$jobs = Get-Job -state Suspended
$resumedJobs = $jobs | resume-job -wait
$resumedJobs | wait-job