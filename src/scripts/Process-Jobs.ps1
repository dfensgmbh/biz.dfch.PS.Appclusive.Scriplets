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
			Write-Host ("No handling for job '{0}' [{1}] found.{2}{3}" -f $job.Name, $job.Id, [Environment]::NewLine, $job);
		}
    }
}

#
# Copyright 2015 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
