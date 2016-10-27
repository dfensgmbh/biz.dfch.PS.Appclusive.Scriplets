#Requires -Modules 'biz.dfch.PS.Appclusive.Client'

PARAM
(
	# Stack Id (Equal to the "iss" property of the JWT token)
	[Parameter(Mandatory = $true)]
	[string] $stackIdentifier
	,
	# Stack specific API base URI
	[Parameter(Mandatory = $true)]
	[uri] $abiquoApiBaseUri
)
Contract-Assert (!!$stackIdentifier);
Contract-Assert (![string]::IsNullOrWhiteSpace($stackIdentifier));

$mgmtUriName = "com.abiquo.cms.api.baseUri.{0}" -f $stackIdentifier;

function CreateAndPersistManagementUriIfNotExist($Name, $Description, $Type, $Value)
{
	$svc = Enter-ApcServer;
	
	$mgmtUri = Get-ApcManagementUri -svc $svc -Name $Name;

	Contract-Assert(!$mgmtUri);

	$mgmtUri = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementUri;
	$mgmtUri.Name = $Name;
	$mgmtUri.Description = $Description;
	$mgmtUri.Type = $Type;
	$mgmtUri.Value = $Value;
		
	$svc.Core.AddToManagementUris($mgmtUri);
	$null = $svc.Core.SaveChanges();
}

CreateAndPersistManagementUriIfNotExist -Name $mgmtUriName -Description 'Stack specific API base URI' -Type 'uri' -Value $abiquoApiBaseUr.AbsoluteUri;

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
