Import-Module biz.dfch.PS.Appclusive.Client

# Default service reference for connecting to Appclusive directly
$svc = Enter-Apc;
$apiBrokerBaseUrl = Get-ApcManagementUri -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.BaseUrl' -ValueOnly -svc $svc;

# Load information for creation of service reference for communication via Apigee
$oAuthAccessToken = Get-ApcManagementCredential -Name 'biz.dfch.CS.Appclusive.Core.Scs.Cmp.AccessToken' -svc $svc;
$oAuthCredential = New-Object System.Net.NetworkCredential('[AuthorisationBaererUser]', $oAuthAccessToken.Password);
Contract-Assert(!!$oAuthCredential);
$tenant = $svc.core.Tenants.AddQueryOption('$filter', "Name eq 'Managed Service Tenant'") | Select
Contract-Assert(!!$tenant);

# Create service reference for communication via Apigee
$apigeeSvc = Enter-Apc -ServerBaseUri $apiBrokerBaseUrl -BaseUrl '/v1/camp/' -Credential $oAuthCredential;
$apigeeSvc.Core.TenantHeaderName = 'Tenant-Id';
$apigeeSvc.Core.TenantID = $tenant.ExternalId;

$apigeeSvc.Core.EntityKinds;

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
