#Requires -Modules 'biz.dfch.PS.Appclusive.Client'

PARAM
(
	# Stack Id (Equal to the "iss" property of the JWT token)
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $stackIdentifier
	,
	# Stack specific API base URI
	[Parameter(Mandatory = $true, Position = 1)]
	[uri] $abiquoApiBaseUri
	,
	[Parameter(Mandatory = $true, Position = 2)]
	[string] $abiquoApiUsername
	,
	[Parameter(Mandatory = $true, Position = 1)]
	[string] $abiquoApiPassword
)
Contract-Assert (!!$stackIdentifier);
Contract-Assert (![string]::IsNullOrWhiteSpace($stackIdentifier));

$connectionInfoName = "com.abiquo.cms.api.{0}" -f $stackIdentifier;

$svc = Enter-ApcServer;

# Create ManagementCredential
$credential = Get-ApcManagementCredential -Name $Name -Svc $svc;
Contract-Assert (!$mgmtCredential);

$credential = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementCredential;
$credential.Name = $connectionInfoName;
$credential.Description = 'Stack specific API credential';
$credential.Username = $abiquoApiUsername;
$credential.Password = $abiquoApiPassword;
$credential.EncryptedPassword = $credential.Password;
		
$svc.Core.AddToManagementCredentials($credential);
$null = $svc.Core.SaveChanges();

# Create ManagementUri
$mgmtUri = Get-ApcManagementUri -svc $svc -Name $Name;

Contract-Assert(!$mgmtUri);

$mgmtUri = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementUri;
$mgmtUri.Name = $Name;
$mgmtUri.Description = 'Stack specific API base URI';
$mgmtUri.Type = 'uri';
$mgmtUri.Value = $abiquoApiBaseUri.AbsoluteUri;
$mgmtUri.ManagementCredentialId = $mc.Id;
	
$svc.Core.AddToManagementUris($mgmtUri);
$null = $svc.Core.SaveChanges();

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
