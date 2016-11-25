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

#
# Copyright 2016 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

