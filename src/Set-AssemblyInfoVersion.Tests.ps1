$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "AssemblyInfo.Tests" "AssemblyInfo.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	Mock Get-Item { 
		$file = Join-Path -Path $PWD -ChildPath "arbitrary-AssemblyInfo.cs";
		return New-Object System.IO.FileInfo($file);
	}
	
	Mock Get-Content { return $AssemblyInfoCs; }
	
	Mock Test-Path { return $false; } -ParameterFilter { $Path -And $Path.Contains("inexistent-AssemblyInfo.cs") }
	Mock Test-Path { return $true; } -ParameterFilter { $Path -And $Path.EndsWith("\AssemblyInfo.cs") }
	
	Mock Set-Content { return $Value; }
	
	$AssemblyInfoCs = @"
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// General Information about an assembly is controlled through the following 
// set of attributes. Change these attribute values to modify the information
// associated with an assembly.
[assembly: AssemblyTitle("biz.dfch.CS.Appclusive.Scheduler.Core")]
[assembly: AssemblyDescription("Windows Scheduler Service for the Appclusive Framework")]
[assembly: AssemblyConfiguration("")]
[assembly: AssemblyCompany("d-fens GmbH")]
[assembly: AssemblyProduct("biz.dfch.CS.Appclusive.Scheduler.Core")]
[assembly: AssemblyCopyright("Copyright © 2011 - 2016 d-fens GmbH.")]
[assembly: AssemblyTrademark("The d-fens logo is a registered trademark in the European Union and/or other countries.")]
[assembly: AssemblyCulture("")]

// Setting ComVisible to false makes the types in this assembly not visible 
// to COM components.  If you need to access a type in this assembly from 
// COM, set the ComVisible attribute to true on that type.
[assembly: ComVisible(false)]

// The following GUID is for the ID of the typelib if this project is exposed to COM
[assembly: Guid("3543629e-c929-4632-ac46-6e3842fa0158")]

// Version information for an assembly consists of the following four values:
//
//      Major Version
//      Minor Version 
//      Build Number
//      Revision
//
// You can specify all the values or you can default the Build and Revision Numbers 
// by using the '*' as shown below:
// [assembly: AssemblyVersion("1.0.*")]
[assembly: AssemblyVersion("2.9.0.*")]
//[assembly: AssemblyFileVersion("1.0.0.0")]
"@

	[Version] $NewVersion = "42.5.8.15";
	
	. "$here\$sut"
	
	Context "InputValidation" {

		# Context wide constants
		
		BeforeEach {
			# N/A
		}

		It "Warmup" -Test {
		
			1 | Should Be 1;
		
		}

		It "AssemblyInfoWithInexistentFile-Throws" -Test {
		
			$AssemblyInfoPathAndFile = 'C:\inexistent-folder\inexistent-AssemblyInfo.cs';
			{ Set-AssemblyInfoVersion $AssemblyInfoPathAndFile } | Should Throw "'InputObject'"
		
		}
		
		It "AssemblyInfoWithInvalidVersion-Throws" -Test {

			{ Set-AssemblyInfoVersion -Version 'abcde' } | Should Throw "'Version'"
		
		}

	}

	Context "Set-AssemblyInfoVersion-Succeeds" {
	
		# Context wide constants
		
		$AssemblyInfoPathAndFile = '.\AssemblyInfo.cs';
		
		BeforeEach {
			# N/A
		}

		AfterEach {
			# N/A
		}

		It "Warmup" -Test {
		
			1 | Should Be 1;
		
		}

		It "AssemblyInfoWhatIf-Succeeds" -Test {
		
			Set-AssemblyInfoVersion $AssemblyInfoPathAndFile "0.0.0.0" -WhatIf;
		
		}

		It "AssemblyInfoWhatIf-Succeeds" -Test {
		
			Set-AssemblyInfoVersion $AssemblyInfoPathAndFile "0.0.0.0" -KeepRevision:$false -WhatIf;
		
		}

		It "GettingAssemblyInfoKeepRevisionTrue-Succeeds" -Test {
		
			$result = Set-AssemblyInfoVersion $AssemblyInfoPathAndFile $NewVersion;
		
			$result.Contains($NewVersion) | Should Be $false;
		}

		It "GettingAssemblyInfoKeepRevisionFalse-Succeeds" -Test {
		
			$result = Set-AssemblyInfoVersion $AssemblyInfoPathAndFile $NewVersion -KeepRevision:$false;
			
			$result.Contains($NewVersion) | Should Be $true;
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
