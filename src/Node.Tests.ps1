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
Function Get-Transitions{
            Param
            (
                $entityKind
            )
            # convert the json encoded finite state machine from EntityKind.Parameters to a dictionary (DictionaryParameters object)
			$dic = New-Object biz.dfch.CS.Appclusive.Public.DictionaryParameters($entityKind.Parameters);
			# Write-Host ($dic.Keys | Out-String);
			$transitions = @(); #create empty array
			foreach($key in $dic.Keys)
			{
				if($key.Contains('-')) #changed SHould be true because I got 24 times "true" as result
                {				
				    if($job.Status -ne $key.Split('-')[0])  ###<-EXPL.
				    {
					    continue;
				    }
				$transition = $key.Split('-')[-1]; #### [1] = [-1]???
				$transitions += $transition;
                }
			}

            #Return ($transitions)
}


Describe -Tags "Node.Tests" "Node.Tests" {

    Context "#CLOUDTCL-NodeAvailableActions" {

		# pass the test set to the test
        <#It "AvailableActions-ShouldMatchStateMachine" -TestCases $nodeIds -Test {
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
			# convert the json encoded finite state machine from EntityKind.Parameters to a dictionary (DictionaryParameters object)
			$dic = New-Object biz.dfch.CS.Appclusive.Public.DictionaryParameters($entityKind.Parameters);
			# Write-Host ($dic.Keys | Out-String);
			$transitions = @(); #create empty array
			foreach($key in $dic.Keys)
			{
				$key.Contains('-') | Should Be $true;
				
				if($job.Status -ne $key.Split('-')[0])  ###<-EXPL.
				{
					continue;
				}
				$transition = $key.Split('-')[-1]; #### [1] = [-1]???
				$transitions += $transition;
			}
			# Write-Host ($transitions | Out-String);
			
			# Assert that both arrays contain the same transitions
			foreach($transition in $transitions)
			{
				$availableActions.Contains($transition) | Should Be $true;
			}
        } #>

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
            $EntityKindTransitions = Get-Transitions($sut);
            #Write-Host $EntityKindTransitions;
            #Write-Host $sut.Version;
			
			# for each transition lookup the corresponding permission

            #get all permissions available the particular EntityKind using its version
			# hint1: you can query permissions via:
			$q = "startswith(Name, '{0}:')" -f $sut.Version
			$transitionPermissions = $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select
			# hint2: permission comes in the following form "<EntityKind.Version>:<Transition>"
			# eg: "com.swisscom.cms.rhel7.v001:AB01OrderFullOSManagement"
            # get an array of transitions
            $transitionsArray = @(); #create empty array
            foreach($name in $transitionPermissions.Name)
			{
                if($name.Contains(':'))
                {	
                    $x = $name.Split(':')[1];
                    $transitionsArray += $x;
			    }
			}
            
            #
            foreach($transition in $EntityKindTransitions)
			{
				$transitionsArray.Contains($transition) | Should Be $true;
			}

            
		}
	}
}