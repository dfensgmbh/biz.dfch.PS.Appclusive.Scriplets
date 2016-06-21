#requires -Modules 'biz.dfch.PS.Appclusive.Client'

function Enter-CimiServer {
[CmdletBinding(
    SupportsShouldProcess = $true
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Scripts/Enter-CimiServer/'
)]
Param
(
	[Parameter(Mandatory = $false, Position = 0)]
	[long] $UserId = 31
	,
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string] $CmpBaseUrlManagementUriName = 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.BaseUrl'
	,
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[string] $OAuth2BaseUrlManagementUriName = 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.OAuth2BaseUrl'
	,
	[Parameter(Mandatory = $false)]
	[string] $CimiClientAssemblyFileAndPathName = 'C:\Program Files\WindowsPowerShell\Modules\CimiClient\biz.dfch.CS.Cimi.Client.dll'
	,
	[Parameter(Mandatory = $false)]
	[hashtable] $svc = $biz_dfch_PS_Appclusive_Client.Services
)

	trap { Log-Exception $_; break; }
	
	Contract-Requires (0 -lt $UserId)
	Contract-Requires (Test-Path -Path $CimiClientAssemblyFileAndPathName)
	Contract-Requires ($biz_dfch_PS_Appclusive_Client.Services -is [hashtable])
	Contract-Requires ($biz_dfch_PS_Appclusive_Client.Services.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core])
	Contract-Requires ($biz_dfch_PS_Appclusive_Client.Services.Diagnostics -is [biz.dfch.CS.Appclusive.Api.Diagnostics.Diagnostics])
	
	$query = "Name eq '{0}'" -f $CmpBaseUrlManagementUriName;
	$cmpBaseUrl = $svc.Core.ManagementUris.AddQueryOption('$filter', $query) | Select;
	Contract-Assert ($null -ne $cmpBaseUrl)
	Contract-Assert (0 -lt $cmpBaseUrl.ManagementCredentialId)
	
	$accessRefreshTokenCred = Get-ApcManagementCredential -Id $cmpBaseUrl.ManagementCredentialId | Select;
	Contract-Assert ($null -ne $accessRefreshTokenCred)

	$query = "Name eq '{0}'" -f $OAuth2BaseUrlManagementUriName;
	$oAuth2BaseUrl = $svc.Core.ManagementUris.AddQueryOption('$filter', $query) | Select;
	Contract-Assert ($null -ne $oAuth2BaseUrl)
	Contract-Assert (0 -lt $oAuth2BaseUrl.ManagementCredentialId)

	$oAuth2BaseUrlMgmtCred = Get-ApcManagementCredential -Id  $oAuth2BaseUrl.ManagementCredentialId;
	Contract-Assert ($null -ne $oAuth2BaseUrlMgmtCred)

	# $tid = Get-ApcKeyNameValue -Key 'biz.dfch.CS.Appclusive.Core.Scs.Cmp' -Name 'tenantId';
	# $tenantId = $tid.Value;
	# $tenantId = '11111111-1111-1111-1111-111111111111';
	
	$user = $svc.core.Users.AddQueryOption('$filter', ('Id eq {0}' -f $UserId)).AddQueryOption('$expand', 'Tenant') | Select;
	Contract-Assert(![string]::IsNullOrWhiteSpace($user.Tid))

	$tenant = $svc.Core.Tenants.AddQueryOption('$filter', ("Id eq guid'{0}'" -f $user.Tid)) | Select;
	Contract-Assert(![string]::IsNullOrWhiteSpace($tenant.ExternalId))

	$tenantId = $tenant.ExternalId;
	# $tenantId = 'e68fd729-80d5-4b56-b850-d27009095061'
	
	Add-Type -Path $CimiClientAssemblyFileAndPathName;
	
	$Global:cimiClient = New-Object biz.dfch.CS.Cimi.Client.v2.CimiClient;

	# Act
	$cloudEntryPoint = $Global:cimiClient.Login($oAuth2BaseUrl.Value, $oAuth2BaseUrlMgmtCred.Username, $oAuth2BaseUrlMgmtCred.Password, $accessRefreshTokenCred.Password, $cmpBaseUrl.Value, $tenantId, 3, 100);

	# Assert
	Contract-Assert ($cloudEntryPoint -is [IO.Swagger.Model.CloudEntryPoint])
	
	return $Global:CimiClient;
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
