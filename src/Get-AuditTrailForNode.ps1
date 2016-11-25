# have a logged in Appclusive session ready ...
PS > $svc
Name                           Value
----                           -----
Diagnostics    biz.dfch.CS.Appclusive.Api.Diagnostics.Diagnostics
Infrastructure biz.dfch.CS.Appclusive.Api.Infrastructure.Infrastructure
Cmp            biz.dfch.CS.Appclusive.Api.Cmp.Cmp
Core           biz.dfch.CS.Appclusive.Api.Core.Core
Csm            biz.dfch.CS.Appclusive.Api.Csm.Csm

# this is the node where we want to track changes from 
PS > $nodeId = 35160L
PS > $q = "Id eq {0}" -f $nodeId;
# get the node ...
PS > $node = $svc.Core.Nodes.AddQueryOption('$filter', $q) | Select
# ... and make sure it exists ...
PS > Contract-Assert (!!$node)
# ... and finally show the node
PS > $node
EntityId       :
Parameters     : {}
EntityKindId   : 31
ParentId       : 1680
Id             : 35160
Tid            : ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe
Name           : SQLTestLorenz10
Description    : SQLTestLorenz10
CreatedById    : 1038
ModifiedById   : 1038
Created        : 6/30/2016 5:31:25 PM +02:00
Modified       : 6/30/2016 5:31:25 PM +02:00
RowVersion     : {0, 0, 0, 0...}
Parent         :
EntityKind     :
Children       : {}
IncomingAssocs : {}
OutgoingAssocs : {}
Tenant         :
CreatedBy      :
ModifiedBy     :

# prepare the query for the Job of the Node ...
PS > $q = "RefId eq '{0}'" -f $node.Id;
# ... get the Job of the node ...
PS > $job = $svc.Core.Jobs.AddQueryOption('$filter', $q) | Select
# ... and make sure the Job exists ...
PS > Contract-Assert (!!$job)
# ... and finally show the Job
PS > $job
Status              : InitialState
RefId               : 35160
Token               : optional
TenantId            : 00000000-0000-0000-0000-000000000000
EntityKindId        : 1
Parameters          : optional
Condition           : Initialise
ConditionParameters :
Error               : {"Version":"1","Succeeded":false,"Code":4,"Message":"Loading addresses of network FAILED","Description":"","InnerJobResult":null}
EndTime             :
ParentId            : 1647
Id                  : 38371
Tid                 : ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe
Name                : Loading addresses of network FAILED
Description         :
CreatedById         : 1038
ModifiedById        : 1038
Created             : 6/30/2016 5:31:25 PM +02:00
Modified            : 6/30/2016 5:31:25 PM +02:00
RowVersion          : {0, 0, 0, 0...}
EntityKind          :
Parent              :
Children            : {}
Tenant              :
CreatedBy           :
ModifiedBy          :

# prepare the query for the AuditTrail ...
PS > $q = "EntityId eq '{0}'" -f $job.Id;
# ... and get the the Audit Trail entries
PS > $auditTrails = $svc.Diagnostics.AuditTrails.AddQueryOption('$filter', $q) | Select;
PS > Contract-Assert (!!$auditTrails)
# show all modifications for that Node
PS > $auditTrails
EntityId     : 38371
EntityType   : Job
EntityState  : Modified
Original     : {"Description":"biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node","Error":"","Name":"biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node"}
Current      : {"Description":"","Error":"{\"Version\":\"1\",\"Succeeded\":false,\"Code\":4,\"Message\":\"Loading addresses of network
               FAILED\",\"Description\":\"\",\"InnerJobResult\":null}","Name":"Loading addresses of network FAILED"}
Id           : 376086
Tid          : ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe
Name         : Loading addresses of network FAILED
Description  : Job-38371-Modified
CreatedById  : 1038
ModifiedById : 1038
Created      : 6/30/2016 5:31:25 PM +02:00
Modified     : 6/30/2016 5:31:25 PM +02:00
RowVersion   : {0, 0, 0, 0...}
Tenant       :
CreatedBy    :
ModifiedBy   :

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
