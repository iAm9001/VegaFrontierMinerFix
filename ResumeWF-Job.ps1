#* This is the script that will initiate the workflow upon the computer restarting

$jobs = Get-Job -state Suspended | Where-Object {$_.name -like '*vega*'}
$jobs | resume-job