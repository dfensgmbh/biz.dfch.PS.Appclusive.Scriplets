$machineJobId = ID_OF_THE_MACHINE_JOB;

Import-Module biz.dfch.PS.Appclusive.Client
$svc = Enter-Apc;

# Load machine job and corresponding node
$machineJob = $svc.Core.Jobs.AddQueryOption('$filter', ("Id eq {0}" -f $machineJobId)) | Select;
$machineNode = $svc.core.Nodes.AddQueryOption('$filter', ("Id eq {0}" -f $machineJob.RefId)) | Select;

# Load EntityBags that belong to machine
$entityBags = $svc.Core.EntityBags.AddQueryOption('$filter', "EntityKindId eq 31 and EntityId eq {0}" -f $machineNode.Id) | Select;

# Delete EntityBags
foreach ($entityBag in $entityBags)
{
	$svc.Core.DeleteObject($entityBag);
	$null = $svc.Core.SaveChanges();
}

# Load ExternalNode
$externalNode = $svc.core.ExternalNodes.AddQueryOption('$filter', ("NodeId eq {0}" -f $machineNode.Id)) | Select;

# Delete ExternalNode and ExternalNodeBags that belong to ExternalNode
if ($externalNode)
{
	$externalNodeBags = $svc.core.ExternalNodeBags.AddQueryOption('$filter', ("ExternalNodeId eq {0}" -f $externalNode.Id)) | Select;
	foreach ($externalNodeBag in $externalNodeBags)
	{
		$svc.Core.DeleteObject($externalNodeBag);
		$null = $svc.Core.SaveChanges();
	}
	
	$svc.Core.DeleteObject($externalNode);
	$null = $svc.Core.SaveChanges();
}

$svc.Core.DeleteObject($machineNode);
$null = $svc.Core.SaveChanges();

$svc.Core.DeleteObject($machineJob);
$null = $svc.Core.SaveChanges();