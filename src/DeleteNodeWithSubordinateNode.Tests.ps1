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
			
			#remove Node
			$svc.Core.DeleteObject($node);
			$result = $svc.Core.SaveChanges();
			
		}
		

		
		
	}
}