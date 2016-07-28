$here = Split-Path -Parent $MyInvocation.MyCommand.Path

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

# PS > Get-ApcTenant | Select Id, Name, ParentId

# Id                                   Name            ParentId
# --                                   ----            --------
# 11111111-1111-1111-1111-111111111111 Level1          11111111-1111-1111-1111-111111111111
# ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe Level2 		   11111111-1111-1111-1111-111111111111
# 99580d56-b5d1-4875-8301-7c2385566225 Level3          ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe
# 42537362-9fb3-4ec6-96f7-191573001738 Level4          99580d56-b5d1-4875-8301-7c2385566225
# bb7580a0-5d34-40b2-9851-86c66443f304 Level2Unrelated 11111111-1111-1111-1111-111111111111

# 11111111-1111-1111-1111-111111111111 Level1
#		ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe Level2
#				99580d56-b5d1-4875-8301-7c2385566225 Level3
#						42537362-9fb3-4ec6-96f7-191573001738 Level4
#		bb7580a0-5d34-40b2-9851-86c66443f304 Level2Unrelated

Describe -Tags "Tenant-Hierarchy.Tests" "Tenant-Hierarchy.Tests" {

	BeforeEach {
		
		$PSDefaultParameterValues.'Write-Host:ForegroundColor' = 'Gray'
	}
	
	AfterEach {
	
		$PSDefaultParameterValues.Clear();
	}
	
	Mock Export-ModuleMember { return $null; }

	$sourceTenant = New-Object biz.dfch.CS.Appclusive.Api.Core.Tenant;
	$relatedTenant = New-Object biz.dfch.CS.Appclusive.Api.Core.Tenant;

	$relations = @(
		'IsAncestor', 
		'IsParent', 
		'IsSelf', 
		'IsSibling', 
		'IsChild', 
		'IsDescendant'
		'IsRelated'
	);
	
	Context "SourceIsLevel4-TargetIsLevel2" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $true;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $false;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $false;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = '42537362-9fb3-4ec6-96f7-191573001738'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}
	
	Context "SourceIsLevel2-TargetIsLevel4" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $false;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $false;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $true;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = '42537362-9fb3-4ec6-96f7-191573001738'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}
	
	Context "SourceIsLevel3-TargetIsLevel2" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $true;
		$expectedResults.IsParent = $true;
		$expectedResults.IsSelf = $false;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $false;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = '99580d56-b5d1-4875-8301-7c2385566225'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}
	
	Context "SourceIsLevel2-TargetIsLevel3" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $false;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $false;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $true;
		$expectedResults.IsDescendant = $true;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = '99580d56-b5d1-4875-8301-7c2385566225'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}
	
	Context "SourceIsLevel2-TargetIsLevel1" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $true;
		$expectedResults.IsParent = $true;
		$expectedResults.IsSelf = $false;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $false;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = '11111111-1111-1111-1111-111111111111'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}
	
	Context "SourceIsLevel1-TargetIsLevel2" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $false;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $false;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $true;
		$expectedResults.IsDescendant = $true;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = '11111111-1111-1111-1111-111111111111'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}

	Context "SourceIsLevel2-TargetIsLevel2-Self" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $false;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $true;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $false;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}

	Context "SourceIsLevel2-TargetIsLevel2-Sibling" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $false;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $false;
		$expectedResults.IsSibling = $true;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $false;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = 'ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = 'bb7580a0-5d34-40b2-9851-86c66443f304'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}

	Context "SourceIsLevel1-TargetIsLevel1-Self" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $false;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $true;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $false;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = '11111111-1111-1111-1111-111111111111'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = '11111111-1111-1111-1111-111111111111'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}
	
	Context "SourceIsLevel4-TargetIsLevel4-Self" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $false;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $true;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $false;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = '42537362-9fb3-4ec6-96f7-191573001738'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = '42537362-9fb3-4ec6-96f7-191573001738'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
		}
	}
	
	Context "SourceIsLevel4-TargetIsLevel2-Unrelated" {
		
		$expectedResults = @{}
		$expectedResults.IsAncestor = $false;
		$expectedResults.IsParent = $false;
		$expectedResults.IsSelf = $false;
		$expectedResults.IsSibling = $false;
		$expectedResults.IsChild = $false;
		$expectedResults.IsDescendant = $false;
		$expectedResults.IsRelated = $false;

		$testCases = @();
		foreach($relation in $relations)
		{
			$testCases += @{ 'Relation' = $relation ; 'ExpectedResult' = $expectedResults.$relation; };
		}

		$sourceTenant.Id = '42537362-9fb3-4ec6-96f7-191573001738'
		Set-ApcSessionTenant $sourceTenant.Id

		$relatedTenant.Id = 'bb7580a0-5d34-40b2-9851-86c66443f304'

		It ("Test-Relation {0} --- ? ---> {1} " -f $sourceTenant.Id, $relatedTenant.Id) -TestCases $testCases -Test {
		
			PARAM($Relation, $ExpectedResult)
			Write-Host ("{0} : Should Be {1}" -f $Relation, $ExpectedResult);
		
			$result = $svc.Core.InvokeEntityActionWithSingleResult($relatedTenant, $Relation, [bool], $null);
			$result | Should Be $ExpectedResult;
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
