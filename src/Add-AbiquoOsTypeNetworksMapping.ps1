PARAM
(
	# Stack Id (Equal to the "iss" property of the JWT token)
	[Parameter(Mandatory = $true)]
	[string] $stackIdentifier
	,
	# Abiquo OS type
	[Parameter(Mandatory = $true)]
	[string] $osType
	,
	# Comma separated list of network Ids for the correspoding OS type
	[Parameter(Mandatory = $true)]
	[string] $networkIds
)
Contract-Assert (!!$stackIdentifier);
Contract-Assert (!!$osType);
Contract-Assert (!!$networkIds);

$svc = Enter-ApcServer;
$knvKeyTemplate = "com.abiquo.cms.osTypeNetworkMapping.{0}";

function CreateAndPersistKeyNameValueIfNotExists($svc, $Key, $Name, $Value)
{
	$knv = Get-ApcKeyNameValue -svc $svc -Key $Key -Name $Name;
	
	if (!$knv)
	{
		New-ApcKeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value;
		
		$msg = "Adding Abiquo OS type <-> network mapping with name '$Name' SUCCEEDED" -f $Name;
		Write-Host -ForegroundColor Green $msg;
	}
	else
	{
		$msg = "Abiquo OS type <-> network mapping with name '$Name' already exists" -f $Name;
		Write-Host -ForegroundColor Yellow $msg;
	}
}

$knvKey = $knvKeyTemplate -f $stackIdentifier;
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $knvKey -Name $osType -Value $networkIds;

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
