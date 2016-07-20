Import-Module biz.dfch.PS.Appclusive.Client

# $credentials = Get-Credential -UserName "w2012r2-t6-10\Administrator" -Message "Login To Lab3" #enter credentials to connect to lab3 (domain of lab3 = w2012r2-t6-10)
# $labSvc = Enter-ApcServer -ServerBaseUri "http://172.19.115.33/appclusive" -Credential $credentials


Describe -Tags "testcase2" "testcase2.ps1" {

    Context "#CLOUDTCL-??" {

        It "nodes" -Test {
			# Arrange
			[long] $nodeId = 34884;

			# Act: retrieve node we want to test with
			$sut = Get-ApcNode -Id $nodeId;
			
			# Assert it is there and has our node id
			$sut | Should Not Be $null;
			$sut.Id | Should Be $nodeId;
			
			# Act: get job of node
			$job = Get-ApcNode -Id $nodeId -ExpandJob;
			
			# Assert
			$job | Should Not Be $null;
			$sut.EntityKindId | Should Not Be $null;
			
			# Act: get available actions for this node
			$entitySetName = "Nodes";
			$actionName = "AvailableActions";
			$type = [System.String];
			$inputParameters = $null;
    		$availableActions = $svc.Core.InvokeEntityActionWithListResult($entitySetName, $nodeId, $actionName, $type, $inputParameters);
			
			# Assert we get some actions
			$availableActions | Should Not Be $null;
			$availableActions.Count -gt 0 | Should Be $true;
			# Write-Host ($availableActions | Out-String)
			
			# Act: get the state machine of the EntityKind
			# Write-Host $sut.EntityKindId
			$entityKind = Get-ApcEntityKind -Id $sut.EntityKindId;
			#Assert
			$entityKind | Should Not Be $null;
			$entityKind.Id | Should Be $sut.EntityKindId;
			$entityKind.Parameters | Should Not Be $null;
			# convert the json encoded finite state machine from EntityKind.Parameters to a dictionary (DictionaryParameters object)
			$dic = New-Object biz.dfch.CS.Appclusive.Public.DictionaryParameters($entityKind.Parameters);
			# Write-Host ($dic.Keys | Out-String);
			$transitions = @();
			foreach($key in $dic.Keys)
			{
				$key.Contains('-') | Should Be $true;
								if($job.Status -ne $key.Split('-')[0])
				{
					continue;
				}
				$transition = $key.Split('-')[-1];
				$transitions += $transition;
			}
			Write-Host ($transitions | Out-String);
			
			$comparisonResult = Compare-Object -ReferenceObject $transitions -DifferenceObject $availableActions;
			Write-Host $comparisonResult

			#ACT
			#$newJob = Get-ApcJob | Where-Object {$_.RefId -eq $sut.Id & $_.Status -eq "Running"};

        }
	}
} 
