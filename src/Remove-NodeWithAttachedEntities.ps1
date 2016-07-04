PARAM
(
	[long] $Id
)

Contract-Requires (0 -lt $Id);

$svc = Enter-ApcServer;

$q = "Id eq {0}" -f $Id;
$node = $svc.Core.Nodes.AddQueryOption('$filter', $q) | Select;
Contract-Assert (!!$node)
$node

$q = "NodeId eq {0}" -f $Id;
$extNode = $svc.Core.ExternalNodes.AddQueryOption('$filter', $q) | Select;
Contract-Assert (!!$extNode)
Contract-Assert ($Id -ne $extNode.Id)
$extNode

$q = "ExternaldNodeId eq {0}" -f $extNode.Id;
$externalNodeBags = $svc.Core.ExternalNodeBags.AddQueryOption('$filter', $q) | Select;
Contract-Assert (!!$externalNodeBags)
$externalNodeBags

foreach($externalNodeBag in $externalNodeBags)
{
	$svc.Core.DeleteObject($externalNodeBag);
	$result = $svc.Core.SaveChanges();
	$result
}

$svc.Core.DeleteObject($extNode);
$result = $svc.Core.SaveChanges();
$result

$q = "ParentId eq {0}" -f $Id;
$childNodes = $svc.Core.Nodes.AddQueryOption('$filter', $q) | Select;
Contract-Assert (!!$childNodes)
$childNodes

foreach($childNode in $childNodes)
{
	$svc.Core.DeleteObject($childNode);
	$result = $svc.Core.SaveChanges();
	$result
}

$q = "RefId eq '{0}'" -f $Id;
$job = $svc.Core.Jobs.AddQueryOption('$filter', $q) | Select;
Contract-Assert (!!$job)
Contract-Assert (1 -eq $job.Count)
$job
$svc.Core.DeleteObject($job);
$result = $svc.Core.SaveChanges();
$result

$q = "EntityId eq {0} and EntityKindId eq {1}" -f 34394, 31;
$entityBags = $svc.Core.EntityBags.AddQueryOption('$top', 1);
Contract-Assert (!!$entityBags)
foreach($entityBag in $entityBags)
{
	$svc.Core.DeleteObject($entityBag);
	$result = $svc.Core.SaveChanges();
	$result
}

$svc.Core.DeleteObject($node);
$result = $svc.Core.SaveChanges();
$result
