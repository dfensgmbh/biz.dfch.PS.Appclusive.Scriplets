
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Node.Tests" "Node.Tests" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"
	
	# DFTODO - naming
	Context "#CLOUDTCL-1873-NodeTests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-ApcServer;
		}
		
		It "DoStateChangeOnNodeSetsConditionAndConditionParametersOnJob" -Test {
			# Arrange
			$condition = 'Continue';
			$conditionParams = @{Msg = "tralala"};
			
			$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
			$node.ParentId = 1;
			$node.Name = 'arbitrary';
			$node.Parameters = '{}';
			$node.EntityKindId = 1;
			$svc.Core.AddToNodes($node);
			$svc.Core.SaveChanges();

			$svc = Enter-ApcServer;
			$query = "RefId eq '{0}' and EntityKindId eq 1" -f $node.Id;
			$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;

			$jobResult = @{Version = "1"; Message = "Msg"; Succeeded = $true};
			Invoke-ApcEntityAction -InputObject $job -EntityActionName "JobResult" -InputParameters $jobResult;
			
			# Act
			Invoke-ApcEntityAction -InputObject $node -EntityActionName 'InvokeAction' -InputName $condition -InputParameters $conditionParams;
			
			# Assert
			$svc = Enter-ApcServer;
			$resultingJob = Get-ApcJob -Id $job.Id;
			$resultingJob.Condition | Should Be $condition;
			$resultingJob.ConditionParameters | Should Be ($conditionParams | ConvertTo-Json -Compress);
			
			# Cleanup
			$resultingNode = Get-ApcNode -Id $node.Id
			$svc.core.DeleteObject($resultingJob);
			$svc.core.DeleteObject($resultingNode);
		}
		
		It "AddAndDeleteNewNode" -Test {
			try {
				# Arrange
				$nodeName = "TestNode Parent"
				$nodeDescription = "TestNode used in Test"		
							
				# Act
				$node = CreateNode -nodeName $nodeName -nodeDescription $nodeDescription;
				$svc.Core.AddToNodes($node);
				$result = $svc.Core.SaveChanges();
							
				#Assert	
				$result.StatusCode | Should Be 201;
				$node.Id | Should Not Be 0;
			} finally {
				#Cleanup
				$svc.Core.DeleteObject($node);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "AddNewParentAndChildNode" -Test {
			try
			{
				# Arrange
				$nodeParentName = "TestNode Parent"
				$nodeParentDescription = "TestNode used in test"
				$nodeChildName = "TestNode Child"
				$nodeChildDescription = "TestNode used in test"
							
				# Create parent node
				$nodeParent = CreateNode -nodeName $nodeParentName -nodeDescription $nodeParentDescription;
				$svc.Core.AddToNodes($nodeParent);
				$result = $svc.Core.SaveChanges();
				
				#Assert	
				$result.StatusCode | Should Be 201;
				$nodeParent.Id | Should Not Be 0;
				
				# Create child node
				$result = $null;
				$nodeChild = CreateNode -nodeName $nodeChildName -nodeDescription $nodeChildDescription -nodeParentId $nodeParent.Id;
				$svc.Core.AddToNodes($nodeChild);
				$result = $svc.Core.SaveChanges();
				
				#Assert	
				$result.StatusCode | Should Be 201;
				$nodeChild.Id | Should Not Be 0;
				$nodeChild.ParentId | Should be $nodeParent.Id
			}
			finally
			{
				#Cleanup
				$svc.Core.DeleteObject($nodeChild);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($nodeParent);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "DeleteParentNodeWithExistingChildThrowsException" -Test {
			try 
			{
				$nodeChild = $null;
				$nodeParent = $null;
				
				#Arrange
				$nodeParentName = "TestNode Parent"
				$nodeParentDescription = "TestNode used in test"
				$nodeChildName = "TestNode Child"
				$nodeChildDescription = "TestNode used in test"
							
				#Create parent node
				$nodeParent = CreateNode -nodeName $nodeParentName -nodeDescription $nodeParentDescription;
				$svc.Core.AddToNodes($nodeParent);
				$result = $svc.Core.SaveChanges();
				
				#Assert	
				$result.StatusCode | Should Be 201;
				$nodeParent.Id | Should Not Be 0;
				
				#Create child node
				$result = $null;
				$nodeChild = CreateNode -nodeName $nodeChildName -nodeDescription $nodeChildDescription -nodeParentId $nodeParent.Id;
				$svc.Core.AddToNodes($nodeChild);
				$result = $svc.Core.SaveChanges();
				
				#Assert	
				$result.StatusCode | Should Be 201;
				$nodeChild.Id | Should Not Be 0;
				$nodeChild.ParentId | Should be $nodeParent.Id
						
				#Arrange/Assert delete parent node
				$svc.Core.DeleteObject($nodeParent);
				
				try 
				{
					$svc.Core.SaveChanges();
				} catch 
				{
					$exception = ConvertFrom-Json $error[0].Exception.InnerException.InnerException.Message;
					$exception.'odata.error'.message.value | Should Be "An error has occurred.";
					$detach = $svc.Core.Detach($nodeParent)
					$detach | Should Be $true;
				}
			}
			catch
			{
				#Cleanup
				#Reconnect
				$svc = Enter-ApcServer;
				$svc.Core.AttachTo('Nodes', $nodeChild);
				$svc.Core.AttachTo('Nodes', $nodeParent);
				
				$svc.Core.DeleteObject($nodeChild);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($nodeParent);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "ReadChildNodes" -Test {
			try
			{
				# Arrange
				$nodeParentName = "TestNode Parent"
				$nodeParentDescription = "TestNode used in test"
				$nodeChildName1 = "TestNode Child"
				$nodeChildDescription1 = "Test Child"
				$nodeChildName2 = "TestNode Child 2"
				$nodeChildDescription2 = "TestNode2"
							
				# Create parent node
				$nodeParent = CreateNode -nodeName $nodeParentName -nodeDescription $nodeParentDescription;
				$svc.Core.AddToNodes($nodeParent);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				# Create child node
				$nodeChild1 = CreateNode -nodeName $nodeChildName1 -nodeDescription $nodeChildDescription1 -nodeParentId $nodeParent.Id;
				$svc.Core.AddToNodes($nodeChild1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				$nodeChild2 = CreateNode -nodeName $nodeChildName2 -nodeDescription $nodeChildDescription2 -nodeParentId $nodeParent.Id;
				$svc.Core.AddToNodes($nodeChild2);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				# Act
				$childNodesReload = $svc.Core.LoadProperty($nodeParent, 'Children') | Select;
				
				#Assert
				$childNodesReload | Should Not Be $Null;
				$childNodesReload.Id -contains $nodeChild1.Id | Should be $true;
				$childNodesReload.Id -contains $nodeChild2.Id | Should be $true;
			}
			finally
			{
				#Cleanup
				$svc.Core.DeleteObject($nodeChild1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($nodeChild2);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($nodeParent);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "ReadParentNode" -Test {
			try
			{
				# Arrange
				$nodeParentName = "TestNode Parent"
				$nodeParentDescription = "TestNode used in test"
				$nodeChildName1 = "TestNode Child"
				$nodeChildDescription1 = "Test Child"
							
				# Create parent node
				$nodeParent = CreateNode -nodeName $nodeParentName -nodeDescription $nodeParentDescription;
				$svc.Core.AddToNodes($nodeParent);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				# Create child node
				$nodeChild1 = CreateNode -nodeName $nodeChildName1 -nodeDescription $nodeChildDescription1 -nodeParentId $nodeParent.Id;
				$svc.Core.AddToNodes($nodeChild1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				# Act
				$parentNodeReload = $svc.Core.LoadProperty($nodeChild1, 'Parent') | Select;
				
				#Assert
				$parentNodeReload | Should Not Be $Null;
				$parentNodeReload.Id | Should be $nodeParent.Id;
			}
			finally
			{
				#Cleanup
				$svc.Core.DeleteObject($nodeChild1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($nodeParent);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "UpdateParameterNameDescription" -Test {
			try {
				# Arrange
				$nodeName = "TestNode Parent";
				$nodeDescription = "TestNode used in Test";
				$nodeNameUpdate = "NameUpdated";
				$nodeDescriptionUpdate = "Description Updated";
				$nodeParameter = "New Parameter";
							
				$node = CreateNode -nodeName $nodeName -nodeDescription $nodeDescription;
				$svc.Core.AddToNodes($node);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				# Act
				$node.Name = $nodeNameUpdate;
				$node.Description = $nodeDescriptionUpdate;
				$node.Parameters = $nodeParameter;
				$svc.Core.UpdateObject($node);
				$result = $svc.Core.SaveChanges();
				
				$nodeReload = $svc.Core.Nodes.AddQueryOption('$filter', "Id eq {0}" -f $node.Id) | Select;
				
				#Assert	
				$result.StatusCode | Should Be 204;
				$nodeReload | Should Not Be $null;
				$nodeReload.Name | Should Be $nodeNameUpdate;
				$nodeReload.Description | Should Be $nodeDescriptionUpdate;
				$nodeReload.Parameters | Should Be $nodeParameter;
			} 
			finally 
			{
				#Cleanup
				$svc.Core.DeleteObject($node);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "DetacheChildNodeFromParentNode" -Test {
			try
			{
				# Arrange
				$nodeParentName = "TestNode Parent"
				$nodeParentDescription = "TestNode used in test"
				$nodeChildName1 = "TestNode Child"
				$nodeChildDescription1 = "Test Child"
							
				# Create parent node
				$nodeParent = CreateNode -nodeName $nodeParentName -nodeDescription $nodeParentDescription;
				$svc.Core.AddToNodes($nodeParent);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				# Create child node
				$nodeChild1 = CreateNode -nodeName $nodeChildName1 -nodeDescription $nodeChildDescription1 -nodeParentId $nodeParent.Id;
				$svc.Core.AddToNodes($nodeChild1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				$parentNodeReload = $svc.Core.LoadProperty($nodeChild1, 'Parent') | Select;
				$parentNodeReload.Id | Should be $nodeParent.Id;
				
				# Act
				$nodeChild1.ParentId = $null;
				$svc.Core.UpdateObject($nodeChild1);
				$resultUpdate = $svc.Core.SaveChanges();
				
				
				#Assert
				$nodeChild1.ParentId | Should Be $null;
				$resultUpdate.StatusCode | Should Be 204;
				
				# Try to load the Parent
				try
				{
					$parentNodeReload2 = $svc.Core.LoadProperty($nodeChild1, 'Parent') | Select;
				}
				catch
				{
					$exception = $error[0].Exception.InnerException.Message;
				}
				$exception | Should Be 'NotFound';

				# Try to load the non existing child
				$childNodesReload2 = $svc.Core.LoadProperty($nodeParent, 'Children') | Select;
				$childNodesReload2 | Should Be $null;
			}
			finally
			{
				#Cleanup
				$svc.Core.DeleteObject($nodeChild1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($nodeParent);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "AttachNodeAsChildToOtherNode" -Test {
			try
			{
				# Arrange
				$nodeName1 = "TestNode Parent"
				$nodeDescription1 = "TestNode used in test"
				$nodeName2 = "TestNode Child"
				$nodeDescription2 = "Test Child"
				
				# Create node 1
				$node1 = CreateNode -nodeName $nodeName1 -nodeDescription $nodeDescription1;
				$svc.Core.AddToNodes($node1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				# Create node 2
				$node2 = CreateNode -nodeName $nodeName2 -nodeDescription $nodeDescription2;
				$svc.Core.AddToNodes($node2);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				$node1LoadChild = $svc.Core.LoadProperty($node1, 'Children') | Select;
				$node2LoadChild = $svc.Core.LoadProperty($node2, 'Children') | Select;
				$node1LoadChild | Should be $null;
				$node2LoadChild | Should be $null;
				
				# Act
				$node2.ParentId = $node1.Id;
				$svc.Core.UpdateObject($node2);
				$resultUpdate = $svc.Core.SaveChanges();
				
				#Assert
				$parentNodeReload = $svc.Core.LoadProperty($node2, 'Parent') | Select;
				$childNodeReload = $svc.Core.LoadProperty($node1, 'Children') | Select;

				$resultUpdate.StatusCode | Should Be 204;
				$parentNodeReload.Id | Should Be $node1.Id
				$childNodeReload.Id | Should Be $node2.Id
			}
			finally
			{
				#Cleanup
				$svc.Core.DeleteObject($node2);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($node1);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "AttachNodeAsChildToHisOwn-ThrowsError" -Test {
			try
			{
				# Arrange
				$nodeName1 = "TestNode Parent"
				$nodeDescription1 = "TestNode used in test"
				
				# Create node 1
				$node = CreateNode -nodeName $nodeName1 -nodeDescription $nodeDescription1;
				$svc.Core.AddToNodes($node);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 201;
				
				# Act
				$node.ParentId = $node.Id;
				$svc.Core.UpdateObject($node);
				
				try 
				{
					$resultUpdate = $svc.Core.SaveChanges();
					$exception = $false;
				}
				catch
				{
					$exception = $true;
				}
				
				#Assert
				$exception | Should Be $true;
			}
			finally
			{
				#Cleanup
				$svc.Core.DeleteObject($node);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUoq27UvWD0zIizUIPisRaUMhL
# fm6gghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
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
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR3Re5OYd7b1dRN
# TxEVgKwRGMOg+TANBgkqhkiG9w0BAQEFAASCAQCNMSrR2l97+pzY0uTdq1pMWG6d
# 6v/f3tm2QyiVbw6AkDzOVB7Qv1roG32xVCu478w8yFMJSMJhjPF0jIsmVQKNw1E1
# 1NL1x/72Ld2IzRBFjaYUJeZCnM+gpSxztbGPqwuT2lFFmcd7pO/Z+tBaR9/9Ek7P
# yAIZXBngSSAdkeUzBQCGhAzYuzxU+KnOZKm9nLGXa0Zu/KFeoW1NSeAcWTNvVstt
# aIFLvmfApdOZtO559DJ+HHft+yL+Bq1DeVZ9pvPYw15+i4svau4SfGLfIQxmN1M2
# UveAuNP4MH08AgHVnrCK/BfwjayyawZO+cG/K6GlXIPpygWc4C2yGyhsn8SeoYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTIyMjExMTM1OFowIwYJKoZIhvcNAQkEMRYEFCD+BxsK9iQAlfkOT+4aMKAHdYX9
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQAducWXdUjY0aK7l75a
# H9spxRrN0CtaXheDg8QvIykhPJrwhSwoP/uS0EENrXbREY5cUacfH6tIYclQ/m2h
# J433FUOK9mruVJD77x+LSSLIE/qjknLPzTIU4mSxQQxYmCb+e3rD1dv2kL7y6aQw
# 8abFsnRNpNGvQ1LCjN11puznw47NIrKOD1ifhXVCPBkIBcP2vQKFTVapu/ekyUlC
# /NfmeVYxjDAoybNA3zxEebtjY4/I5YTMiod3EG4vJxkIZvjYbVbaFuff1CGQ2NWz
# fAiCAFIn35n3p87KTnbxLyA7Pwk1Mj7PKSIVijH5RRrb92roZUAkNEZybJhDFS+I
# APgI
# SIG # End signature block
