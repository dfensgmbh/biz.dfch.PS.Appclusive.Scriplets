Import-Module biz.dfch.PS.Appclusive.Client

<#
for #CLOUDTCL-NodeAvailableActions
GIVEN 
    a Node in inventory
    AND
    this Node has a corresponding Job
    AND
    this Node has an arbitrary EntityKindId
WHEN
    a query against that Node with "AvailableActions" is performed
THEN
    then the resulting actions are identical to the state transitions available from the state machine based on the current state of the corresponding Job
#>

# create a test set / create array
$nodeIds = @();
# define Id as a test set parameter
$nodeIds += @{"Id" = [long] 34884};
# this is expected to fail for Node.Id == 1
# $nodeIds += @{"Id" = [long] 1};
$nodeIds += @{"Id" = [long] 34885};

#entityKindIds for 2nd test
$entityKindIds = @();
$entityKindIds += @{"Id" = [long] 4097};


#function gets an entityKind as a parameter and returns an array of the status transitions of the entityKind
function Get-Transitions {
	Param
	(
		[string] $Parameters
		,
		[string] $Status = $null
	)
	# convert the json encoded finite state machine from EntityKind.Parameters to a dictionary (DictionaryParameters object)
	$dic = New-Object biz.dfch.CS.Appclusive.Public.DictionaryParameters($Parameters);
	#Write-Host "CheckPoint2";
	$transitions = @(); #create empty array
	foreach($key in $dic.Keys)
	{
		if(!$key.Contains('-')) #changed SHould be true because I got 24 times "true" as result
		{	
			continue;
		}
		if($Status)
		{
			if( !$Status -Or ($Status -ne $key.Split('-')[0]) )  ###<-EXPL.
			{
				continue;
			}
		}
		$transition = $key.Split('-')[-1]; #### [1] = [-1]???
		$transitions += $transition;
	}

	return $transitions;
}


Describe -Tags "Node.Tests" "Node.Tests" {

    Context "#CLOUDTCL-Warmup" {
	
		It "ServiceReference-MustBeInitialised" -Test {
			$svc | Should Not Be $null;
		}
	}

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
			
			# Act: get available actions (for this node)
            #definition: System.Object InvokeEntitySetActionWithListResult(string entitySetName, string actionName, 
            #type type, System.Object inputParameters) 
			$entitySetName = "Nodes";
			$actionName = "AvailableActions";
			$type = [System.String];
			$inputParameters = $null;
			$availableActions = $svc.Core.InvokeEntityActionWithListResult($entitySetName, $Id, $actionName, $type, $inputParameters);
			
			# Assert we get some actions
			$availableActions | Should Not Be $null;
			$availableActions.Count -gt 0 | Should Be $true;
			#Write-Host ($availableActions | Out-String) #out-string makes an array of strings
			
			# Act: get the state machine of the EntityKind (general)
			# Write-Host $sut.EntityKindId
			$entityKind = Get-ApcEntityKind -Id $sut.EntityKindId;
			
			#Assert
			$entityKind | Should Not Be $null;
			$entityKind.Id | Should Be $sut.EntityKindId;
			$entityKind.Parameters | Should Not Be $null;
			#Write-Host "Checkpoint1";
            $transitions = Get-Transitions -Parameters $entityKind.Parameters -Status $job.status;
			Contract-Assert (!!$transitions);

			#Write-Host ($transitions | Out-String);
			
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
			$sut = Get-ApcEntityKind -Id $id;
			
			# make sure it exists
            $sut | Should Not Be $null
			
			# get all transitions from that EntityKind
			# hint1: like in previous tests case
			# hint2: convert that code into a function so you can reuse it in both tests
            $transitions = Get-Transitions($sut.Parameters);
			Contract-Assert (!!$transitions);
            #Write-Host $sut.Version;
			
			# for each transition lookup the corresponding permission
			# hint1: you can query permissions via:
			$q = "startswith(Name, '{0}:')" -f $sut.Version;
			$transitionPermissions = $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select;
			# hint2: permission comes in the following form "<EntityKind.Version>:<Transition>"
			# eg: "com.swisscom.cms.rhel7.v001:AB01OrderFullOSManagement"
            # also check "*" permissions
			# and assert that we do not have "too many" permissions
			
			#check that Initialise transition is included in the EntityKind transitions
			$transitions.Contains("Initialise") | Should be $true;
			
			#split the permission strings
			$transitionsArray = @(); #create empty array
            foreach($name in $transitionPermissions.Name)
			{
                if($name.Contains(':'))
                {	
                    $x = $name.Split(':')[1];
                    $transitionsArray += $x;
			    }
			}
			
			#check that the * permission is included:
			$transitionsArray.Contains("*") | Should be $true;
			
			#Check that all the transitions have permissions
			foreach($transition in $transitions)
			{
				foreach($transitionsArrayMember in $transitionsArray)
				{
					if($transition = "Initialise")
					{
						continue;
					}
					if($transitionsArrayMember = "*")
					{
						continue;
					}
					$transitionsArray.Contains($transition) | Should Be $true;
				}
			}
			
		}
	}
}
