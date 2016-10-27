#Requires -Modules 'biz.dfch.PS.Appclusive.Client'

PARAM
(
	# Stack Id (Equal to the "iss" property of the JWT token)
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $StackIdentifier
	,
	# Stack specific API base URI
	[Parameter(Mandatory = $true, Position = 1)]
	[uri] $AbiquoApiBaseUri
	,
	[Parameter(Mandatory = $true, Position = 2)]
	[string] $AbiquoApiToken
	,
	[Parameter(Mandatory = $false)]
	[string] $AbiquoApiUsername = "None"
)
Contract-Assert (!!$StackIdentifier);
Contract-Assert (![string]::IsNullOrWhiteSpace($StackIdentifier));

$connectionInfoName = "com.abiquo.cms.api.{0}" -f $StackIdentifier;

$svc = Enter-ApcServer;

# Create ManagementCredential
$mgmtCredential = Get-ApcManagementCredential -Name $connectionInfoName -Svc $svc;
Contract-Assert (!$mgmtCredential);

$mgmtCredential = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementCredential;
$mgmtCredential.Name = $connectionInfoName;
$mgmtCredential.Description = 'Stack specific API credential';
$mgmtCredential.Username = $AbiquoApiUsername;
$mgmtCredential.Password = $AbiquoApiToken;
$mgmtCredential.EncryptedPassword = $mgmtCredential.Password;
		
$svc.Core.AddToManagementCredentials($mgmtCredential);
$null = $svc.Core.SaveChanges();

# Create ManagementUri
$mgmtUri = Get-ApcManagementUri -svc $svc -Name $connectionInfoName;

Contract-Assert(!$mgmtUri);

$mgmtUri = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementUri;
$mgmtUri.Name = $connectionInfoName;
$mgmtUri.Description = 'Stack specific API base URI';
$mgmtUri.Type = 'uri';
$mgmtUri.Value = $AbiquoApiBaseUri.AbsoluteUri;
$mgmtUri.ManagementCredentialId = $mgmtCredential.Id;
	
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
