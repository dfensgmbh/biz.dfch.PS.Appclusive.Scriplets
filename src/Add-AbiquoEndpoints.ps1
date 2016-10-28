#Requires -Modules 'biz.dfch.PS.Appclusive.Client'

PARAM
(
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[string] $InstanceIdentifier
	,
	[Parameter(Mandatory = $true, Position = 1)]
	[uri] $AbiquoApiBaseUri
	,
	[Parameter(Mandatory = $true, Position = 2)]
	[ValidateNotNullOrEmpty()]
	[string] $OAuth2Username
	,
	[Parameter(Mandatory = $true, Position = 3)]
	[ValidateNotNullOrEmpty()]
	[string] $OAuth2AccessToken
	,
	[Parameter(Mandatory = $true, Position = 4)]
	[ValidateNotNullOrEmpty()]
	[string] $OAuth2AccessRefreshToken
	,
	[Parameter(Mandatory = $true, Position = 5)]
	[uri] $SSOApiBaseUri
	,
	[Parameter(Mandatory = $true, Position = 6)]
	[ValidateNotNullOrEmpty()]
	[string] $ManagedServicesDnsSuffix
)

$abiquoApiMgmtUriName = "com.abiquo.{0}.endpoint" -f $InstanceIdentifier;
$ssoApiMgmtUriName = "com.abiquo.{0}.sso" -f $InstanceIdentifier;
$dnsSuffixKnvKey = "com.abiquo.{0}" -f $InstanceIdentifier;
$dnsSuffixKnvName = "ManagedServicesDnsSuffix";


$svc = Enter-ApcServer;

# Create ManagementCredential for Abiquo API communication
$mgmtCredential = Get-ApcManagementCredential -Name $abiquoApiMgmtUriName -Svc $svc;
Contract-Assert (!$mgmtCredential);
$mgmtCredential = New-ApcManagementCredential -Name $abiquoApiMgmtUriName -Username $OAuth2Username -Password $OAuth2AccessToken -Description 'Instance specific API credential' -svc $svc

# Create ManagementUri for Abiquo API communication
$mgmtUri = Get-ApcManagementUri -Name $abiquoApiMgmtUriName -svc $svc;
Contract-Assert(!$mgmtUri);
$null = New-ApcManagementUri -Name $abiquoApiMgmtUriName -Type 'uri' -Value $AbiquoApiBaseUri.AbsoluteUri -ManagementCredentialId $mgmtCredential.Id -Description 'Instance specific API base URI' -svc $svc

# Create ManagementCredential for SSO communication
$mgmtCredential = Get-ApcManagementCredential -Name $ssoApiMgmtUriName -Svc $svc;
Contract-Assert (!$mgmtCredential);
$mgmtCredential = New-ApcManagementCredential -Name $ssoApiMgmtUriName -Username $OAuth2Username -Password $OAuth2AccessRefreshToken -Description 'Instance specific SSO credential' -svc $svc

# Create ManagementUri for SSO communication
$mgmtUri = Get-ApcManagementUri -Name $ssoApiMgmtUriName -svc $svc;
Contract-Assert(!$mgmtUri);
$null = New-ApcManagementUri -Name $ssoApiMgmtUriName -Type 'uri' -Value $SSOApiBaseUri.AbsoluteUri -ManagementCredentialId $mgmtCredential.Id -Description 'Instance specific SSO base URI' -svc $svc

$null = Set-ApcKeyNameValue -svc $svc -Key $dnsSuffixKnvKey -Name $dnsSuffixKnvName -Value $ManagedServicesDnsSuffix -CreateIfNotExist;

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
