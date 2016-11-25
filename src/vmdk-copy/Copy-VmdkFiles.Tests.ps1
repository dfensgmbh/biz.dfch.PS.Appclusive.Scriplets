
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Describe -Tags "Copy-VmdkFiles.Tests" "Copy-VmdkFiles.Tests" {

	$configuration = @{
		"Server" = "arbitrary-server";
	}
	
	Mock Export-ModuleMember { return $null; }
	
	# we define these pseudo function 
	# to mock the BEGIN/PROCESS/END block in the sut
	function BEGIN() { <# do nothing #> }
	function PROCESS() { <# do nothing #> }
	function END() { <# do nothing #> }
	
	. "$here\$sut" -ConfigurationFile 'C:\Github\biz.dfch.PS.Appclusive.Scriplets\src\vmdk-copy\Copy-VmdkFiles.xml';
	
	Context "Enter-vCenter" {
	
		# we have to define this stub before mocking, 
		# otherwise Mock will not find the original function to overload
		# because the snapin is not already loaded
		function Connect-VIServer() { };
		$script:isConnectVIServerCalled = $false;
		Mock Connect-VIServer { $script:isConnectVIServerCalled = $true; return @{"Server" = $configuration.Server; } };

		# Context wide constants
		# N/A
		
		It "Enter-vCenter-Succeeds" -Test {
		
			# Arrange
			$server = $configuration.Server;
			
			# Act
			$result = Enter-vCenter -Server $server;
			
			# Assert
			$script:isConnectVIServerCalled | Should Be $true;
			$result | Should Not Be $null;
			$result.Server | Should Be $server;
		}
		
		It "Enter-vCenter-WithEmtpyName-Throws" -Test {
		
			# Arrange
			$Server = '';
			
			# Act
			{ $result = Enter-vCenter -Server $Server; } | Should Throw;
			
			# Assert
			# N/A
		}
	}
	
	Context "Exit-vCenter" {

		function Disconnect-VIServer() { };
		$script:isDisconnectVIServerCalled = $false;
		Mock Disconnect-VIServer { $script:isDisconnectVIServerCalled = $true; return; };

		# Context wide constants
		# N/A
		
		It "Exit-vCenter-Succeeds" -Test {
		
			# Arrange
			$server = $configuration.Server;
			
			# Act
			$result = Exit-vCenter -Server $Server;
			
			# Assert
			$script:isDisconnectVIServerCalled | Should Be $true;
			$snapins = Get-PSSnapin -Name VMWare* -ErrorAction:SilentlyContinue;
			$snapins | Should Be $null;
		}
	}

	Context "Exit-vCenterWithErrors" {

		function Disconnect-VIServer() { };
		$script:isDisconnectVIServerCalled = $false;
		Mock Disconnect-VIServer { $script:isDisconnectVIServerCalled = $true; throw; };

		# Context wide constants
		# N/A
		
		# It "Exit-vCenter-Throws" -Test {
		
			# # Arrange
			# $server = $configuration.Server;
			
			# # Act
			# $result = Exit-vCenter -Server $Server;
			
			# # Assert
			# $script:isDisconnectVIServerCalled | Should Be $true;
			# $snapins = Get-PSSnapin -Name VMWare* -ErrorAction:SilentlyContinue;
			# $snapins | Should Be $null;
		# }
	}
	
	Context "ProcessMasterVms" {
	
		AfterEach {
			Remove-PSDrive SourceDs
		}
		
		$ConfigurationFileName = @{BackupFolder = 'Z:\SOFTWARE'; TimespanDifferenceMinutes = 60; }
		
		$VmPathName = "[Datastore] Folder1/VM01.vmx";
		$Files = @{ 'VmPathName' = $VmPathName}
		$Config = @{ 'Files' = $Files}
		$ExtensionData = @{ 'Config' = $Config}
		$mockedVM = @{ 'ExtensionData' = $ExtensionData; 'PowerState' = 'PoweredOff' }
		
		function Get-VM {}
		Mock Get-VM { return $mockedVM; };

		$dataStore = "arbitrary-dataStore";
		function Get-Datastore {}
		Mock Get-Datastore { return $dataStore; };
		
		if(!(Get-PSDrive 'SourceDs' -ErrorAction:SilentlyContinue))
		{
			$psDrive = New-PSDrive -Name 'SourceDs' -Root $ENV:TEMP -PSProvider FileSystem;
		}
		
		function New-PSDrive {}
		Mock New-PSDrive { return; }
		
		function Remove-PSDrive {}
		Mock Remove-PSDrive { return; }

		function Copy-DatastoreItem {}
		Mock Copy-DatastoreItem { PARAM($Item, $Destination) Log-Debug 'Copy-DatastoreItem' ("{0} -- > {1}" -f $item, $Destination); }
		
		It "ProcessMasterVms" -Test {
		
			ProcessMasterVms @("VM1", "VM2");
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
