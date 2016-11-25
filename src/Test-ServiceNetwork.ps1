$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

. "$here\$sut"
. "$here\Enter-CimiServer.ps1"

if((Test-Path -Path Variable:cimiClient))
{
	Remove-Variable cimiClient -Scope Global;
}
New-Variable cimiClient -Value '' -Scope Global -ErrorAction:SilentlyContinue;

if((Test-Path -Path Variable:CimiMachineName))
{
	Remove-Variable CimiMachineName -Scope Global;
}
New-Variable CimiMachineName -Value 'TestMachine-27dd5c1c-b20c-4ace-87b7-84e36c8009d5' -Scope Global -ErrorAction:SilentlyContinue;

$testCases = @();
$testCases += (@{"machineName" = 'TestMachine-7970fe81-ee86-4ca8-bc73-8fe792da908c' });
$testCases += (@{"machineName" = 'TestMachine-93962aac-7764-4792-b146-1b312721bf55' });


Describe -Tags "ServiceNetwork-Add.Tests" "ServiceNetwork-Add.Tests" {

	Mock Export-ModuleMember { return $null; }

	Context "ServiceNetwork-Add" {
	
		# Context wide constants
		# N/A
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-ApcServer;
		}

		It "CimiClientLogin-Succeeds" -Test {
		
			$Global:cimiClient = Enter-CimiServer;
		
		}

		It "ServiceNetwork-Add" -TestCases $testCases -Test {
		
			param($MachineName)

			$expectedInitialManagementLevel = 'unmanaged';
			$expectedNewManagementLevel = 'full';
			
			$managedServiceDnsSuffix = (Get-ApcKeyNameValue -Key "biz.dfch.CS.Appclusive.Cmp.Cimi" -Name "ManagedServiceDnsSuffix" -Select Value).Value;
			# $managedServiceDnsSuffix = (Get-ApcKeyNameValue -Key "biz.dfch.CS.Appclusive.Cmp.Cimi" -Select Value).Value;
			Contract-Assert (![string]::IsNullOrWhiteSpace($managedServiceDnsSuffix))

			# get machines
			$machinesCollection = $Global:cimiClient.GetMachineCollection($null);
			$machinesCollection | Should Not Be $null;
			$machinesCollection.Machines | Should Not Be $null;
			$machinesCollection.Machines.Count | Should Not Be 0;
			
			# select machine
			$machineBeforeAddingServiceNet = $machinesCollection.Machines |? Name -eq $MachineName;
			$machineBeforeAddingServiceNet | Should Not Be $null;
			$machineBeforeAddingServiceNet -is [IO.Swagger.Model.Machine] | Should Be $true;
			
			#Show MachineID
			Write-Warning ($machineBeforeAddingServiceNet.Id);

			$isEndingWithCimiId = $machineBeforeAddingServiceNet.Id -match '/([^/]+)$';
			$isEndingWithCimiId | Should Be $true;
			$cimiId = [Guid]::Parse($Matches[1]); 
			$cimiId -is [Guid] | Should Be $true;
			
			# assert machine is not in ERROR state
			$machineBeforeAddingServiceNet.State | Should Not Be 'ERROR';

			# note current number of NICs
			$networkInterfaceCountBeforeAdding = $machineBeforeAddingServiceNet.NetworkInterfaces.Count;

			# assert current management level
			$property = $machineBeforeAddingServiceNet.Properties |? Key -eq 'managementLevel' | Select Value;
			$property | Should Not Be $null;
			$property.Value | Should Be $expectedInitialManagementLevel;

			# set new management level
			$machineProperties = New-Object biz.dfch.CS.Cimi.Client.MachineProperties($machineBeforeAddingServiceNet);
			$machineProperties | Should Not Be $null;
			$machineProperties.ManagementLevel = $expectedNewManagementLevel;
			
			# update machine
			$machineAfterAddingServiceNet = $Global:cimiClient.UpdateMachine($machineBeforeAddingServiceNet.Id, $machineProperties, 16, 100, 1800000);
			$machineAfterAddingServiceNet | Should Not Be $null;
			$machineAfterAddingServiceNet -is [IO.Swagger.Model.Machine] | Should Be $true;

			# # get new number of NICs
			$machineAfterAddingServiceNet.NetworkInterfaces | Should Not Be $null;
			$networkInterfaceCountAfterAdding = $machineAfterAddingServiceNet.NetworkInterfaces.Count;
			$networkInterfaceCountAfterAdding | Should Be ($networkInterfaceCountBeforeAdding +1)

			# assert current management level
			$property = $machineAfterAddingServiceNet.Properties |? Key -eq 'managementLevel' | Select Value;
			$property | Should Not Be $null;
			$property.Value | Should Be $expectedNewManagementLevel;
			
			$networkInterface = $null;
			$isMgmtInterfacePresent = $false;
			foreach($networkInterface in $machineAfterAddingServiceNet.NetworkInterfaces.NetworkInterfaces) 
			{ 
				$property = $networkInterface.Properties |? Key -eq 'isMgmtInterface'; 
				if($property.Value -eq 'true') 
				{ 
					$isMgmtInterfacePresent = $true;
					break; 
				}
			}
			$isMgmtInterfacePresent | Should Be $true;
			$networkInterface | Should Not Be $null;
			$networkInterface.Addresses.Count | Should Be 1;
			$networkInterface.Addresses.Addresses[0].Ip | Should Not Be $null;
			$address = $ipAddress = $networkInterface.Addresses.Addresses[0];
			$address | Should Not Be $null;
			$address -is [IO.Swagger.Model.Address] | Should Be $true;
			$ipAddress = $address.Ip;
			$ipAddress | Should Not Be $null;
			
			$fqdn = ('{0}.{1}' -f $cimiId.ToString(), $managedServiceDnsSuffix);
			$pingResult = &ping $fqdn -n 1 -w 10;
			$pingResult | Should Not Be $null;
			$pingResult -is [Array] | Should Be $true;
			1 -le $pingResult.Count | Should Be $true;
			$pingResult[1] -match ".\[(\d+\.\d+\.\d+\.\d+)\]" | Should Be $true;
		}

		It "ServiceNetworkTag-Add-ShouldThrow" -TestCases $testCases -Test {
		
			param($MachineName)

			# get machines
			$machinesCollection = $Global:cimiClient.GetMachineCollection($null);
			$machinesCollection | Should Not Be $null;
			$machinesCollection.Machines | Should Not Be $null;
			$machinesCollection.Machines.Count | Should Not Be 0;
			
			# select machine
			$machineBeforeAddingServiceNet = $machinesCollection.Machines |? Name -eq $MachineName;
			$machineBeforeAddingServiceNet | Should Not Be $null;
			$machineBeforeAddingServiceNet -is [IO.Swagger.Model.Machine] | Should Be $true;
			
			#Show MachineID
			Write-Warning ($machineBeforeAddingServiceNet.Id);

			$isEndingWithCimiId = $machineBeforeAddingServiceNet.Id -match '/([^/]+)$';
			$isEndingWithCimiId | Should Be $true;
			$cimiId = [Guid]::Parse($Matches[1]); 
			$cimiId -is [Guid] | Should Be $true;
			
			# assert machine is not in ERROR state
			$machineBeforeAddingServiceNet.State | Should Not Be 'ERROR';

			# set new management level
			$machineProperties = New-Object biz.dfch.CS.Cimi.Client.MachineProperties($machineBeforeAddingServiceNet);
			$machineProperties | Should Not Be $null;
			$machineProperties.ManagementLevel = $expectedNewManagementLevel;
			
			# update machine
			$machineAfterAddingServiceNet = $Global:cimiClient.UpdateMachine($machineBeforeAddingServiceNet.Id, $machineProperties, 16, 100, 1800000);
			$machineAfterAddingServiceNet | Should Not Be $null;
			$machineAfterAddingServiceNet -is [IO.Swagger.Model.Machine] | Should Be $true;


			# set new management level
			$machineProperties = New-Object biz.dfch.CS.Cimi.Client.MachineProperties($machineBeforeAddingServiceNet);
			$machineProperties | Should Not Be $null;

			# assert current servicenet tags
			$machineProperties.ServiceNetTags | Should Be $null;

			# add new servicene tag
			$machineProperties.ServiceNetTags = New-Object System.Collections.Generic.List[string]
			$machineProperties.ServiceNetTags.Add("test-42");
			
			# update machine
			{ $Global:cimiClient.UpdateMachine($machineBeforeAddingServiceNet.Id, $machineProperties, 16, 100, 1800000) } | Should Throw;
		}
	}
}

Describe -Tags "ServiceNetwork-Remove.Tests" "ServiceNetwork-Remove.Tests" {

	Mock Export-ModuleMember { return $null; }

	Context "ServiceNetwork-Remove" {
	
		# Context wide constants
		# N/A
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-ApcServer;
		}

		It "CimiClientLogin-Succeeds" -Test {
		
			$Global:cimiClient = Enter-CimiServer;
		
		}

		It "ServiceNetwork-Remove" -TestCases $testCases -Test {

			param($MachineName)

			$expectedInitialManagementLevel = 'full';
			$expectedNewManagementLevel = 'unmanaged';

			# get machines
			$machinesCollection = $Global:cimiClient.GetMachineCollection($null);
			$machinesCollection | Should Not Be $null;
			$machinesCollection.Machines | Should Not Be $null;
			$machinesCollection.Machines.Count | Should Not Be 0;

			# select machine
			$machineBeforeRemovingServiceNet = $machinesCollection.Machines |? Name -eq $MachineName;
			$machineBeforeRemovingServiceNet | Should Not Be $null;
			$machineBeforeRemovingServiceNet -is [IO.Swagger.Model.Machine] | Should Be $true;

			# show MachineID
			Write-Warning ($machineBeforeRemovingServiceNet.Id);

			# assert machine is not in ERROR state
			$machineBeforeRemovingServiceNet.State | Should Not Be 'ERROR';

			# get current number of NICs
			$networkInterfaceCountBeforeRemoving = $machineBeforeRemovingServiceNet.NetworkInterfaces.Count;

			# assert current management level
			$property = $machineBeforeRemovingServiceNet.Properties |? Key -eq 'managementLevel' | Select Value;
			$property | Should Not Be $null;
			$property.Value | Should Be $expectedInitialManagementLevel;

			# set new management level
			$machineProperties = New-Object biz.dfch.CS.Cimi.Client.MachineProperties($machineBeforeRemovingServiceNet);
			$machineProperties | Should Not Be $null;
			$machineProperties.ManagementLevel = $expectedNewManagementLevel;
			
			# update machine
			$machineAfterRemovingServiceNet = $cimiClient.UpdateMachine($machineBeforeRemovingServiceNet.Id, $machineProperties, 16, 100, 1800000);
			$machineAfterRemovingServiceNet | Should Not Be $null;
			$machineAfterRemovingServiceNet -is [IO.Swagger.Model.Machine] | Should Be $true;

			# assert current number of NICs
			$networkInterfaceCountAfterRemoving = $machineAfterRemovingServiceNet.NetworkInterfaces.Count;
			$networkInterfaceCountAfterRemoving | Should Be ($networkInterfaceCountBeforeRemoving -1);

			# assert current management level
			$property = $machineAfterRemovingServiceNet.Properties |? Key -eq 'managementLevel' | Select Value;
			$property | Should Not Be $null;
			$property.Value | Should Be $expectedNewManagementLevel;
		}
	}
}

#
# Copyright 2015-2016 d-fens GmbH
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
