#Requires -Modules 'biz.dfch.PS.Appclusive.Client'

PARAM
(
	# Stack Id (Equal to the "iss" property of the JWT token)
	[Parameter(Mandatory = $true)]
	[string] $stackIdentifier
)
Contract-Assert (!!$stackIdentifier);

$svc = Enter-ApcServer;
$knvKey = "com.abiquo.cms.osTypeNetworkMapping.{0}" -f $stackIdentifier;

# Mapping of OS types to network names (Delimiter: '|')
$osTypeToNetworkNameMapping = @{
	"OTHER" = "Bluenet Linux|Bluenet Unix";
	"MACOS" = "";
	"SOLARIS" = "";
	"LINUX" = "";
	"FREEBSD" = "";
	"NETBSD" = "";
	"OPENBSD" = "";
	"NOT_APPLICABLE" = "";
	"WINDOWS" = "Bluenet Windows";
	"WINDOWS_SERVER_2003" = "Bluenet Windows";
	"WINDOWS_SERVER_2003_64" = "Bluenet Windows";
	"WINDOWS_SERVER_2008" = "Bluenet Windows";
	"WINDOWS_SERVER_2008_64" = "Bluenet Windows";
	"FREEBSD_64" = "";
	"RHEL" = "";
	"RHEL_64" = "";
	"SOLARIS_64" = "";
	"SUSE" = "";
	"SUSE_64" = "";
	"SLES" = "";
	"SLES_64" = "";
	"NOVELL_OES" = "";
	"MANDRIVA" = "";
	"MANDRIVA_64" = "";
	"TURBOLINUX" = "";
	"TURBOLINUX_64" = "";
	"UBUNTU" = "";
	"UBUNTU_64" = "";
	"DEBIAN" = "";
	"DEBIAN_64" = "";
	"LINUX_2_4" = "Bluenet Linux";
	"LINUX_2_4_64" = "Bluenet Linux";
	"LINUX_2_6" = "Bluenet Linux";
	"LINUX_2_6_64" = "Bluenet Linux";
	"LINUX_64" = "Bluenet Linux";
	"OTHER_64" = "";
	"WINDOWS_SERVER_2008_R2" = "Bluenet Windows";
	"ESXI" = "";
	"WINDOWS_7" = "Bluenet Windows";
	"CENTOS" = "";
	"CENTOS_64" = "";
	"ORACLE_ENTERPRISE_LINUX" = "";
	"ORACLE_ENTERPRISE_LINUX_64" = "";
	"ECOMSTATION_32" = "";
	"WINDOWS_SERVER_2011" = "Bluenet Windows";
	"WINDOWS_SERVER_2012" = "Bluenet Windows";
	"WINDOWS_8" = "Bluenet Windows";
	"WINDOWS_8_64" = "Bluenet Windows";
	"UNRECOGNIZED" = "";
}

function CreateAndPersistKeyNameValueIfNotExists($svc, $Key, $Name, $Value)
{
	$knv = Get-ApcKeyNameValue -svc $svc -Key $Key -Name $Name;
	
	if (!$knv)
	{
		$null = New-ApcKeyNameValue -svc $svc -Key $Key -Name $Name -Value $Value;
		
		$msg = "Adding KNV entry for Abiquo OS type <-> network mapping with name '{0}' SUCCEEDED" -f $Name;
		Write-Host -ForegroundColor Green $msg;
	}
	else
	{
		$msg = "KNV entry for Abiquo OS type <-> network mapping with name '{0}' already exists" -f $Name;
		Write-Host -ForegroundColor Yellow $msg;
	}
}

foreach ($item in $osTypeToNetworkNameMapping.GetEnumerator())
{
	if ($item.Value)
	{
		CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $knvKey -Name $item.Name -Value $item.Value;
	}
	else
	{
		$msg = "Adding KNV entry for Abiquo OS type <-> network mapping with name '{0}' FAILED (No network name(s) provided)" -f $item.Name;
		Write-Host -ForegroundColor Yellow $msg;
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
