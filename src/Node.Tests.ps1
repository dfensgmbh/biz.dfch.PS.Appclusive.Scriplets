Import-Module biz.dfch.PS.Appclusive.Client

# create a test set
$nodeIds = @();
# define Id as a test set parameter
$nodeIds += @{"Id" = [long] 34884};
# this is expected to fail for Node.Id == 1
# $nodeIds += @{"Id" = [long] 1};
$nodeIds += @{"Id" = [long] 34885};

$entityKindIds = @();
$entityKindIds += @{"Id" = [long] 4097};

Describe -Tags "Node.Tests" "Node.Tests" {

    Context "#CLOUDTCL-NodeAvailableActions" {

		# pass the test set to the test
        It "AvailableActions-ShouldMatchStateMachine" -TestCases $nodeIds -Test {
			PARAM
			(
				# expect an id as input parameter, i.e. the node id to test
				[long] $Id
			)

			# Act: retrieve node we want to test with
			$sut = Get-ApcNode -Id $Id;
			
			# Assert it is there and has our node id
			$sut | Should Not Be $null;
			$sut.Id | Should Be $Id;
			$sut.EntityKindId | Should Not Be $null;
			
			# Act: get job of node
			$job = Get-ApcNode -Id $Id -ExpandJob;
			
			# Assert we have a job
			$job | Should Not Be $null;
			
			# Act: get available actions for this node
			$entitySetName = "Nodes";
			$actionName = "AvailableActions";
			$type = [System.String];
			$inputParameters = $null;
			$availableActions = $svc.Core.InvokeEntityActionWithListResult($entitySetName, $Id, $actionName, $type, $inputParameters);
			
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
			# Write-Host ($transitions | Out-String);
			
			# Assert that both arrays contain the same transitions
			foreach($transition in $transitions)
			{
				$availableActions.Contains($transition) | Should Be $true;
			}
        }

		# pass the test set to the test
        It "PermissionsForEntityKindVersion-ShouldBeAvailabe" -TestCases $entityKindIds -Test {
			PARAM
			(
				# expect an id as input parameter, i.e. the EntityKind id to test
				[long] $Id
			)
			
			# grab the EntityKind
			# $sut = Get-ApcEntityKind -Id $id;
			
			# make sure it exists
			
			# get all transitions from that EntityKind
			# hint1: like in previous tests case
			# hint2: convert that code into a function so you can reuse it in both tests
			
			# for each transition lookup the corresponding permission
			# hint1: you can query permissions via:
			# $q = "startswith(Name, '{0}:')" -f $sut.Version
			# $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select
			# hint2: permission comes in the following form "<EntityKind.Version>:<Transition>"
			# eg: "com.swisscom.cms.rhel7.v001:AB01OrderFullOSManagement"
			
			
		}
	}
}