$svc = Enter-Appclusive LAB3;


Describe -Tags "DeleteNode.Tests" "DeleteNode.Tests" {

    Context "#CLOUDTCL-Warmup" {
	
		BeforeEach {
		$moduleName = 'biz.dfch.PS.Appclusive.Client';
		Remove-Module $moduleName -ErrorAction:SilentlyContinue;
		Import-Module $moduleName;
		$svc = Enter-Appclusive LAB3;
		}
	
		It "ServiceReference-MustBeInitialised" -Test {
			$svc | Should Not Be $null;
		}
	}
	
	Context "#CLOUDTCL-DeleteNodeWithChildNode" {
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive LAB3;
		}
		
		It "DeleteNodeWithChildNode" -Test {
			#ARRANGE
			$nodeName = "newtestnode";
			$nodeDescr = "this is a test node";
			$nodeParentId = 1680;
			
			#ACT create Node
			$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
			$node.Name = $nodeName;
			$node.Description = $nodeDescr;
			$node.ParentId = $nodeParentId;
			$node.EntityKindId = 1;
			$node.Parameters = '{}';
			$node.Tid = "11111111-1111-1111-1111-111111111111";
			$svc.Core.AddToNodes($node);
			$result = $svc.Core.SaveChanges();
			
			#get the node
			$query = "Name eq '{0}' and ParentId eq {1}" -f $nodeName, $nodeParentId;
			$node = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
			#$node = Get-ApcNode -Name $nodeName -ParentId $nodeParentId | select;
			
			#ASSERT node
			$node | Should Not Be $null;
			$node.Id | Should Not Be $null;
			#get Id of the node
			$nodeId = $node.Id;
			
			#create subordinate Node
			#ARRANGE
			$childName = "newtestnode-Child";
			$childDescr = "this is a test subordinate Node";
			
			#ACT create child Node
			$childNode = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
			$childNode.Name = $childName;
			$childNode.Description = $childDescr;
			$childNode.ParentId = $nodeId; #it gets the id of the 1st node as parent Node
			$childNode.EntityKindId = 1;
			$childNode.Parameters = '{}';
			$svc.Core.AddToNodes($childNode);
			$result = $svc.Core.SaveChanges();
			
			#get child Node
			$query = "Name eq '{0}' and ParentId eq {1}" -f $childName, $nodeId;
			$childNode = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
			#$childNode = Get-ApcNode -Name $childName -ParentId $nodeId | select;
			
			#ASSERT child Node
			$childNode | Should Not Be $null;
			$childNode.Id | Should Not Be $null;
			$childNode.ParentId | Should Be $nodeId;
			
			$childId = $childNode.Id;
			
			try
			{ 
				#Push-ApcChangeTracker;
				
				$svc.Core.DeleteObject($node);
				#remove Node, but it's supposed to fail as we have Children
				{ $svc.Core.SaveChanges(); } | Should ThrowDataServiceClientException @{StatusCode = 400};
				# { $svc.Core.SaveChanges(); } | Should Throw;
				Write-Host "Parent not deleted";
			}
			catch
			{
				Write-Host $(Format-ApcException)
			}
			finally 
			{
				#Pop-ApcChangeTracker;
				$svc = Enter-Appclusive LAB3;
				
				
				#delete childNode
				$query = "Id eq {0}" -f $childId;
				$childNode = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
				$svc.Core.DeleteObject($childNode);
				$result = $svc.Core.SaveChanges();
				#delete Node
				$query = "Id eq {0}" -f $nodeId;
				$node = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
				$svc.Core.DeleteObject($node);
				$result = $svc.Core.SaveChanges();
			}
			
		}
		
		It "DeleteNodeCheckAttatchedEntitiesDeletion" -Test {
			#ARRANGE
			$nodeName = "newtestnode";
			$nodeDescr = "this is a test node";
			$nodeParentId = 1680;
			
			#ACT create Node
			$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
			$node.Name = $nodeName;
			$node.Description = $nodeDescr;
			$node.ParentId = $nodeParentId;
			$node.EntityKindId = 1;
			$node.Parameters = '{}';
			$node.Tid = "11111111-1111-1111-1111-111111111111";
			$svc.Core.AddToNodes($node);
			$result = $svc.Core.SaveChanges();
			
			#get the node
			$query = "Name eq '{0}' and ParentId eq {1}" -f $nodeName, $nodeParentId;
			$node = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
			#$node = Get-ApcNode -Name $nodeName -ParentId $nodeParentId | select;
			
			#ASSERT node
			$node | Should Not Be $null;
			$node.Id | Should Not Be $null;
			#get Id of the node
			$nodeId = $node.Id;
			
			#get the job of the node
			$job = Get-ApcNode -Id $nodeId -ExpandJob;
			$jobId = $job.Id;
			
			#create external node
			$extName = "external-test-node";
			$extNode = New-Object biz.dfch.CS.Appclusive.Api.Core.ExternalNode;
			$extNode.Name = $extName;
			$extNode.ExternalId = "509f27d7-4380-42fa-ac6d-0731c8f2111c";
			$extNode.ExternalType = "Cimi";
			$extNode.NodeId = $nodeId;
			$svc.Core.AddToExternalNodes($extNode);
			$result = $svc.Core.SaveChanges();
			
			$result.StatusCode | Should Be 201;
			#get the externa Node
			$query = "Name eq '{0}' and NodeId eq {1}" -f $extName, $nodeId;
			$extNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $query) | select;
			$extNode | Should Not Be $null;
			$extNodeId = $extNode.Id;
			
			#create ACL
			$aclName = "newTestAcl";
			$aclDescr = "Test Acl";
			$acl = New-Object biz.dfch.CS.Appclusive.Api.Core.Acl;
			$acl.Name = $aclName;
			$acl.Description = $aclDescr;
			$acl.EntityId = $nodeId;
			$acl.EntityKindId = 1;
			$acl.Tid = "11111111-1111-1111-1111-111111111111";
			$svc.Core.AddToAcls($acl);
			$result = $svc.Core.SaveChanges();
			
			#get ACL
			$query = "Name eq '{0}' and EntityId eq {1}" -f $aclName, $nodeId;
			$acl = $svc.Core.Acls.AddQueryOption('$filter', $query) | select;
			$acl | Should Not Be $null;
			$aclId = $acl.Id;
			
			#create ACE
			$aceName = "newTestAce";
			$aceDescr = "Test Ace";
			$ace = New-Object biz.dfch.CS.Appclusive.Api.Core.Ace;
			$ace.Name = $aceName;
			$ace.Description = $aceDescr;
			$ace.AclId = $aclId;
			$ace.Tid = "11111111-1111-1111-1111-111111111111";
			$username = $ENV:USERNAME;
			$query = "Name eq '{0}'" -f $username;
			$user = $svc.Core.Users.AddQueryOption('$filter', $query) | select;
			$userId = $user.Id;
			$ace.TrusteeId = $userId;
			$ace.TrusteeType = 1; #1 for users
			$ace.Type = 2;
			$ace.PermissionId = 2;
			$svc.Core.AddToAces($ace);
			$result = $svc.Core.SaveChanges();
			
			#get ACE
			$query = "Name eq '{0}' and AclId eq {1}" -f $aceName, $aclId;
			$ace = $svc.Core.Aces.AddQueryOption('$filter', $query) | select;
			$ace | Should Not Be $null;
			$aceId = $ace.Id;
			
			
			#ACT delete Node
			$query = "Id eq {0}" -f $nodeId;
			$node = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
			$svc.Core.DeleteObject($node);
			$result = $svc.Core.SaveChanges();
			
			#check that node is deleted
			$query = "Id eq {0}" -f $nodeId;
			$node = $svc.Core.Nodes.AddQueryOption('$filter', $query) | select;
			$node | Should Be $null;
			
			#check that Job is deleted
			$query = "Id eq {0}" -f $jobId;
			$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | select;
			$job | Should Be $null;
			
			#check that the external Node is Deleted
			$query = "Id eq {0}" -f $extNodeId;
			$extNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $query) | select;
			$extNode | Should Be $null;
			
			#check that the acl is Deleted
			$query = "Id eq {0}" -f $aclId;
			$acl = $svc.Core.Acls.AddQueryOption('$filter', $query) | select;
			$acl | Should Be $null;
			
			#check that the ace is deleted
			$query = "Id eq {0}" -f $aceId;
			$ace = $svc.Core.Aces.AddQueryOption('$filter', $query) | select;
			$ace | Should Be $null;
			
			
		}
		

		
		
	}
}