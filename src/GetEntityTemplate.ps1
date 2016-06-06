# With InvokeEntitySetActionWithSingleResult you can query arbitrary OData actions
# that operate on an entity set (i.e. EntityKinds as opposed to an entity such as 'EntityKind')
# which return a single object (hence WithSingleResult)

PS > $svc.Core.InvokeEntitySetActionWithSingleResult

OverloadDefinitions
-------------------
System.Object InvokeEntitySetActionWithSingleResult(string entitySetName, string actionName, type type, System.Object inputParameters)
System.Object InvokeEntitySetActionWithSingleResult(System.Object entity, string actionName, type type, System.Object inputParameters)
System.Object InvokeEntitySetActionWithSingleResult(string entitySetName, string actionName, System.Object type, System.Object inputParameters)
System.Object InvokeEntitySetActionWithSingleResult(System.Object entity, string actionName, System.Object type, System.Object inputParameters)
T InvokeEntitySetActionWithSingleResult[T](string entitySetName, string actionName, System.Object inputParameters)
T InvokeEntitySetActionWithSingleResult[T](System.Object entity, string actionName, System.Object inputParameters)

# to get the default parameters for a 'Product' execute the following:
PS > $svc.Core.InvokeEntitySetActionWithSingleResult('Products', 'Template', [biz.dfch.CS.Appclusive.Api.Core.Product], $null);

Type           : required
EntityKindId   : 0
ValidFrom      : 01.01.0001 00:00:00 +00:00
ValidUntil     : 31.12.9999 23:59:59 +00:00
EndOfLife      : 31.12.9999 23:59:59 +00:00
Parameters     : optional
Id             : 0
Tid            : 22222222-2222-2222-2222-222222222222
Name           : required
Description    : optional
CreatedById    : 1
ModifiedById   : 1
Created        : 06.06.2016 07:51:55 +02:00
Modified       : 06.06.2016 07:51:55 +02:00
RowVersion     :
CatalogueItems : {}
EntityKind     :
Tenant         :
CreatedBy      :
ModifiedBy     :

PS > $xml = Invoke-RestMethod 'https://appclusive/Appclusive/api/Core/$metadata' -UseDefaultCredentials;
PS > $xml.OuterXml |Out-File .\Core-Metadata.xml;

