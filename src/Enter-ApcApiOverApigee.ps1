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
