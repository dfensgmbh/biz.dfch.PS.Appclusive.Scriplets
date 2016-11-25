import-module biz.dfch.PS.Appclusive.Client
import-module biz.dfch.PS.Cimi.Client

$apc = Enter-Apc;
$Svcs = @{Apc = $apc}

$OAuthBaseUrl = Get-ApcManagementUri -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.OAuth2BaseUrl' -ValueOnly -svc $Svcs.Apc;
$ApiBrokerBaseUrl = Get-ApcManagementUri -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.BaseUrl' -ValueOnly -svc $Svcs.Apc;
$CredOAuth2BaseUrl = Get-ApcManagementCredential -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.OAuth2BaseUrl' -As 'PSCredential' -svc $Svcs.Apc;
$CredAccessRefreshToken = Get-ApcManagementCredential -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.AccessRefreshToken' -svc $Svcs.Apc;
$AccessRefreshToken = $CredAccessRefreshToken.Password;
$TenantId = Get-ApcKeyNameValue -Key 'biz.dfch.CS.Appclusive.Core.Scs.Cmp' -Name 'tenantId' -ValueOnly -svc $Svcs.Apc;
$Svcs['Cimi'] = Enter-CimiServer -OAuthBaseUrl $OAuthBaseUrl -ApiBrokerBaseUrl $ApiBrokerBaseUrl -Credential $CredOAuth2BaseUrl -AccessRefreshToken $AccessRefreshToken -TenantId $TenantId;

$nodeId = NODE_ID_HERE;
$Node = Get-ApcNode -Id $nodeId -svc $Svcs.Apc;
$Job = $Svcs.Apc.Core.Jobs.AddQueryOption('$filter', ("EntityKindId eq 1 and RefId eq '{0}'" -f $Node.Id)) | Select;

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
