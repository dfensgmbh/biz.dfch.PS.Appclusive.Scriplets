#Requires -Modules 'biz.dfch.PS.Appclusive.Client'

PARAM
(
	# Id of the Abiquo instance
	[Parameter(Mandatory = $true, Position = 0)]
	[ValidateNotNullOrEmpty()]
	[string] $InstanceIdentifier
)

$svc = Enter-ApcServer;
$knvKey = "com.abiquo.cms.osTypeNetworkMapping.{0}" -f $InstanceIdentifier;

# Mapping of OS types to network names (Delimiter: '|')
# The OS types listed here represent the OS types of
# the OsTypeEnum in biz.dfch.CS.Abiquo.Client
$osTypeToNetworkNameMappings = @{
	"OTHER" = "";
	"MACOS" = "";
	"SOLARIS" = "";
	"LINUX" = "BlueNetSAPLnx0001|BlueNetSAPLnx0002";
	"FREEBSD" = "";
	"NETBSD" = "";
	"OPENBSD" = "";
	"NOT_APPLICABLE" = "";
	"WINDOWS" = "BlueNetSAPWin0001|BlueNetSAPWin0002";
	"WINDOWS_SERVER_2003" = "";
	"WINDOWS_SERVER_2003_64" = "";
	"WINDOWS_SERVER_2008" = "BlueNetSAPWin0001|BlueNetSAPWin0002";
	"WINDOWS_SERVER_2008_64" = "BlueNetSAPWin0001|BlueNetSAPWin0002";
	"FREEBSD_64" = "";
	"RHEL" = "BlueNetSAPLnx0001|BlueNetSAPLnx0002";
	"RHEL_64" = "BlueNetSAPLnx0001|BlueNetSAPLnx0002";
	"SOLARIS_64" = "";
	"SUSE" = "";
	"SUSE_64" = "";
	"SLES" = "BlueNetSAPLnx0001|BlueNetSAPLnx0002";
	"SLES_64" = "BlueNetSAPLnx0001|BlueNetSAPLnx0002";
	"NOVELL_OES" = "";
	"MANDRIVA" = "";
	"MANDRIVA_64" = "";
	"TURBOLINUX" = "";
	"TURBOLINUX_64" = "";
	"UBUNTU" = "";
	"UBUNTU_64" = "";
	"DEBIAN" = "";
	"DEBIAN_64" = "";
	"LINUX_2_4" = "";
	"LINUX_2_4_64" = "";
	"LINUX_2_6" = "";
	"LINUX_2_6_64" = "";
	"LINUX_64" = "Bluenet Linux|Bluenet Unix";
	"OTHER_64" = "";
	"WINDOWS_SERVER_2008_R2" = "BlueNetSAPWin0001|BlueNetSAPWin0002";
	"ESXI" = "";
	"WINDOWS_7" = "";
	"CENTOS" = "";
	"CENTOS_64" = "";
	"ORACLE_ENTERPRISE_LINUX" = "";
	"ORACLE_ENTERPRISE_LINUX_64" = "";
	"ECOMSTATION_32" = "";
	"WINDOWS_SERVER_2011" = "";
	"WINDOWS_SERVER_2012" = "BlueNetSAPWin0001|BlueNetSAPWin0002";
	"WINDOWS_8" = "";
	"WINDOWS_8_64" = "";
	"UNRECOGNIZED" = "";
}

foreach ($osTypeToNetworkNameMapping in $osTypeToNetworkNameMappings.GetEnumerator())
{
	if (!$osTypeToNetworkNameMapping.Value)
	{
		continue;
	}

	foreach($network in $osTypeToNetworkNameMapping.Value.Trim('|').Split('|'))
	{
		Set-ApcKeyNameValue -svc $svc -Key $knvKey -Name $osTypeToNetworkNameMapping.Name -Value $network -CreateIfNotExist;
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
