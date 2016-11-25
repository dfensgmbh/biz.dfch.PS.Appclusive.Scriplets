$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Appclusive.Tests" "Appclusive.Tests" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"
	
	Context "RedmineTest" {
	
		BeforeEach {

			$svc = Enter-Apc -Credential $cred;
		}


		It "RequestingSystemRootNodeViaSystemTenantUserSucceeds" -Test {
	
			# Arrange
			$svc = Enter-Apc -Credential $cred;
		
			# Act
			$q = 'Id eq 1';
			$result = $svc.Core.Nodes.AddQueryOption('$filter', $q) | Select;

			# Assert
			$result | Should Not Be $null;
			$result.Id | Should Be 1;
			$result.Tid | Should Be '11111111-1111-1111-1111-111111111111'
		}

		It "RequestingNodesReturnsPageSize" -Test {
	
			# Arrange
			$pageSize = 45;

			$svc = Enter-Apc -Credential $cred;
		
			# Act
			$result = $svc.Core.Nodes | Select;

			# Assert
			$result | Should Not Be $null;
			$result.Count | Should Be $pageSize;
		}

		# It "RequestingSystemRootNodeViaOtherTenantUserFails" -Test {
	
			# # Arrange
			# $cred = "OtherUser"
			# $svc = Enter-Apc -Credential $cred;
		
			# # Act
			# $q = 'Id eq 1';
			# $result = $svc.Core.Nodes.AddQueryOption('$filter', $q) | Select;

			# # Assert
			# $result | Should Be $null;
		# }

		It "RequestingSystemRootNodeWithInvalidCredentialsFails" -Test {
	
			# Arrange
			$username = "arbitrary-domain\invalid-user";
			$password = "invalid-password" | ConvertTo-SecureString -asPlainText -Force;
			$cred = New-Object System.Management.Automation.PSCredential($username, $password);

			$svc = Enter-Apc -Credential $cred;
		
			# Act
			# { Test-ApcStatus -Authenticate } | Should Throw;
			Test-ApcStatus -Authenticate;

			# Assert
			# N/A
		}

		# It "RequestingIncidentsViaAppclusiveApiShouldSucceed" -Test {
	
			# # Arrange
			# $svc = Enter-Apc -Credential $cred;
		
			# # Act, Assert
			# $svc.Csm.Incidents | Should Not Throw;
		# }
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
