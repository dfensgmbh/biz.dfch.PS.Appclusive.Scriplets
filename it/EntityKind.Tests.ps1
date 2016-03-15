$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "EntityKind.Tests" "EntityKind.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	
	Context "#CLOUDTCL-1879-EntityKindTests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			
			$credApc = (Import-Clixml (Join-Path -Path $env:USERPROFILE -ChildPath ("appclusiveCred-{0}.xml" -f $env:USERNAME)))
			$svc = Enter-Apc -Credential $credApc;
			$apcUser = $svc.Core.Users.AddQueryOption('$filter', ("substringof('{0}', Name)" -f $credApc.UserName))
		}
		
		It "GetEntityKindsCreatedBySeed" -Test {
			# Arrange
			
			# Act
			$entityKinds = $svc.Core.EntityKinds;
			
			# Assert	
			$entityKinds | Should Not Be $null;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Job" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Ace" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Acl" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Approval" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Assoc" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Cart" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.CartItem" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Catalogue" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.CatalogueItem" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.ContractMapping" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Customer" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.EntityKind" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Gate" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.KeyNameValue" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.ManagementCredential" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.ManagementUri" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Order" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.OrderItem" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Permission" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Product" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Role" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Tenant" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.User" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.ExternalNode" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Core.Folder" | Should be $true;
			$entityKinds.Name -Contains "biz.dfch.CS.Appclusive.Core.OdataServices.Diagnostics.AuditTrail" | Should be $true;
		}
		
		It "CreateAndDeleteEntityKind-Succeeds" -Test {
			try
			{
				# Arrange
				$entityKindName = ("TestForPesterRun-{0}" -f [Guid]::NewGuid().ToString())
				$entityKindDescription = ("Test Description For Pester Run - {0}" -f [Guid]::NewGuid().ToString())
				$entityKindVersion = [Guid]::NewGuid().ToString();
				$entityKindParameters = "'{ }'"
				
				# Act
				$entityKind = CreateEntityKind -entityKindName $entityKindName -entityKindDescription $entityKindDescription -entityKindVersion $entityKindVersion
				$svc.Core.AddToEntityKinds($entityKind)
				$result = $svc.Core.SaveChanges();
				
				$entityKindCreated = $svc.Core.EntityKinds.AddQueryOption('$filter', ("Id eq {0}" -f $entityKind.Id))
				
				# Assert	
				$result.StatusCode | Should Be 201;			
				$entityKindCreated | Should Not Be $null;
				$entityKindCreated.Name | Should Be $entityKindName
				$entityKindCreated.Description | Should Be $entityKindDescription
			}
			finally
			{
				if (!$entityKind -eq $false)
				{
					#Cleanup
					$svc.Core.DeleteObject($entityKind);
					$result = $svc.Core.SaveChanges();
					$result.StatusCode | Should Be 204;
					write-warning "EntityKind deleted"
				}
			}
		}
		
		It "CreateEntityKindWithoutName-Fail" -Test {
			try
			{
				# Arrange
				$entityKindName = ("TestForPesterRun-{0}" -f [Guid]::NewGuid().ToString())
				$entityKindDescription = ("Test Description For Pester Run - {0}" -f [Guid]::NewGuid().ToString())
				$entityKindVersion = [Guid]::NewGuid().ToString();
				$entityKindParameters = "'{ }'"
				
				# Act
				$entityKind = CreateEntityKind -entityKindName $entityKindName -entityKindDescription $entityKindDescription -entityKindVersion $entityKindVersion
				$entityKind.Name = $null;
				$svc.Core.AddToEntityKinds($entityKind)
				
				# Assert	
				{ $svc.Core.SaveChanges() } | Should Throw;
				$entityKind.Id | Should Be 0;	
				$Error[0].Exception | Should Match "entity.Name : The Name field is required."
			}
			finally
			{
				if (!$entityKind -eq $false -And $entityKind.Id -ne 0)
				{
					#Cleanup
					$svc.Core.DeleteObject($entityKind);
					$result = $svc.Core.SaveChanges();
					$result.StatusCode | Should Be 204;
					write-warning "EntityKind deleted"
				}
			}
		}
		
		It "CreateEntityKindWithoutVersion-Fail" -Test {
			try
			{
				# Arrange
				$entityKindName = ("TestForPesterRun-{0}" -f [Guid]::NewGuid().ToString())
				$entityKindDescription = ("Test Description For Pester Run - {0}" -f [Guid]::NewGuid().ToString())
				$entityKindVersion = [Guid]::NewGuid().ToString();
				$entityKindParameters = "'{ }'"
				
				# Act
				$entityKind = CreateEntityKind -entityKindName $entityKindName -entityKindDescription $entityKindDescription -entityKindVersion $entityKindVersion
				$entityKind.Version = $null;
				$svc.Core.AddToEntityKinds($entityKind)
				
				# Assert	
				{ $svc.Core.SaveChanges() } | Should Throw;
				$entityKind.Id | Should Be 0;	
				$Error[0].Exception | Should Match "entity.Version : The Version field is required."
			}
			finally
			{
				if (!$entityKind -eq $false -And $entityKind.Id -ne 0)
				{
					#Cleanup
					$svc.Core.DeleteObject($entityKind);
					$result = $svc.Core.SaveChanges();
					$result.StatusCode | Should Be 204;
					write-warning "EntityKind deleted"
				}
			}
		}
		
		It "CreateEntityKindTwiceWithDiffrentVersion" -Test {
			try
			{
				# Arrange
				$entityKindName = ("TestForPesterRun-{0}" -f [Guid]::NewGuid().ToString())
				$entityKindDescription1 = ("Test Description For Pester Run - {0}" -f [Guid]::NewGuid().ToString())
				$entityKindVersion1 = [Guid]::NewGuid().ToString();
				$entityKindParameters = "'{ }'"
				$entityKind1 = CreateEntityKind -entityKindName $entityKindName -entityKindDescription $entityKindDescription1 -entityKindVersion $entityKindVersion1
				
				# Act
				$svc.Core.AddToEntityKinds($entityKind1);
				$result = $svc.Core.SaveChanges();

				# Assert
				$result.StatusCode | Should Be 201;
				$entityKind1 | Should Not Be $null;
				$entityKind1.Name | Should Be $entityKindName;
				$entityKind1.Description | Should Be $entityKindDescription1;
				
				# Arrange
				$entityKindDescription2 = ("SecondEntry: Test Description For Pester Run - {0}" -f [Guid]::NewGuid().ToString())
				$entityKindVersion2 = [Guid]::NewGuid().ToString();
				$entityKind2 = CreateEntityKind -entityKindName $entityKindName -entityKindDescription $entityKindDescription2 -entityKindVersion $entityKindVersion2
				
				# Act
				$svc.Core.AddToEntityKinds($entityKind2);
				$result = $svc.Core.SaveChanges();
				
				# Assert
				$entityKind2 | Should Not Be $null;
				$entityKind2.Name | Should Be $entityKindName;
				$entityKind2.Description | Should Be $entityKindDescription2;
				
				$entityKind1Check = $svc.Core.EntityKinds.AddQueryOption('$filter',("Id eq {0}" -f $entityKind1.Id))
				$entityKind2Check = $svc.Core.EntityKinds.AddQueryOption('$filter',("Id eq {0}" -f $entityKind2.Id))
				$entityKind1Check.Description | Should Not Be $entityKind2Check.Description
				$entityKind1Check.Id | Should Not Be $entityKind2Check.Id
				$entityKind1Check.Name | Should Be $entityKind2Check.Name
			}
			finally
			{
				#Cleanup
				$svc.Core.DeleteObject($entityKind1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				write-warning "EntityKind deleted"
				
				#Cleanup
				$svc.Core.DeleteObject($entityKind2);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				write-warning "EntityKind deleted"
			}
		}
		
		It "CreateEntityKindTwiceWithSameNameAndVersion-Fail" -Test {
			try
			{
				# Arrange
				$entityKindName = ("TestForPesterRun-{0}" -f [Guid]::NewGuid().ToString())
				$entityKindDescription1 = ("Test Description For Pester Run - {0}" -f [Guid]::NewGuid().ToString())
				$entityKindDescription2 = ("SecondEntry: Test Description For Pester Run - {0}" -f [Guid]::NewGuid().ToString())
				$entityKindVersion = [Guid]::NewGuid().ToString();
				$entityKindParameters = "'{ }'"
				$entityKind = CreateEntityKind -entityKindName $entityKindName -entityKindDescription $entityKindDescription1 -entityKindVersion $entityKindVersion
				$svc.Core.AddToEntityKinds($entityKind);
				
				# Act
				$result = $svc.Core.SaveChanges();

				# Assert
				$result.StatusCode | Should Be 201;
				$entityKind | Should Not Be $null;
				$entityKind.Name | Should Be $entityKindName;
				$entityKind.Description | Should Be $entityKindDescription1;

				
				# Act
				$entityKind2 = CreateEntityKind -entityKindName $entityKindName -entityKindDescription $entityKindDescription2 -entityKindVersion $entityKindVersion
				$svc.Core.AddToEntityKinds($entityKind2);
				
				
				{ $svc.Core.SaveChanges() } | Should Throw;
				$svc.Core.RevertEntityState($entityKind2)
				$Error[0].Exception | Should Match ("EntityKind with Name '{0}' and Version '{1}' already exists" -f $entityKindName, $entityKindVersion)
			}
			finally
			{
				#Cleanup
				$svc.Core.DeleteObject($entityKind);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				write-warning "EntityKind deleted"
			}
		}
		
		It "UpdateEntityKindNameDescriptionVersionParameter-Succeeds" -Test {
			try
			{
				# Arrange Create EntityKind
				$entityKindName = ("TestForPesterRun-{0}" -f [Guid]::NewGuid().ToString())
				$entityKindDescription = ("Test Description For Pester Run - {0}" -f [Guid]::NewGuid().ToString())
				$entityKindVersion = [Guid]::NewGuid().ToString();
				$entityKindParameters = "'{ }'"
				$entityKind = CreateEntityKind -entityKindName $entityKindName -entityKindDescription $entityKindDescription -entityKindVersion $entityKindVersion
				$svc.Core.AddToEntityKinds($entityKind)
				$result = $svc.Core.SaveChanges();
				
				$entityKindCreated = $svc.Core.EntityKinds.AddQueryOption('$filter', ("Id eq {0}" -f $entityKind.Id))
				
				$result.StatusCode | Should Be 201;			
				$entityKindCreated | Should Not Be $null;
				$entityKindCreated.Name | Should Be $entityKindName
				$entityKindCreated.Description | Should Be $entityKindDescription
				$entityKindCreated.Version | Should Be $entityKindVersion
				
				# Arrange Update
				$entityKindUpdateName = ("NameUpdated-{0}" -f [Guid]::NewGuid().ToString());
				$entityKindUpdateDescription = ("DescriptionUpdated-{0}" -f [Guid]::NewGuid().ToString());
				$entityKindUpdateParameter = ("ParameterUpdated-{0}" -f [Guid]::NewGuid().ToString());
				$entityKindUpdateVersion = 2;
				
				#Act
				$entityKind.Name = $entityKindUpdateName;
				$entityKind.Description = $entityKindUpdateDescription;
				$entityKind.Parameters = $entityKindUpdateParameter;
				$entityKind.Version = $entityKindUpdateVersion;

				$svc.Core.UpdateObject($entityKind);
				$result = $svc.Core.SaveChanges();
				
				# Assert	
				write-warning $entityKindCreated.Name
				$entityKindUpdated = $svc.Core.EntityKinds.AddQueryOption('$filter', "Id eq "+$entityKind.Id+"")

				$result.StatusCode | Should Be 204;			
				$entityKindUpdated.Name | Should Be $entityKindUpdateName;
				$entityKindUpdated.Description | Should Be $entityKindUpdateDescription;
				$entityKindUpdated.Parameters | Should Be $entityKindUpdateParameter;
				$entityKindUpdated.Version | Should Be $entityKindUpdateVersion;
			}
			finally
			{
				if (!$entityKind -eq $false)
				{
					#Cleanup
					$svc.Core.DeleteObject($entityKind);
					$result = $svc.Core.SaveChanges();
					$result.StatusCode | Should Be 204;
					write-warning "EntityKind deleted"
				}
			}
		}
	}
}

#
# Copyright 2015 d-fens GmbH
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

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU32rQlGk1M5H53Q8n1QjdI5A8
# EiKgghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAzMDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAgDLcB40coJydPCroPSGLWaFN
# fsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4
# A11P2RwumODpiObs1wV+Vip79xZbo62PlyUShBuyXGNKCtLvEFRHgoQ1aSicDOQf
# FBYk+nXcdHJuTsrjakOvz302SNG96QaRLC+myHH9z73YnSGY/K/b3iKMr6fzd++d
# 3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUHCya9vm0CXrG4sFhshToN9v9aJwzF3lPn
# VDxWTMlOTDD28lz7GozCgr6tWZH2G01Ve89bAdz9etNvI1wyR5sB88FRFEaKmzCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBT/NGsVvLvazGpb
# hzqb8AwAcpOQcTANBgkqhkiG9w0BAQEFAASCAQBk4XNzL0lxNX/QW8GkdZyZ5jgo
# O/KAjFDBW2xUYhWgXOCcjIuY5F2fQg/D9a0HV/QHY1I1YAEoOr9lxBHJaMV9aWlP
# j2gBii7/u42nTfcKa1k8TIbgYpQzkngRHDKzCzewGtPUtQql2ukj45HPtNO46yQn
# thwb/ooE7yvQPyXhNPcQNhvsSMrrtuKZKqXok0pRukmZrJ3htCKvoAPlFNwv8wn1
# 4LsbiBDvCjk/wO7oWnLlqqCUuqrvXkcnl5EgomBHDBXOgiFZX4VdwW26aOt83zbk
# Ibz0j4AATQvQlP0Z73PcclryXBBdK3Yv9vmh7n2fsOOm8gmTBJx7vv9aT5zGoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTIyMjExMTM1NVowIwYJKoZIhvcNAQkEMRYEFA60esJUiCpHUQUoE81sUKbaod6+
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQBLDHvd7BVGS+INrU2j
# Rl7MsBMtL6IS6IpUJwdi8gsj70R9ee7iP+W9ubZFbFjWBdrNEBx58jAPZMIgUhkM
# TMN9fmx75scE6NohLUb4NRMiU/YINjLGCAaTctj1+djzRonIetQr2uc4YfEIar2l
# eKEi1Omxv19l0Vp1WYZkGSOx2THyA83s8eqY97sI5/xz58Oc7ZjCMPmGj0sO3oh8
# hnkLec3DzoUDRqK3ZMFc6s6KD3rlWtwz3ZMtaMMrpiDWgPTznpexyXkVOthPuDwK
# 1N8d3omnEtuy25Y2QhdGH3Z8DfQlKQw62ZNChHM8Hv7hBSQ98bMZAFPJkztpmMlv
# 7o9L
# SIG # End signature block
