function CreateNode($nodeName, $nodeDescription, $nodeParentId) 
{

	$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
	$node.ParentId = $nodeParentId;
	$node.Name = $NodeName;
	$node.Description = $nodeDescription;
	$node.Parameters = '{}';
	$node.Type = $node.GetType().FullName;
	$node.Created = [System.DateTimeOffset]::Now;
	$node.Modified = $node.Created;
	$node.CreatedBy = $ENV:USERNAME;
	$node.ModifiedBy = $node.CreatedBy;
	$node.Tid = "11111111-1111-1111-1111-111111111111";
	$node.Id = 0;
	return $node;
}
