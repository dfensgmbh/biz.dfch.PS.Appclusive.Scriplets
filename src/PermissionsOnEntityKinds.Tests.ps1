$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe "PermissionsOnEntityKinds" -Tags "PermissionsOnEntityKinds.Tests" {

	Mock Export-ModuleMember { return $null; }

	Context "PermissionsOnEntityKinds" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			
			$svc = Enter-Apc;
		}
		
		It "Warmup" -Test {
			$true | Should Be $true;
		}

		It "ExtractStateTransitions" -Test {
			[string] $fn = "ExtractStateTransitions";

			$eks = New-Object System.Collections.Generic.List``1[biz.dfch.CS.Appclusive.Api.Core.EntityKind];

			$continuation = $true;
			$response = $svc.Core.EntityKinds.Execute();
			do
			{
				foreach($ek in $response) 
				{ 
					if([biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::IntrinsicEnd.value__ -ge $ek.Id)
					{
						continue;
					}

					if($ek.Name -eq $ek.Version)
					{
						Log-Warn $fn ("{0} [{1}] has identical Version. Skipping ..." -f $ek.Name, $ek.Id);
						continue;
					}

					$eks.Add($ek); 
				}
				$continuation = $response.GetContinuation();
				if(!$continuation)
				{
					break;
				}
				$response = $svc.Core.Execute($continuation);
			}
			while($continuation)
			Contract-Assert (0 -lt $eks.Count)

			foreach($ek in $eks)
			{
				try
				{
					$dic = New-Object biz.dfch.CS.Appclusive.Public.DictionaryParameters($ek.Parameters);
					$statesAndTransistions = $dic.Keys.Split("-");
					$transitions = New-Object System.Collections.ArrayList;

					for($c = 1; $c -lt $statesAndTransistions.Count; $c += 2)
					{
						$transition = $statesAndTransistions[$c];
						if("Initialise" -eq $transition)
						{
							continue;
						}
						$transitions.Add($transition);
					}

                    if ($transitions.Count -eq 0)
                    {
                        continue;
                    }
                    
                    Write-Host "";
                    Write-Host "EntityKind " -ForegroundColor Yellow -NoNewline;
                    Write-Host ("{0} | {1}" -f $ek.Name, $ek.Version);


					foreach($transition in $transitions)
					{
                        Write-Host "  Transition " -ForegroundColor Yellow -NoNewline;
                        Write-Host ("{0} " -f $transition) -NoNewline;

                        # Check if None-Versioned Permission exists --> Continue
						$permissionName = "{0}:{1}" -f $ek.Name, $transition;

						$q = "Name eq '{0}'" -f $permissionName;
						$permission = $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select;
						if($permission)
						{
							Log-Warn $fn ("{0}: {1} {2}. PermissionName '{3}' already exists. Skipping ..." -f $ek.Id, $ek.Name, $ek.Version, $permissionName);
                            Write-Host "Exists" -ForegroundColor magenta;
							continue;
						}

                        # Check if Versioned Permission exists --> Rename
                        $versionPermissionName = "{0}:{1}" -f $ek.Version, $transition;

						$q = "Name eq '{0}'" -f $versionPermissionName;
						$permission = $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select;
						if($permission)
						{
                            $permission.Name = $permissionName;
                            $permission.Description = $permissionName;
						    $svc.Core.UpdateObject($permission);
						    $result = $svc.Core.SaveChanges();

                            Write-Host "Renamed" -ForegroundColor Gray;
                            continue;
						}

                        # Create New
						$permission = New-Object biz.dfch.CS.Appclusive.Api.Core.Permission;
						$svc.Core.AddToPermissions($permission);
						$svc.Core.UpdateObject($permission);
						$permission.Name = $permissionName;
						$permission.Description = $permissionName;
                        Write-Host "Created" -ForegroundColor Green;
						$result = $svc.Core.SaveChanges();
					}

                    
                    Write-Host "  Transition " -ForegroundColor Yellow -NoNewline;
                    Write-Host ("* " -f $transition) -NoNewline;
					$permissionName = "{0}:{1}" -f $ek.Name, '*';
					$q = "Name eq '{0}'" -f $permissionName;
					$permission = $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select;
                    if($permission)
					{
                        Write-Host "Exists" -ForegroundColor Magenta;
						continue;
					}

                    # Check if Versioned Permission exists --> Rename
                    $versionPermissionName = "{0}:{1}" -f $ek.Version, '*';

					$q = "Name eq '{0}'" -f $versionPermissionName;
					$permission = $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select;
					if($permission)
					{
                        $permission.Name = $permissionName;
                        $permission.Description = $permissionName;
						$svc.Core.UpdateObject($permission);
						$result = $svc.Core.SaveChanges();

                        Write-Host "Renamed" -ForegroundColor Gray;
                        continue;
					}

					$permission = New-Object biz.dfch.CS.Appclusive.Api.Core.Permission;
					$svc.Core.AddToPermissions($permission);
					$svc.Core.UpdateObject($permission);
					$permission.Name = $permissionName;
					$permission.Description = $permissionName;
					$result = $svc.Core.SaveChanges();
                    Write-Host "Created" -ForegroundColor Green;
				}
				catch
				{
					Log-Error $fn ("{0}: {1} {2} FAILED." -f $ek.Id, $ek.Name, $ek.Version);
					Log-Exception $_;
				}
			}
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
