#requires -Modules 'biz.dfch.PS.Appclusive.Client'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# DFTODO - I would not dotsource these scripts but write scripts with PARAM block, so they can be called like Cmdlets
. "$here\Process-Order.ps1"

$svc = Enter-AppclusiveServer;

# Get jobs with status 'WaitingToRun'
$waitingJobs = $svc.Core.Jobs.AddQueryOption('$filter', "Status eq 'WaitingToRun'") | Select;

foreach($job in $waitingJobs) 
{
	# Get job type
	$separatorPos = $job.Name.LastIndexOf(".");
	$jobType = $job.Name.Substring($separatorPos + 1);
	
	# Delegation to worker script based on job type
	switch ($jobType) 
    { 
        "Order" 
		{
			ProcessOrder -svc $svc -job $job;
		} 
        default 
		{
			Write-Host ("JobType of job '{0}' [{1}] could not be determined.{2}{3}" -f $job.Name, $job.Id, [Environment]::NewLine, $job);
		}
    }
}
