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

# to get the complete metadata for an endpoint you can query $metadata
# which is available for each endpoint

PS > $xml = Invoke-RestMethod 'https://appclusive/Appclusive/api/Core/$metadata' -UseDefaultCredentials;
PS > $xml.OuterXml |Out-File .\Core-Metadata.xml;

# you can query all available endpoints via
PS > $svc.Diagnostics.Endpoints

Version       : 0.0.0.0
Address       : https://appclusive/
RouteTemplate :
RoutePrefix   : /
ServerRole    : HOST
Priority      : 0
Id            : 1
Tid           : 11111111-1111-1111-1111-111111111111
Name          : BaseUri
Description   :
CreatedById   : 1
ModifiedById  : 1
Created       : 06.06.2016 04:56:18 +02:00
Modified      : 06.06.2016 04:56:18 +02:00
RowVersion    :
Tenant        :
CreatedBy     :
ModifiedBy    :

Version       : 2.1.3.31404
Address       : https://appclusive/Appclusiveapi/Cmp
RouteTemplate : /Appclusiveapi/Cmp/{*odataPath}
RoutePrefix   : /Appclusiveapi/Cmp
ServerRole    : HOST
Priority      : 2147483632
Id            : 2
Tid           : 11111111-1111-1111-1111-111111111111
Name          : Cmp
Description   :
CreatedById   : 1
ModifiedById  : 1
Created       : 06.06.2016 04:56:18 +02:00
Modified      : 06.06.2016 04:56:18 +02:00
RowVersion    :
Tenant        :
CreatedBy     :
ModifiedBy    :

Version       : 2.1.3.31404
Address       : https://appclusive/Appclusiveapi/Core
RouteTemplate : /Appclusiveapi/Core/{*odataPath}
RoutePrefix   : /Appclusiveapi/Core
ServerRole    : HOST
Priority      : 2147483646
Id            : 3
Tid           : 11111111-1111-1111-1111-111111111111
Name          : Core
Description   :
CreatedById   : 1
ModifiedById  : 1
Created       : 06.06.2016 04:56:18 +02:00
Modified      : 06.06.2016 04:56:18 +02:00
RowVersion    :
Tenant        :
CreatedBy     :
ModifiedBy    :

Version       : 2.1.3.31404
Address       : https://appclusive/Appclusiveapi/Diagnostics
RouteTemplate : /Appclusiveapi/Diagnostics/{*odataPath}
RoutePrefix   : /Appclusiveapi/Diagnostics
ServerRole    : HOST
Priority      : 2147483647
Id            : 4
Tid           : 11111111-1111-1111-1111-111111111111
Name          : Diagnostics
Description   :
CreatedById   : 1
ModifiedById  : 1
Created       : 06.06.2016 04:56:18 +02:00
Modified      : 06.06.2016 04:56:18 +02:00
RowVersion    :
Tenant        :
CreatedBy     :
ModifiedBy    :

Version       : 2.1.3.31404
Address       : https://appclusive/Appclusiveapi/Infrastructure
RouteTemplate : /Appclusiveapi/Infrastructure/{*odataPath}
RoutePrefix   : /Appclusiveapi/Infrastructure
ServerRole    : HOST
Priority      : 2147483627
Id            : 5
Tid           : 11111111-1111-1111-1111-111111111111
Name          : Infrastructure
Description   :
CreatedById   : 1
ModifiedById  : 1
Created       : 06.06.2016 04:56:18 +02:00
Modified      : 06.06.2016 04:56:18 +02:00
RowVersion    :
Tenant        :
CreatedBy     :
ModifiedBy    :

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
