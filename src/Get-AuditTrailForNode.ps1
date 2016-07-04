PS > $svc
Name                           Value
----                           -----
Diagnostics    biz.dfch.CS.Appclusive.Api.Diagnostics.Diagnostics
Infrastructure biz.dfch.CS.Appclusive.Api.Infrastructure.Infrastructure
Cmp            biz.dfch.CS.Appclusive.Api.Cmp.Cmp
Core           biz.dfch.CS.Appclusive.Api.Core.Core
Csm            biz.dfch.CS.Appclusive.Api.Csm.Csm

PS > $nodeId = 35160L
PS > $q = "Id eq {0}" -f $nodeId;
PS > $node = $svc.Core.Nodes.AddQueryOption('$filter', $q) | Select
PS > Contract-Assert (!!$node)
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

PS > $q = "RefId eq '{0}'" -f $node.Id;
PS > $job = $svc.Core.Jobs.AddQueryOption('$filter', $q) | Select
PS > Contract-Assert (!!$job)
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

PS > $q = "EntityId eq '{0}'" -f $job.Id;
PS > $auditTrails = $svc.Diagnostics.AuditTrails.AddQueryOption('$filter', $q) | Select;
PS > Contract-Assert (!!$auditTrails)
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
