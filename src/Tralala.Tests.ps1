$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Tralala.Tests" "Tralala.Tests" {

	Mock Export-ModuleMember { return $null; }

	Mock Invoke-RestMethod { return "tralala"; }
	
	. "$here\$sut"
	
	Context "AddingTwoNumbers-Succeeds" {
	
		# Context wide constants
		
		BeforeEach {
			# N/A
		}

		It "Warmup" -Test {
		
			1 | Should Be 1;
		
		}
	
		It "Check-InstallationDirectory" -Test {
			Test-Path C:\Logs | Should Be $true;
		}
		
		It "AddingTwoAndTwo-ShouldBeFour" -Test {
		
			$result = Add 2 2
			
			$result | Should Be 4;
		}
	}

	Context "DividingTwoNumbers-Succeeds" {
		It "DividingTwoAndTwo-ShouldBeOne" -Test {
		
			$result = Div 2 2
			
			$result | Should Be 1;
		}
	}

	Context "DividingTwoNumbers-Throws" {

		It "DividingTwoAndTwo-ShouldThrow" -Test {
		
			{ Div 2 0 } | Should Throw ;
		}
	}
	
	Context "DoSomehting-Succeeds" {

		It "DoSomehting-Succeeds" -Test {
		
			$uri = "http://www.example.com"
			$result = DoSomething $uri;
			
			$result | Should Be "tralala";
		}
	}
	
	Context "MyFirstTest" {
		It "DoSomeMagic" -Test {
			1 + 1 | Should Be 2;
		}
	}
	
	Context "MyFirstAppclusiveTest" {
		It "Get-UserWithIdOne" -Test {
			
			$result = $svc.Core.Users.AddQueryOption('$filter', "Id eq 1") | Select;
			$result | Should Not Be $null;
			$result.Id | Should Be 1;
			
		}
		
		It "Get-SystemRootNode" -Test {
			
			$node = $svc.Core.Nodes.AddQueryOption('$filter', "Id eq 1") | Select;
			$node | Should Not Be $null;
			$node.Id | Should Be 1;
			$node.ParentId | Should Be $node.Id;
		}
	}

	Context "RedmineTest" {
	
		BeforeEach {

			$svc = Enter-Apc -Credential $cred;
		}

		It "RequestingIncidentsViaAppclusiveApiShouldSucceed" -Test {
	
			# Arrange
			$svc = Enter-Acp -Credential $cred;
		
			# Act, Assert
			$svc.Csm.Incidents | Should Not Throw;
			
			# Act
			$result = $svc.Csm.Incidents;

			# Assert
			$result | Should Not Be $null;
			$result.Count -gt 0 | Should Be $true;

		}
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
