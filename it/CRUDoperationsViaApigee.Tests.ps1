$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "CRUDoperationsViaApigee.Tests" "CRUDoperationsViaApigee.Tests" {

	Mock Export-ModuleMember { return $null; }

	Context "#CLOUDTCL-1873-CRUDoperationsViaApigee" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			
			$svc = Enter-Apc;
			$apiBrokerBaseUrl = Get-ApcManagementUri -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.BaseUrl' -ValueOnly -svc $svc;

			# Load information for creation of service reference for communication via Apigee
			$oAuthAccessToken = Get-ApcManagementCredential -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.AccessToken' -svc $svc;
			$oAuthCredential = New-Object System.Net.NetworkCredential('[AuthorisationBaererUser]', $oAuthAccessToken.Password);
			Contract-Assert(!!$oAuthCredential);
			$tenant = $svc.Core.Tenants.AddQueryOption('$filter', "Name eq 'Managed Service Tenant'") | Select
			Contract-Assert(!!$tenant);

			# Create service reference for communication via Apigee
			$svcViaApigee = Enter-Apc -ServerBaseUri $apiBrokerBaseUrl -BaseUrl '/v1/camp/' -Credential $oAuthCredential;
			$svcViaApigee.Core.TenantHeaderName = 'Tenant-Id';
			$svcViaApigee.Core.TenantID = $tenant.ExternalId;
		}
		
		It "GetEntityKindViaApigee" -Test {
			# Arrange
			
			# Act
			$entityKinds = $svcViaApigee.Core.EntityKinds;
			
			# Assert
			$entityKinds | Should Not Be $null;
			$entityKinds.Count | Should Not Be 0;
		}
		
		It "PostAndDeleteEntityKindViaApigee" -Test {
			# Arrange
			$entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
			$entityKind.Version = 'Arbitrary.Version-{0}' -f [guid]::NewGuid();
			$entityKind.Name = $entityKind.Version;
			$entityKind.Parameters = '{"InitialState-Initialise":"ArbitraryState"}';

			# Act
			$svcViaApigee.Core.AddToEntityKinds($entityKind);
			$creationResult = $svcViaApigee.Core.SaveChanges();
			
			# Assert
			$creationResult | Should Not Be $null;
			$creationResult.StatusCode | Should Be 201;
			
			$deletionResult = Remove-ApcEntity -InputObject $entityKind -svc $svcViaApigee -Confirm:$false;
			$deletionResult | Should Not Be $null;
			$deletionResult.StatusCode | Should Be 204;
		}
		
		It "MergeEntityKindViaApigee" -Test {
			# Arrange
			$entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
			$entityKind.Version = 'Arbitrary.Version-{0}' -f [guid]::NewGuid();
			$entityKind.Name = $entityKind.Version;
			$entityKind.Parameters = '{"InitialState-Initialise":"ArbitraryState"}';

			# Act
			$svcViaApigee.Core.AddToEntityKinds($entityKind);
			$creationResult = $svcViaApigee.Core.SaveChanges();
			
			# Assert
			$creationResult | Should Not Be $null;
			$creationResult.StatusCode | Should Be 201;
			
			try
			{
				$entityKind.Name = 'Another.Name';
				$svcViaApigee.Core.UpdateObject($entityKind);
				$svcViaApigee.Core.SaveChanges();
			}
			finally
			{
				$null = Remove-ApcEntity -InputObject $entityKind -svc $svcViaApigee -Confirm:$false;
			}
		}
		
		It "PutEntityKindViaApigee" -Test {
			# Arrange
			$svcViaApigee.Core.SaveChangesDefaultOptions = [System.Data.Services.Client.SaveChangesOptions]::ReplaceOnUpdate;
			
			$entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
			$entityKind.Version = 'Arbitrary.Version-{0}' -f [guid]::NewGuid();
			$entityKind.Name = $entityKind.Version;
			$entityKind.Parameters = '{"InitialState-Initialise":"ArbitraryState"}';

			# Act
			$svcViaApigee.Core.AddToEntityKinds($entityKind);
			$creationResult = $svcViaApigee.Core.SaveChanges();
			
			# Assert
			$creationResult | Should Not Be $null;
			$creationResult.StatusCode | Should Be 201;
			
			try
			{
				$entityKind.Name = 'Another.Name';
				$svcViaApigee.Core.UpdateObject($entityKind);
				$svcViaApigee.Core.SaveChanges();
			}
			finally
			{
				$null = Remove-ApcEntity -InputObject $entityKind -svc $svcViaApigee -Confirm:$false;
			}
		}
		
		It "PatchEntityKindViaApigee" -Test {
			# Arrange
			$svcViaApigee.Core.SaveChangesDefaultOptions = [System.Data.Services.Client.SaveChangesOptions]::PatchOnUpdate;
			
			$entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
			$entityKind.Version = 'Arbitrary.Version-{0}' -f [guid]::NewGuid();
			$entityKind.Name = $entityKind.Version;
			$entityKind.Parameters = '{"InitialState-Initialise":"ArbitraryState"}';

			# Act
			$svcViaApigee.Core.AddToEntityKinds($entityKind);
			$creationResult = $svcViaApigee.Core.SaveChanges();
			
			# Assert
			$creationResult | Should Not Be $null;
			$creationResult.StatusCode | Should Be 201;
			
			try
			{
				$entityKind.Name = 'Another.Name';
				$svcViaApigee.Core.UpdateObject($entityKind);
				$svcViaApigee.Core.SaveChanges();
			}
			finally
			{
				$null = Remove-ApcEntity -InputObject $entityKind -svc $svcViaApigee -Confirm:$false;
			}
		}
		
		It "BatchUpdateEntityKindViaApigee" -Test {
			# Arrange
			$svcViaApigee.Core.SaveChangesDefaultOptions = [System.Data.Services.Client.SaveChangesOptions]::Batch;
			
			$entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
			$entityKind.Version = 'Arbitrary.Version-{0}' -f [guid]::NewGuid();
			$entityKind.Name = $entityKind.Version;
			$entityKind.Parameters = '{"InitialState-Initialise":"ArbitraryState"}';

			# Act
			$svcViaApigee.Core.AddToEntityKinds($entityKind);
			$creationResult = $svcViaApigee.Core.SaveChanges();
			
			# Assert
			$creationResult | Should Not Be $null;
			$creationResult.StatusCode | Should Be 201;
			
			try
			{
				$entityKind.Name = 'Another.Name';
				$svcViaApigee.Core.UpdateObject($entityKind);
				$svcViaApigee.Core.SaveChanges();
			}
			finally
			{
				$null = Remove-ApcEntity -InputObject $entityKind -svc $svcViaApigee -Confirm:$false;
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