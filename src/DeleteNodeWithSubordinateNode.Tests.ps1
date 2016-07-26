Describe -Tags "DeleteNodeWithSubordinateNode.Tests" "DeleteNodeWithSubordinateNode.Tests" {

    Context "#CLOUDTCL-Warmup" {
	
		BeforeEach {
		$moduleName = 'biz.dfch.PS.Appclusive.Client';
		Remove-Module $moduleName -ErrorAction:SilentlyContinue;
		Import-Module $moduleName;
		$svc = Enter-ApcServer;
		}
	
		It "ServiceReference-MustBeInitialised" -Test {
			$svc | Should Not Be $null;
		}
	}
	
	Context "#CLOUDTCL-DeleteNodeWithSubordinateNode" {
		It "ServiceReference-MustBeInitialised" -Test {
			#ARRANGE
			$nodeName = "newtestnode";
			
			#ACT create Node
			$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
			$node.Name = $nodeName;
			$node.ParentId = 1680;
			$node.EntityKindId = 1;
			$node.Parameters = '{}';
			$svc.Core.AddToNodes($node);
			$result = $svc.Core.SaveChanges();
			
			
			#get the node
			$query = "Name eq '{0}'" -f $nodeName;
			$node = $svc.Core.Nodes.AddQueryOption('$filter', $query);
			
			#ASSERT node
			$node | Should Not Be $null;
			$node.Id | Should Not Be $null;
			#get Id of the node
			$nodeId = $node.Id;
			
			#get the job of the node
			$job = Get-ApcNode -Id $nodeId -ExpandJob;
			$jobId = $job.Id;
			
			#create subordinate Node
			#ARRANGE
			$childName = "newtestnode-Child";
			
			#ACT create child Node
			$childNode = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
			$childNode.Name = $childName;
			$childNode.ParentId = $nodeId; #it gets the id of the 1st node as parent Node
			$childNode.EntityKindId = 1;
			$childNode.Parameters = '{}';
			$svc.Core.AddToNodes($childNode);
			$result = $svc.Core.SaveChanges();
			
			#get child Node
			$query = "Name eq '{0}'" -f $childName;
			$childNode = $svc.Core.Nodes.AddQueryOption('$filter', $query);
			
			#ASSERT child Node
			$childNode | Should Not Be $null;
			$childNode.Id | Should Not Be $null;
			$childNode.ParentId | Should Be $nodeId;
			
			$childId = $childNode.Id;
			
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
			
			
			#remove Node
			#$svc.Core.DeleteObject($node);
			#$result = $svc.Core.SaveChanges();
			Remove-ApcNode -id $childId;
			
			#ASSERT that child Node is not deleted
			$query = "Id eq '{0}'" -f $childId;
			$childNode = $svc.Core.Nodes.AddQueryOption('$filter', $query);
			Contract-Assert(!!$childNode);
			
			
		}
		

		
		
	}
}