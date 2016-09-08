#Requires -Modules biz.dfch.PS.Appclusive.Client

$deletedGatesCount = 0;
$svc = Enter-Appclusive;

# Load all Gates referencing a Job
$jobGates = $svc.Core.Gates.AddQueryOption('$filter', "startswith(Name, 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Job')").Execute();
	
while($true)
{
	foreach($jobGate in $jobGates)
	{
		# Extract Id of the Job from Gate name
		$result = $jobGate.Name -match '\.Job-(\d+)\-';
        if(!$result)
        {
            continue;
        }
        $jobId = $Matches[1];
		
		# Try loading Job
		$job = Get-ApcJob -Id $jobId -svc $svc;
		if ($job)
		{
			continue;
		}
		
		 Write-Warning ("{0}: referenced job '{1}' does not exist." -f $jobGate.Name, $jobId);
		
		try
		{
			$svc.Core.DeleteObject($jobGate);
			$result = $svc.Core.SaveChanges();
			Contract-Assert (204 -eq $result.StatusCode);
			$deletedGatesCount ++;
		}
		catch
		{
			Write-Host ("Removing Job Gate '{0}' [{1}] FAILED.{2}{3}" -f $jobGate.Name, $jobGate.Id, [Environment]::NewLine, ($entity | Out-String)) -ForegroundColor Red;
		}
	}
	
	$continuation = $jobGates.GetContinuation();
	if ($continuation -eq $null)
	{
		break;
	}
	$jobGates = $svc.Core.Execute($continuation);
}

Write-Host ("Removing orphaned Gates completed. '{0}' Gates deleted." -f $deletedGatesCount) -ForegroundColor Green;

#
# Copyright 2016 d-fens GmbH
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
