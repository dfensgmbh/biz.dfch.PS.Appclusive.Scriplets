#Requires -modules 'biz.dfch.PS.Appclusive.Client'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

Describe -Tags "Message.Tests" "Message.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	. "$here\$sut"
	
	$messagesUri = 'http://appclusive/api/Diagnostics/Messages';

	Context "Negotiate-Authentication" {
	
		# Context wide constants
		
		BeforeEach {
			# N/A
		}

		It "CreatingMessage-Succeeds" -Test {
			
			# Arrange
			$jsonBody = @'
{
    "Parameters":  null
	,
    "Name":  "2e6b1bda-72a1-454c-8c66-86d85f670d0d"
	,
    "Description":  "[Pester] Message.Tests CreatingMessage-Succeeds"
}
'@
			
			# Act
			$result = Invoke-RestMethod -Method POST 'http://appclusive/api/Diagnostics/Messages/Create' -Credential $cred -ContentType 'application/json' -Body $jsonBody
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be "2e6b1bda-72a1-454c-8c66-86d85f670d0d";
			$result.Description | Should Be "[Pester] Message.Tests CreatingMessage-Succeeds";
			$result.Parameters | Should Be $null;
			
			$message = Invoke-RestMethod "http://appclusive/api/Diagnostics/Messages($($result.Id))" -Credential $cred;
			$message.Id | Should Be $result.Id;
			
			$result = Invoke-RestMethod -Method DELETE 'http://appclusive/api/Diagnostics/Messages($($result.Id))' -Credential $cred
		}
	}

		It "CreatingMessageWithParameters-Succeeds" -Test {
			
			# Arrange
			$jsonBody = @'
{
    "Parameters":  "[ 'this-is-valid-json' , 'and-it-is-an-array' ]"
	,
    "Name":  "2e6b1bda-72a1-454c-8c66-86d85f670d0d"
	,
    "Description":  "[Pester] Message.Tests CreatingMessage-Succeeds"
}
'@
			
			# Act
			$result = Invoke-RestMethod -Method POST 'http://appclusive/api/Diagnostics/Messages/Create' -Credential $cred -ContentType 'application/json' -Body $jsonBody
			
			# Assert
			$result | Should Not Be $null;
			$result.Name | Should Be "2e6b1bda-72a1-454c-8c66-86d85f670d0d";
			$result.Description | Should Be "[Pester] Message.Tests CreatingMessageWithParameters-Succeeds";
			$result.Parameters | Should Be "[ 'this-is-valid-json' , 'and-it-is-an-array' ]";
			
			$message = Invoke-RestMethod "http://appclusive/api/Diagnostics/Messages($($result.Id))" -Credential $cred;
			$message.Id | Should Be $result.Id;

			$result = Invoke-RestMethod -Method DELETE 'http://appclusive/api/Diagnostics/Messages($($result.Id))' -Credential $cred
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
