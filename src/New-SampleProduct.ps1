#Requires -Modules @{ ModuleName = 'biz.dfch.PS.Appclusive.Client'; ModuleVersion = "4.2.1" }

# IMPORTANT - This script has to be runned as SYSTEM user

PARAM
(
	[Parameter(Mandatory=$true)]
	[string] $TenantId
)

$svc = Enter-ApcServer;

# Constants
$catalogueEntitySet = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Catalogue';
$catalogueItemEntitySet = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.CatalogueItem';

$sampleProductEntityKindName = 'com.swisscom.cms.sample';
$sampleProductEntityKindVersion = 'com.swisscom.cms.sample.v001';
$sampleProductName = 'CMS Sample Product';
$sampleCatalogueName = 'Cloud Managed Services';


function CreateAndPersistKeyNameValueIfNotExists($svc, $Key, $Name, $Value)
{
	$knv = Get-ApcKeyNameValue -svc $svc -Key $Key -Name $Name;
	
	if (!$knv)
	{
		$newKnv = New-Object biz.dfch.CS.Appclusive.Api.Core.KeyNameValue;
		$newKnv.Key = $Key;
		$newKnv.Name = $Name;
		$newKnv.Value = $Value;
		$svc.Core.AddToKeyNameValues($newKnv);
		$null = $svc.Core.SaveChanges();
	}
}

# Create EntityKind
$sampleProductEntityKind = Get-ApcEntityKind -Version $sampleProductEntityKindVersion;

if (!$sampleProductEntityKind)
{
	$sampleProductEntityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
	$sampleProductEntityKind.Name = $sampleProductEntityKindName;
	$sampleProductEntityKind.Description = "Sample Product";
	$sampleProductEntityKind.Version = $sampleProductEntityKindVersion;
	$sampleProductEntityKind.Parameters = '{"InitialState-Initialise":"Created","Created-Run":"Running","Created-Delete":"Deleted","Running-Stop":"Stopped","Stopped-Decommission":"Decomissioned"}';
	
	$svc.Core.AddToEntityKinds($sampleProductEntityKind);
	$null = $svc.Core.SaveChanges();

	Contract-Assert ($sampleProductEntityKind.Id -gt 0);
}


# Create Product
$sampleProduct = Get-ApcProduct -Name $sampleProductName;

if (!$sampleProduct)
{
	$sampleProduct = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$sampleProduct.Type = $sampleProductEntityKindName;
	$sampleProduct.Name = $sampleProductName;
	$sampleProduct.EntityKindId = $sampleProductEntityKind.Id;
	$sampleProduct.Description = $sampleProduct.Name;
	$sampleProduct.ValidFrom = [System.DateTimeOffset]::MinValue;
	$sampleProduct.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$sampleProduct.EndOfLife = [System.DateTimeOffset]::MaxValue;
	
	$svc.Core.AddToProducts($sampleProduct);
	$result = $svc.Core.SaveChanges();
	
	Contract-Assert ($result.StatusCode -eq 201);
	Contract-Assert (!!$sampleProduct.Id -gt 0);
}


# Create KNVs for Action UI definitions
$actionUiDefinition = '{ "displayText": "Order Full Server OS Management", "configSteps": [ { "key": "vmAdminCredentials", "stepLabel": "Credentials", "schema": { "title": "Built-in Administrator Account", "type": "object", "properties": { "username": { "title": "Username", "type": "string", "required": true }, "password": { "title": "Password", "type": "string", "required": true } } }, "form": [ { "key": "username", "description": "Built-in Administrator" }, { "key": "password", "type": "password" } ] }, { "key": "serviceConfig", "stepLabel": "Configuration", "schema": { "title": "OS Management Configuration", "type": "object", "required": [ "supportTime", "maintenanceWindow", "emergencyPatches" ], "properties": { "supportTime": { "title": "Support Time", "type": "string", "enum": [ "officeHours", "24x7" ], "default": "officeHours", "required": true }, "maintenanceWindow": { "title": "Maintenance Window", "type": "string", "enum": [ "weekend1OfMonth", "weekend3OfMonth" ], "default": "weekend1OfMonth", "required": true }, "autoApplyPatches": { "title": "Regular Security Patches", "type": "boolean", "default": true, "required": true }, "emergencyPatches": { "title": "Emergency Patches", "type": "boolean", "default": true, "required": true }, "customerAlarmingTargetList": { "title": "Alarming Contact", "type": "string", "pattern": "^\\S+@\\S+$", "validationMessage": "Enter a valid email address", "placeholder": "support@example.com" }, "frozenZone": { "type": "array", "title": "Frozen Zone", "items": { "type": "object", "title": "Time Period", "properties": { "dateTimeFrom": { "title": "From", "type": "string", "format": "date-time" }, "dateTimeTo": { "title": "To", "type": "string", "format": "date-time" }, "required": [ "dateTimeFrom", "dateTimeTo" ] } }, "validationMessage": "Either a From-To timespan is not valid, or you have select only one date. In this case remove the Frozen Zone." } } }, "form": [ { "key": "supportTime", "type": "radios", "disableSuccessState": true, "titleMap": [ { "value": "officeHours", "name": "Office Hours" }, { "value": "24x7", "name": "7 x 24" } ] }, { "key": "emergencyPatches", "type": "radios", "disableSuccessState": true, "description": " Specify whether emergency updates can be automatically installed, also outside of the maintenance window", "titleMap": [ { "value": true, "name": "Enforce installation of emergency patches" }, { "value": false, "name": "Just send me a notification about emergency patches" } ] }, { "key": "maintenanceWindow", "type": "radios", "disableSuccessState": true, "titleMap": [ { "value": "weekend1OfMonth", "name": "1st Saturday/Sunday of the month" }, { "value": "weekend3OfMonth", "name": "3rd Saturday/Sunday of the month" } ] }, { "key": "customerAlarmingTargetList", "description": "Enter an email address to receive notifications" }, { "key": "frozenZone", "description": "Choose one or multiple frozen zones during which no changes should be applied to the OS (e.g installation of patches)", "style": { "add": "btn-success" }, "items": [ "frozenZone[].dateTimeFrom", "frozenZone[].dateTimeTo" ], "customValidation": "function (){var formData=vm.stepModel[''frozenZone''];var noError = true; angular.forEach(formData, function(data) { if (!!data.dateTimeFrom &amp;&amp; !!data.dateTimeTo &amp;&amp; new Date(data.dateTimeFrom) &gt;= new Date(data.dateTimeTo) || (!data.dateTimeFrom &amp;&amp; !!data.dateTimeTo) || (!data.dateTimeTo &amp;&amp; !!data.dateTimeFrom)) { noError = false; }}); $scope.$broadcast(''schemaForm.error.frozenZone'', ''smthng'', undefined, noError);}" } ] }, { "key": "confirmation", "stepLabel": "Confirm", "schema": { "type": "object", "title": "Confirm Setup", "properties": { "foo": { "type": "boolean" } } }, "form": [ { "type": "help", "helpvalue": "&lt;p&gt;Please verify your entered values below.&lt;/p&gt;" }, { "type": "template", "template": "&lt;p&gt;Username: &lt;b&gt;{{form.context.configModel.vmAdminCredentials.username}}&lt;/b&gt;&lt;/p&gt;" }, { "type": "template", "template": "&lt;p&gt;Password: &lt;b&gt;{{form.context.configModel.vmAdminCredentials.password}}&lt;/b&gt;&lt;/p&gt;" }, { "type": "template", "template": "&lt;p&gt;Support Time: &lt;b&gt;{{form.context.configModel.serviceConfig.supportTime}}&lt;/b&gt;&lt;/p&gt;" }, { "type": "template", "template": "&lt;p&gt;Emergency Patches: &lt;b&gt;{{form.context.configModel.serviceConfig.emergencyPatches}}&lt;/b&gt;&lt;/p&gt;" }, { "type": "template", "template": "&lt;p&gt;Maintenance Window: &lt;b&gt;{{form.context.configModel.serviceConfig.maintenanceWindow}}&lt;/b&gt;&lt;/p&gt;" }, { "type": "template", "template": "&lt;p&gt;Alarming Contact: &lt;b&gt;{{form.context.configModel.serviceConfig.customerAlarmingTargetList}}&lt;/b&gt;&lt;i ng-if=\"!form.context.configModel.configModel.serviceConfig.customerAlarmingTargetList\"&gt;N/A&lt;/i&gt;&lt;/p&gt;" }, { "type": "template", "template": "&lt;p ng-init=\"form.context.configModel.serviceConfig.frozenZone.hasEntries = false\"&gt;&lt;b&gt;Frozen Zone(s):&lt;/b&gt;&lt;/p&gt;&lt;p ng-repeat=\"fZ in form.context.configModel.serviceConfig.frozenZone track by $index\" ng-if=\"fZ.dateTimeFrom &amp;&amp; fZ.dateTimeTo &amp;&amp; (form.context.configModel.serviceConfig.frozenZone.hasEntries = true)\"&gt;&lt;em&gt;from:&lt;/em&gt; {{fZ.dateTimeFrom | date:''medium''}} &lt;em&gt;to:&lt;/em&gt; {{fZ.dateTimeTo | date:''medium''}}&lt;/p&gt;&lt;p ng-hide=\"form.context.configModel.serviceConfig.frozenZone.hasEntries\"&gt;&lt;i&gt;N/A&lt;/i&gt;&lt;/p&gt;" }, { "type": "help", "helpvalue": "&lt;i&gt;To Order Full Server OS Management press ''Finish''.&lt;/i&gt;" } ] } ] }';
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $sampleProductEntityKindVersion -Name 'Action-Initialise' -Value $actionUiDefinition;
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $sampleProductEntityKindVersion -Name 'Action-Run' -Value $actionUiDefinition;
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $sampleProductEntityKindVersion -Name 'Action-Delete' -Value $actionUiDefinition;
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $sampleProductEntityKindVersion -Name 'Action-Stop' -Value $actionUiDefinition;
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $sampleProductEntityKindVersion -Name 'Action-Decommission' -Value $actionUiDefinition;

# Create KNV for EntCloudPortalUIProductDetails
$entCloudPortalUiProductsDetailsValue = '{"schema":{"type":"object","title":"Edit screen","properties":{"foo":{"type":"boolean"}}},"form":[{"type":"template","template":"<div><p><em>Product:</em> {{form.context.product.Name}}</p></div>"},{"type":"template","template":"<div><p><em>Node ID:</em> {{form.context.node.Id}}</p></div>"},{"type":"template","template":"<div><p><em>Created:</em> {{form.context.node.Created}}</p></div>"},{"type":"template","template":"<div><p><em>Maintenance Window:</em> {{form.context.node.Parameters.MaintenanceWindow}}</p></div>"},{"type":"template","template":"<div><p><em>Support Hours:</em> {{form.context.node.Parameters.SupportHours}}</p></div>"},{"type":"template","template":"<div><p><em>Frozen Zones:</em></p></div><div ng-repeat=\"zone in form.context.node.Parameters.FrozenZone track by $index\"><div><p><em>from:</em> {{zone.from}}</p></div><div><p><em>to:</em> {{zone.to}}</p></div></div>"},{"type":"template","template":"<div><p><em>Last successful Compliance Check:</em> {{form.context.node.Parameters.LastSuccessfulComplianceCheck}}</p></div>"},{"type":"template","template":"<div><p><em>Compliance Checks Exception List:</em> {{form.context.node.Parameters.ComplianceCheckExceptionList}}</p></div>"},{"type":"template","template":"<div><p><em>Local Admin Exception List:</em> {{form.context.node.Parameters.localAdminExceptionListObjects}}</p></div>"}]}';
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $sampleProductEntityKindVersion -Name 'EntCloudPortalUIProductDetails-default' -Value $entCloudPortalUiProductsDetailsValue;

# Create KNV for Icon
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $sampleProductEntityKindVersion -Name 'Icon-default' -Value 'picto-server';

# Create KNV for Translation
$translationValue = '{ "AB01OrderFullOSManagement": "Order Full Managed", "AF01OrderLimitedManaged": "Order Limited Managed", "FA01ReturnToUnmanaged": "Return to Unmanaged", "FG01EnableLimitedCustomerMaintenance": "Enable Limited Customer Maintenance", "FB01OrderFullManaged": "Order Full Managed", "GA01ReturnToUnamanaged": "Return to Unmanaged", "GF01ReturnToLimitedManaged": "Return to Limited Managed", "BA01ReturnToUnmanaged": "Return to Unmanaged", "BD01EnableFullCustomerMaintenance": "Enable Full Customer Maintenance", "BF01ReturnToLimitedManaged": "Switch to Limited Managed", "DB01DisableCustomerMaintenance": "Disable Customer Maintenance", "DA01ReturnToUnmanaged": "Return to Unmanaged", "DE01TempAdmin": "Temp Admin", "ED01RevokeTempAdmin": "Revoke TempAdmin", "EA01ReturnToUnmanaged": "Return to Unmanaged", "EG01SwitchToLimitedManaged": "Switch to Limited Managed", "EE01GetCredentials": "Get Credentials", "DD01StartVM": "Start VM", "DD02StopVM": "Stop VM", "DD03RestartVM": "Restart VM", "GG01StartVM": "Start VM", "GG02StopVM": "Stop VM", "GG03RestartVM": "Restart VM", "FF01Edit": "Edit", "BB01Edit": "Edit", "CB01ReturnToFullManaged": "Return to Full Managed", "CF01ReturnToLimitedManaged": "Return to Limited Managed", "FC01SetMaintenance": "Set Provider Maintenance", "AZ01Decommission": "Decommission Service" }';
CreateAndPersistKeyNameValueIfNotExists -svc $svc -Key $sampleProductEntityKindVersion -Name 'Translation-1033' -Value $translationValue;


# Create Catalogue
Set-ApcSessionTenant -Id $TenantId -svc $svc;

$query = "Name eq '{0}' and Tid eq guid'{1}'" -f $sampleCatalogueName, $TenantId;
$catalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | Select;

if (!$catalogue)
{
	$catalogue = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
	$catalogue.Name = $sampleCatalogueName;
	$catalogue.Description = 'CMS Sample Catalogue';
	$catalogue.Version = '1.0';
	$catalogue.Status = "Published";
	
	$svc.Core.AddToCatalogues($catalogue);
	$result = $svc.Core.SaveChanges();
	
	Contract-Assert ($result.StatusCode -eq 201);
	Contract-Assert ($catalogue.Id -gt 0);
}

	
# Create CatalogueItem
$query = "Name eq '{0}' and Tid eq guid'{1}'" -f $sampleProductName, $TenantId;
$catalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | Select;

if (!$catalogueItem)
{
	$catalogueItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$catalogueItem.Name = $sampleProductName;
	$catalogueItem.Description = $catalogueItem.Name;
	$catalogueItem.Parameters = '{}';
	$catalogueItem.ProductId = $sampleProduct.Id;
	$catalogueItem.CatalogueId = $catalogue.Id;
	$catalogueItem.ValidFrom = [System.DateTimeOffset]::MinValue;
	$catalogueItem.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$catalogueItem.EndOfLife = [System.DateTimeOffset]::MaxValue;

	$svc.Core.AddToCatalogueItems($catalogueItem);
	$result = $svc.Core.SaveChanges();

	Contract-Assert ($result.StatusCode -eq 201);
	Contract-Assert (!!$catalogueItem.Id -gt 0);
}

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
