$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Invoke-GenericMethod.Tests" "Invoke-GenericMethod.Tests" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"
	
	Context "Generic-Succeeds" {
	
		# Context wide constants
		
		BeforeEach {
			# N/A
		}

		It "Warmup" -Test {
		
			1 | Should Be 1;
		
		}
	}

	Context "Type" {

		It "InvalidType-Throws" -Test {
		
			$statement = '[invalid.Type]::DeserializeObject[biz.dfch.Appclusive.Products.Infrastructure.V001.Disk01]($serialisedBaseDisk)';
			{ Invoke-GenericMethod $statement } | Should ThrowErrorId 'TypeNotFound';
		}
	}

	Context "MethodName" {

		It "InvalidMethodName-Throws" -Test {
		
			$statement = '[biz.dfch.CS.Appclusive.Public.BaseDto]::InvalidMethodName[biz.dfch.Appclusive.Products.Infrastructure.V001.Disk01]($serialisedBaseDisk)';
			{ Invoke-GenericMethod $statement } | Should ThrowCategory "InvalidResult";
		}
	}

	Context "Parameters" {

		It "InvalidType-Throws" -Test {
		
			$statement = '[biz.dfch.CS.Appclusive.Public.BaseDto]::DeserializeObject[biz.dfch.Appclusive.Products.Infrastructure.V001.Disk01]($invalidVariable)';
			{ Invoke-GenericMethod $statement } | Should ThrowErrorId 'InvokeMethodOnNull';
		}
	}

	Context "SuccessfulStaticInvocation" {

		It "InvocationWithImplicitParameters-Succeeds" -Test {

			$message = New-Object biz.dfch.CS.Appclusive.Public.Messaging.Dto.Message;
			$message.Body = "arbitrary-body";
			$message.BodyType = "arbitrary-bodytype";
			$message.HeaderType = "arbitrary-headertype";
			$message.Header = "arbitrary-header";
			$message.IsValid() | Should Be $true;
			$json = $message.SerializeObject();
			
			$statement = '[biz.dfch.CS.Appclusive.Public.BaseDto]::DeserializeObject[biz.dfch.CS.Appclusive.Public.Messaging.Dto.Message]($json)';
			$result = Invoke-GenericMethod $statement;
			
			$result.Body | Should Be $message.Body;
			$result.BodyType | Should Be $message.BodyType;
			$result.HeaderType | Should Be $message.HeaderType;
			$result.Header | Should Be $message.Header;
		}

		It "InvocationWithExplicitParameters-Succeeds" -Test {

			$message = New-Object biz.dfch.CS.Appclusive.Public.Messaging.Dto.Message;
			$message.Body = "arbitrary-body";
			$message.BodyType = "arbitrary-bodytype";
			$message.HeaderType = "arbitrary-headertype";
			$message.Header = "arbitrary-header";
			$message.IsValid() | Should Be $true;
			$json = $message.SerializeObject();
			
			$statement = '[biz.dfch.CS.Appclusive.Public.BaseDto]::DeserializeObject[biz.dfch.CS.Appclusive.Public.Messaging.Dto.Message]([System.String] $json)';
			$result = Invoke-GenericMethod $statement;
			
			$result.Body | Should Be $message.Body;
			$result.BodyType | Should Be $message.BodyType;
			$result.HeaderType | Should Be $message.HeaderType;
			$result.Header | Should Be $message.Header;
		}

	Context "SuccessfulInstanceInvocation" {

		It "InvocationWithImplicitParameters-Succeeds" -Test {

			$message = New-Object biz.dfch.CS.Appclusive.Public.Messaging.Dto.Message;
			$message.Body = "arbitrary-body";
			$message.BodyType = "arbitrary-bodytype";
			$message.HeaderType = "arbitrary-headertype";
			$message.Header = "arbitrary-header";
			$message.IsValid() | Should Be $true;
			$json = $message.SerializeObject();
			
			$statement = '$core.DeserializeObject[biz.dfch.CS.Appclusive.Public.Messaging.Dto.Message]($json)';
			$result = Invoke-GenericMethod $statement;
			
			$result.Body | Should Be $message.Body;
			$result.BodyType | Should Be $message.BodyType;
			$result.HeaderType | Should Be $message.HeaderType;
			$result.Header | Should Be $message.Header;
		}

		It "InvocationWithExplicitParameters-Succeeds" -Test {

			$message = New-Object biz.dfch.CS.Appclusive.Public.Messaging.Dto.Message;
			$message.Body = "arbitrary-body";
			$message.BodyType = "arbitrary-bodytype";
			$message.HeaderType = "arbitrary-headertype";
			$message.Header = "arbitrary-header";
			$message.IsValid() | Should Be $true;
			$json = $message.SerializeObject();
			
			$statement = '$core.DeserializeObject[biz.dfch.CS.Appclusive.Public.Messaging.Dto.Message]([System.String] $json)';
			$result = Invoke-GenericMethod $statement;
			
			$result.Body | Should Be $message.Body;
			$result.BodyType | Should Be $message.BodyType;
			$result.HeaderType | Should Be $message.HeaderType;
			$result.Header | Should Be $message.Header;
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
