PARAM
(
	[ValidateScript( { Test-Path -Path $_ -PathType Leaf; } )]
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $InputObject
)

$config = [System.Configuration.ConfigurationManager]::OpenExeConfiguration($InputObject);
Contract-Assert (!!$config)

$config.AppSettings.Settings

# Key                     : UpdateIntervalMinutes
# Value                   : 5
# LockAttributes          : {}
# LockAllAttributesExcept : {}
# LockElements            : {}
# LockAllElementsExcept   : {}
# LockItem                : False
# ElementInformation      : System.Configuration.ElementInformation
# CurrentConfiguration    : System.Configuration.Configuration

# Key                     : ServerNotReachableRetries
# Value                   : 4
# LockAttributes          : {}
# LockAllAttributesExcept : {}
# LockElements            : {}
# LockAllElementsExcept   : {}
# LockItem                : False
# ElementInformation      : System.Configuration.ElementInformation
# CurrentConfiguration    : System.Configuration.Configuration

# Key                     : ManagementUri
# Value                   : biz.dfch.CS.Appclusive.Scheduler
# LockAttributes          : {}
# LockAllAttributesExcept : {}
# LockElements            : {}
# LockAllElementsExcept   : {}
# LockItem                : False
# ElementInformation      : System.Configuration.ElementInformation
# CurrentConfiguration    : System.Configuration.Configuration

# Key                     : Uri
# Value                   : http://appclusive/Appclusive/
# LockAttributes          : {}
# LockAllAttributesExcept : {}
# LockElements            : {}
# LockAllElementsExcept   : {}
# LockItem                : False
# ElementInformation      : System.Configuration.ElementInformation
# CurrentConfiguration    : System.Configuration.Configuration

$config.AppSettings.Settings["Uri"]

# Key                     : Uri
# Value                   : http://appclusive/Appclusive/
# LockAttributes          : {}
# LockAllAttributesExcept : {}
# LockElements            : {}
# LockAllElementsExcept   : {}
# LockItem                : False
# ElementInformation      : System.Configuration.ElementInformation
# CurrentConfiguration    : System.Configuration.Configuration


# <?xml version="1.0" encoding="utf-8"?>
# <configuration>
  # <configSections>
    # <section name="credential" type="System.Configuration.IgnoreSectionHandler" />
	# </configSections>
  # <credential>
	# <username>.\Administrator</username>
	# <password>P@ssw0rd</password>
  # </credential>
# </configuration>

$credentialSection = $config.GetSection("AppclusiveCredential")
$rawxml = $credentialSection.SectionInformation.GetRawXml()
$rawxml
<#
	<credential>
		<username>.\arbitrary-user</username>
		<password>arbitrary-password</password>
	</credential>
#>

$result = $rawxml -match '\<username\>(.+)\</username\>';
Contract.Assert($result)
$username = $Matches[1];

$result = $rawxml -match '\<password\>(.+)\</password\>';
Contract.Assert($result)
$password = $Matches[1];


$credentialSection.SectionInformation.ProtectSection
# OverloadDefinitions
# -------------------
# void ProtectSection(string protectionProvider)
$credentialSection.SectionInformation.ProtectSection("DataProtectionConfigurationProvider");
Contract-Assert ( $credentialSection.SectionInformation.IsProtected);
$credentialSection.SectionInformation.ForceSave = $true;
$config.Save([System.Configuration.ConfigurationSaveMode]::Minimal);

  # <credential configProtectionProvider="DataProtectionConfigurationProvider">
    # <EncryptedData>
      # <CipherData>
        # <CipherValue>AQAAANCMnd8BFdERjHoAwE/Cl+sBAAAAWRWlfpCmJUaTl+EQsFPK/QQAAAACAAAAAAAQZgAAAAEAACAAAABlh4Af+K5C68B/1Y3L8N+i1NAmsUdVRpkondV+ep+3OgAAAAAOgAAAAAIAACAAAADoBZcGoONJacrzX0oveKQnD+wWZnI8yTni6hq2RV+5UuAAAABRKVcLOsyYSIOs+gxxc+dbSU51l5W507grBvHzez/5VJ/cEPm80ebAy6wKJq+yVzBe2p7D9CjfSxeK7sDJX5vZnlSwQ4+O4Ctka3ygmp4rS4da5zGsi3SaaeDlmY2K6NhlpAq16AeFUGvCCJmVhPBTk/JnaQbBxtw95Q9sbpXtv1QMKwKC7ORl8oiv5xFpqcasl49bQNjN/YvWFIB0UR8kTo2ZqYlqCs91BepacqBPQB55lLc7FfQDvvRyH2tD0Ic+e3mXd/n46tXccxNQOZ+lJoqx2/t9HQlp6UwmpI8QykAAAAA6UUxXmucSeMzfZQex51zqCipf2Uf9u0W27eo/+RpHN7surWtZvFEJDlC0J89XTq7N0hIohveNqJkZCduE4SPs</CipherValue>
      # </CipherData>
    # </EncryptedData>
  # </credential>
 
if($credentialSection.SectionInformation.IsProtected)
{
	$credentialSection.SectionInformation.UnprotectSection();
	$credentialSection.SectionInformation.ForceSave = $true;
	$config.Save([System.Configuration.ConfigurationSaveMode]::Minimal);
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
