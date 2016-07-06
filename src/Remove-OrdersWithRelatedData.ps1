#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Appclusive.Client'; ModuleVersion = "2.8.1" }

[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'High'
)]
PARAM
(
	# N/A
)

function DeleteEntities
{
	[CmdletBinding(
		SupportsShouldProcess = $true
		,
		ConfirmImpact = 'High'
	)]
	PARAM
	(
		[Parameter(Mandatory = $false)]
		[String] $Endpoint = 'Core'
		,
		[Parameter(Mandatory = $true, Position = 0)]
		[String] $EntitySetName
	)
	
	$svc = Enter-ApcServer;
	
	$entities = $svc.$Endpoint.$EntitySetName.Execute();
	
	while($true)
	{
		foreach($entity in $entities)
		{
			$itemString = '{0}/[{1}]/{2}' -f $EntitySetName, $entity.Id, $entity.Name;
			if($PSCmdlet.ShouldProcess($itemString))
			{
				try
				{
					$svc.Core.DeleteObject($entity);
					$null = $svc.Core.SaveChanges();
				}
				catch
				{
					Write-Host ("Removing entity '{0}' [{1}] FAILED.{2}{3}" -f $entity.Name, $entity.Id, [Environment]::NewLine, ($entity | Out-String)) -ForegroundColor Red;
				}
			}
		}
		
		$continuation = $entities.GetContinuation();
		if ($continuation -eq $null)
		{
			break;
		}
		$entities = $svc.Core.Execute($continuation);
	}
}

function DeleteNodeEntities
{
	[CmdletBinding(
		SupportsShouldProcess = $true
		,
		ConfirmImpact = 'Low'
	)]
	PARAM
	(
		# N/A
	)
	
	$svc = Enter-ApcServer;
	
	# do *NOT* use `| Select`, as we use the GetContinuation() later on this DataServiceQueryResponse
	$entities = $svc.Core.Nodes.AddQueryOption('$filter', "(EntityKindId ne 29) and (EntityKindId ne 33)").AddQueryOption('$orderby', "Id desc").Execute();
	
	while($true)
	{
		foreach($entity in $entities)
		{
			try
			{
				$svc.Core.DeleteObject($entity);
				$null = $svc.Core.SaveChanges();
			}
			catch
			{
				Write-Host ("Removing entity '{0}' [{1}] FAILED.{2}{3}" -f $entity.Name, $entity.Id, [Environment]::NewLine, ($entity | Out-String)) -ForegroundColor Red;
			}
		}
		
		$continuation = $entities.GetContinuation();
		if ($continuation -eq $null)
		{
			break;
		}
		$entities = $svc.Core.Execute($continuation);
	}
}

function DeleteJobEntities
{
	[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	)]
	PARAM
	(
		# N/A
	)
	
	$svc = Enter-ApcServer;
	
	$entities = $svc.Core.Jobs.AddQueryOption('$filter', "(substringof('tenant', Description) eq false) or (Description eq null)").AddQueryOption('$orderby', "Id desc").Execute();
	
	while($true)
	{
		foreach($entity in $entities)
		{
			try
			{
				$svc.Core.DeleteObject($entity);
				$null = $svc.Core.SaveChanges();
			}
			catch
			{
				Write-Host ("Removing entity '{0}' [{1}] FAILED.{2}{3}" -f $entity.Name, $entity.Id, [Environment]::NewLine, ($entity | Out-String)) -ForegroundColor Red;
			}
		}
		
		$continuation = $entities.GetContinuation();
		if ($continuation -eq $null)
		{
			break;
		}
		$entities = $svc.Core.Execute($continuation);
	}
}

Write-Host "START removing orders with all related data ..." -ForegroundColor Yellow;

DeleteEntities -EntitySetName "Machines" -Confirm:$Confirm;
DeleteEntities -EntitySetName "Approvals" -Confirm:$Confirm;
DeleteEntities -EntitySetName "Assocs" -Confirm:$Confirm;
DeleteEntities -EntitySetName "EntityBags" -Confirm:$Confirm;
DeleteEntities -EntitySetName "ExternalNodeBags" -Confirm:$Confirm;
DeleteEntities -EntitySetName "ExternalNodes" -Confirm:$Confirm;
DeleteEntities -EntitySetName "Gates" -Confirm:$Confirm;
DeleteEntities -EntitySetName "Orders" -Confirm:$Confirm;

if($PSCmdlet.ShouldProcess('Delete all Nodes expect root and configuration nodes'))
{
	DeleteNodeEntities -Confirm:$Confirm;
}

if($PSCmdlet.ShouldProcess('Delete all Jobs expect root and configuration jobs'))
{
	DeleteJobEntities -Confirm:$Confirm;
}

if($PSCmdlet.ShouldProcess('Clear Audit Log'))
{
	try
	{
		$svc = Enter-Apc;
		$svc.Core.InvokeEntitySetActionWithVoidResult("SpecialOperations", "ClearAuditLog", $null);
		Write-Host "Clearing audit log SUCCEEDED" -ForegroundColor Green;
	}
	catch
	{
		Write-Host "Clearing audit log FAILED" -ForegroundColor Red;
	}
}

Write-Host "END removing orders with all related data COMPLETED" -ForegroundColor Yellow;

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
