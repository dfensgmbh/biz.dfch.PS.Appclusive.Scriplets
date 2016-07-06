$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Test-Entity.Tests" "Test-Entity.Tests" {

	Mock Export-ModuleMember { return $null; }

	Context "Acl" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			
			$svc = Enter-Apc;
		}
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}
		
		It "Aces" -Test {
			
			$aclCache = @{};
			
			$entities = $svc.Core.Aces.AddQueryOption('$orderby', "Id desc").Execute();
				
			while($true)
			{
				foreach($entity in $entities)
				{
					if(!$aclCache.ContainsKey($entity.AclId))
					{
						$q = "Id eq {0}" -f $entity.AclId;
						$acl = $svc.Core.Acls.AddQueryOption('$filter', $q).AddQueryOption('$top', 1) | Select;
						if($null -eq $acl)
						{
							$aclCache.Add($entity.AclId, $false);
						}
						else
						{
							$aclCache.Add($entity.AclId, $true);
						}
					}
					if($true -ne $aclCache.Item($entity.AclId))
					{
						Write-Warning ("Id '{0}'. Name '{1}'. AclId '{2}'." -f $entity.Id, $entity.Name, $entity.AclId);
					}
				}
				$continuation = $entities.GetContinuation();
				if ($continuation -eq $null)
				{
					break;
				}
				$entities = $svc.Core.Execute($continuation);
			};
		}
		
		It "Acls" -Test {
			
			$nodeCache = @{};
			
			$entities = $svc.Core.Acls.AddQueryOption('$orderby', "Id desc").Execute();
				
			while($true)
			{
				foreach($entity in $entities)
				{
					if(1 -ne $entity.EntityKindId)
					{
						Write-Warning ("Non-Node ACL found. Skipping test. Id '{0}'. Name '{1}'. EntityId '{2}'. EntityKindId '{3}'" -f $entity.Id, $entity.Name, $entity.EntityId, $entity.EntityKindId);
						
						continue;
					}
					if(!$nodeCache.ContainsKey($entity.EntityId))
					{
						$q = "Id eq {0}" -f $entity.EntityId;
						$node = $svc.Core.Nodes.AddQueryOption('$filter', $q).AddQueryOption('$top', 1) | Select;
						if($null -eq $node)
						{
							$nodeCache.Add($entity.EntityId, $false);
						}
						else
						{
							$nodeCache.Add($entity.EntityId, $true);
						}
					}
					if($true -ne $nodeCache.Item($entity.EntityId))
					{
						Write-Warning ("Id '{0}'. Name '{1}'. EntityId '{2}'. EntityKindId '{3}'" -f $entity.Id, $entity.Name, $entity.EntityId, $entity.EntityKindId);
					}
				}
				$continuation = $entities.GetContinuation();
				if ($continuation -eq $null)
				{
					break;
				}
				$entities = $svc.Core.Execute($continuation);
			};
		}
		
		It "Jobs" -Test {
			
			$nodeCache = @{};
			
			$entities = $svc.Core.Jobs.AddQueryOption('$orderby', "Id desc").Execute();
				
			while($true)
			{
				foreach($entity in $entities)
				{
					if(1 -ne $entity.EntityKindId)
					{
						Write-Warning ("Non-Node JOB found. Skipping test. Id '{0}'. Name '{1}'. EntityId '{2}'. EntityKindId '{3}'" -f $entity.Id, $entity.Name, $entity.RefId, $entity.EntityKindId);
						
						continue;
					}
					if(!$nodeCache.ContainsKey($entity.RefId))
					{
						$q = "Id eq {0}" -f $entity.RefId;
						$node = $svc.Core.Nodes.AddQueryOption('$filter', $q).AddQueryOption('$top', 1) | Select;
						if($null -eq $node)
						{
							$nodeCache.Add($entity.RefId, $false);
						}
						else
						{
							$nodeCache.Add($entity.RefId, $true);
						}
					}
					if($true -ne $nodeCache.Item($entity.RefId))
					{
						Write-Warning ("Id '{0}'. Name '{1}'. EntityId '{2}'. EntityKindId '{3}'" -f $entity.Id, $entity.Name, $entity.RefId, $entity.EntityKindId);
					}
				}
				$continuation = $entities.GetContinuation();
				if ($continuation -eq $null)
				{
					break;
				}
				$entities = $svc.Core.Execute($continuation);
			};
		}
	}
}

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
