#Requires -Modules biz.dfch.PS.Appclusive.Client

PARAM
(
	[Parameter(Mandatory = $false)]
	[switch] $Recreate = $true
)

Remove-Module biz.dfch.PS.Appclusive.Client -ErrorAction:SilentlyContinue;
Import-Module biz.dfch.PS.Appclusive.Client -Prefix Appclusive;

function Aces($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$aces = $svc.Core.Aces | Select;
	DeleteItems -svc $svc -items $aces;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function Acls($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$acls = $svc.Core.Acls | Select;
	DeleteItems -svc $svc -items $acls;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function Approvals($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$approvals = $svc.Core.Approvals | Select;
	DeleteItems -svc $svc -items $approvals;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function AuditTrails($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$auditTrails = $svc.Core.AuditTrails | Select;
	DeleteItems -svc $svc -items $auditTrails;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function Carts($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$carts = $svc.Core.Carts | Select;
	DeleteItems -svc $svc -items $carts;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function Catalogues($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$catalogues = $svc.Core.Catalogues | Select;
	DeleteItems -svc $svc -items $catalogues;

	if(!$Recreate)
	{
		return;
	}
	
	$svc = Enter-AppclusiveServer;

	$catName = 'Default DaaS'

	$cat = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
	$svc.Core.AddToCatalogues($cat);
	$cat.Status = "Published";
	$cat.Version = 1;
	$cat.Name = "Default DaaS";
	$cat.Description = "Default catalogue for DaaS VDI";
	$cat.Created = [System.DateTimeOffset]::Now;
	$cat.Modified = $cat.Created;
	$cat.CreatedBy = "SYSTEM";
	$cat.ModifiedBy = $cat.CreatedBy;
	$cat.Tid = "1";
	$cat.Id = 0;
	$svc.Core.UpdateObject($cat);
	$svc.Core.SaveChanges();
}

function CatalogueItems($Recreate) 
{
	if(!$Recreate)
	{
		return;
	}

	$svc = Enter-AppclusiveServer;

	$catName = 'Default DaaS'
	$cat = $svc.Core.Catalogues |? Name -eq $catName;
	
	$productName = 'VDI Personal';
	$product = $svc.Core.Products |? Name -eq $productName;

	$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$svc.Core.AddToCatalogueItems($catItem);
	$svc.Core.SetLink($catItem, "Catalogue", $cat);
	$catItem.CatalogueId = $cat.Id;
	$catItem.ProductId = $product.Id;
	$catItem.Name = $productName;
	$catItem.Description = 'VDI (Virtual Desktop Infrastructure) for personal use';
	$catItem.Created = [System.DateTimeOffset]::Now;
	$catItem.Modified = $catItem.Created;
	$catItem.ValidFrom = [System.DateTimeOffset]::MinValue;
	$catItem.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$catItem.EndOfSale = [System.DateTimeOffset]::MaxValue;
	$catItem.EndOfLife = [System.DateTimeOffset]::MaxValue;
	$catItem.CreatedBy = "SYSTEM";
	$catItem.ModifiedBy = $catItem.CreatedBy;
	$catItem.Tid = "1";
	$catItem.Id = 0;
	$svc.Core.UpdateObject($catItem);
	$svc.Core.SaveChanges();

	$productName = 'VDI Technical';
	$product = $svc.Core.Products |? Name -eq $productName;
	
	$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$catItem;
	$svc.Core.AddToCatalogueItems($catItem);
	$svc.Core.SetLink($catItem, "Catalogue", $cat);
	$catItem.CatalogueId = $cat.Id;
	$catItem.ProductId = $product.Id;
	$catItem.Name = $productName;
	$catItem.Description = 'VDI (Virtual Desktop Infrastructure) for someone else';
	$catItem.Created = [System.DateTimeOffset]::Now;
	$catItem.Modified = $catItem.Created;
	$catItem.ValidFrom = [System.DateTimeOffset]::MinValue;
	$catItem.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$catItem.EndOfSale = [System.DateTimeOffset]::MaxValue;
	$catItem.EndOfLife = [System.DateTimeOffset]::MaxValue;
	$catItem.CreatedBy = "SYSTEM";
	$catItem.ModifiedBy = $catItem.CreatedBy;
	$catItem.Tid = "1";
	$catItem.Id = 0;
	$svc.Core.UpdateObject($catItem);
	$svc.Core.SaveChanges();
	
	$productName = 'DSWR Autocad 12 Production';
	$product = $svc.Core.Products |? Name -eq $productName;
	
	$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$catItem;
	$svc.Core.AddToCatalogueItems($catItem);
	$svc.Core.SetLink($catItem, "Catalogue", $cat);
	$catItem.CatalogueId = $cat.Id;
	$catItem.ProductId = $product.Id;
	$catItem.Name = $productName;
	$catItem.Description = 'DSWR Autocad 12 Production';
	$catItem.Created = [System.DateTimeOffset]::Now;
	$catItem.Modified = $catItem.Created;
	$catItem.ValidFrom = [System.DateTimeOffset]::MinValue;
	$catItem.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$catItem.EndOfSale = [System.DateTimeOffset]::MaxValue;
	$catItem.EndOfLife = [System.DateTimeOffset]::MaxValue;
	$catItem.CreatedBy = "SYSTEM";
	$catItem.ModifiedBy = $catItem.CreatedBy;
	$catItem.Tid = "1";
	$catItem.Id = 0;
	$svc.Core.UpdateObject($catItem);
	$svc.Core.SaveChanges();
}

function EntityTypes($Recreate)
{
	$svc = Enter-AppclusiveServer;
	$entityTypes = $svc.Core.EntityTypes | Select;
	DeleteItems -svc $svc -items $entityTypes;

	if(!$Recreate)
	{
		return;
	}
	
	$svc = Enter-AppclusiveServer;

	$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
	$svc.Core.AddToEntityTypes($et);
	$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Order';
	$et.Description = 'Order entity definition';
	$et.Parameters = '{"Created-Continue":"Approval","Created-Cancel":"Cancelled","Approval-Continue":"WaitingToRun","Approval-Cancel":"Cancelled","WaitingToRun-Continue":"Running","WaitingToRun-Cancel":"Cancelled", "Running-Continue":"Completed", "Running-Cancel":"Cancelled"}';
	$et.Version = '1';
	$et.Created = [System.DateTimeOffset]::Now;
	$et.Modified = $et.Created;
	$et.CreatedBy = "SYSTEM";
	$et.ModifiedBy = $et.CreatedBy;
	$et.Tid = "1";
	$et.Id = 0;
	$svc.Core.UpdateObject($et);
	$svc.Core.SaveChanges();

	$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
	$svc.Core.AddToEntityTypes($et);
	$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Approval';
	$et.Description = 'Approval entity definition';
	$et.Parameters = '{"Created-Continue":"Approved","Created-Cancel":"Declined"}';
	$et.Version = '1';
	$et.Created = [System.DateTimeOffset]::Now;
	$et.Modified = $et.Created;
	$et.CreatedBy = "SYSTEM";
	$et.ModifiedBy = $et.CreatedBy;
	$et.Tid = "1";
	$et.Id = 0;
	$svc.Core.UpdateObject($et);
	$svc.Core.SaveChanges();

	$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
	$svc.Core.AddToEntityTypes($et);
	$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Default';
	$et.Description = 'This is the definition for the default entity type';
	$et.Parameters = '{"Created-Continue":"Running","Created-Cancel":"InternalErrorState","Running-Continue":"Completed"}';
	$et.Version = '1';
	$et.Created = [System.DateTimeOffset]::Now;
	$et.Modified = $et.Created;
	$et.CreatedBy = "SYSTEM";
	$et.ModifiedBy = $et.CreatedBy;
	$et.Tid = "1";
	$et.Id = 0;
	$svc.Core.UpdateObject($et);
	$svc.Core.SaveChanges();
}

function Gates($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$gates = $svc.Core.Gates | Select;
	DeleteItems -svc $svc -items $gates;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function Jobs($Recreate)
{
	$svc = Enter-AppclusiveServer;

	$jobsWithParent = $svc.Core.Jobs |? ParentId -ne $null;
	DeleteItems -svc $svc -items $jobsWithParent;
	
	$svc = Enter-AppclusiveServer;
	
	$jobsWithoutParent = $svc.Core.Jobs | Select;
	DeleteItems -svc $svc -items $jobsWithoutParent;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function KeyNameValues($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$knvs = $svc.Core.KeyNameValues | Select;
	DeleteItems -svc $svc -items $knvs;

	if(!$Recreate)
	{
		return;
	}
	
	$svc = Enter-AppclusiveServer;
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.CS.Appclusive.Core.Managers.UpdateNotificationSubscriptions' -Name 'biz.dfch.CS.Appclusive.Core.Managers.OrderEntityManager' -Value 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Job';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Blacklist' -Value 'Pilot$';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Blacklist' -Value 'Test$';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Whitelist' -Value 'DSWR.+Production$';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Whitelist' -Value 'DSWR.+\d$';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController' -Name 'Properties' -Value '{}';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'StubMode' -Value 'True';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'ConnectionServerName' -Value '{}';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'PsSessionConfig' -Value '{}';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'PoolId' -Value '{}';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'SccmModulePath' -Value 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'SiteName' -Value 'P02';

	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.CS.Appclusive.Core.Messaging.Bus.AmqpMessagingClient' -Name 'NotifyWfeFacility' -Value 'NOTIFY-WFE';
	New-AppclusiveKeyNameValue -svc $svc -Key 'biz.dfch.CS.Appclusive.Core.Messaging.Bus.AmqpMessagingClient' -Name 'NotifyAllFacility' -Value 'NOTIFY-ALL';
	
	Get-AppclusiveKeyNameValue -svc $svc -ListAvailable;
}

function Assocs($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$assocs = $svc.Core.Assocs | Select;
	DeleteItems -svc $svc -items $assocs;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function ManagementCredentials($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$mgmtUris = $svc.Core.ManagementUris | Select;
	DeleteItems -svc $svc -items $mgmtUris;
	
	$mgmtCreds = $svc.Core.ManagementCredentials | Select;
	DeleteItems -svc $svc -items $mgmtCreds;

	if(!$Recreate)
	{
		return;
	}
	
	$svc = Enter-AppclusiveServer;

	$mc = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementCredential;
	$svc.Core.AddToManagementCredentials($mc);
	$mc.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController';
	$mc.Description = 'ManagementCredential for Active Directory access';
	$mc.Username = 'DFCH\adservice';
	$mc.Password = "P@ssw0rd";
	$mc.EncryptedPassword = $mc.Password;
	$mc.Created = [System.DateTimeOffset]::Now;
	$mc.Modified = $mc.Created;
	$mc.CreatedBy = "SYSTEM";
	$mc.ModifiedBy = $mc.CreatedBy;
	$mc.Tid = "1";
	$mc.Id = 0;
	$svc.Core.UpdateObject($mc);
	$svc.Core.SaveChanges();
	
	$mc = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementCredential;
	$svc.Core.AddToManagementCredentials($mc);
	$mc.Name = 'biz.dfch.CS.Appclusive.Core.Messaging.Bus.AmqpMessagingClient.ConnectionString';
	$mc.Description = 'ManagementCredential for Amqp connection string';
	$mc.Username = 'RootManageSharedAccessKey';
	$mc.Password = 'ngolZ2sQlq2ifQqUQyaOQ4msZ53uSOEhBhxzLp85KfI=';
	$mc.EncryptedPassword = $mc.Password;
	$mc.Created = [System.DateTimeOffset]::Now;
	$mc.Modified = $mc.Created;
	$mc.CreatedBy = "SYSTEM";
	$mc.ModifiedBy = $mc.CreatedBy;
	$mc.Tid = "1";
	$mc.Id = 0;
	$svc.Core.UpdateObject($mc);
	$svc.Core.SaveChanges();
}

function ManagementUris($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$mgmtUris = $svc.Core.ManagementUris | Select;
	DeleteItems -svc $svc -items $mgmtUris;

	if(!$Recreate)
	{
		return;
	}
	
	$svc = Enter-AppclusiveServer;

	$mc = $svc.Core.ManagementCredentials |? Name -eq 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController';

	$mgmtUri = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementUri;
	$svc.Core.AddToManagementUris($mgmtUri);
	$mgmtUri.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController';
	$mgmtUri.Description = 'LDAP Path';
	$mgmtUri.Created = [System.DateTimeOffset]::Now;
	$mgmtUri.Modified = $mgmtUri.Created;
	$mgmtUri.CreatedBy = "SYSTEM";
	$mgmtUri.ModifiedBy = $mgmtUri.CreatedBy;
	$mgmtUri.Tid = "1";
	$mgmtUri.Id = 0;
	$mgmtUri.Type = 'json';
	$mgmtUri.Value = '{"Path":"LDAP://dfch.biz/DC=dfch,DC=biz","AuthenticationType":"Secure"}';
	$mgmtUri.ManagementCredentialId = $mc.Id;
	$svc.Core.UpdateObject($mgmtUri);
	$svc.Core.SaveChanges();
	
	$mc = $svc.Core.ManagementCredentials |? Name -eq 'biz.dfch.CS.Appclusive.Core.Messaging.Bus.AmqpMessagingClient.ConnectionString';
	
	$mgmtUri = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementUri;
	$svc.Core.AddToManagementUris($mgmtUri);
	$mgmtUri.Name = 'biz.dfch.CS.Appclusive.Core.Messaging.Bus.AmqpMessagingClient.ConnectionString';
	$mgmtUri.Description = 'Connection String for Amqp messaging client';
	$mgmtUri.Created = [System.DateTimeOffset]::Now;
	$mgmtUri.Modified = $mgmtUri.Created;
	$mgmtUri.CreatedBy = "SYSTEM";
	$mgmtUri.ModifiedBy = $mgmtUri.CreatedBy;
	$mgmtUri.Tid = "1";
	$mgmtUri.Id = 0;
	$mgmtUri.Type = 'json';
	$mgmtUri.Value = '{"ConnectionString":"Endpoint=sb://win-8a036g6jvpj/ServiceBusDefaultNamespace;SharedAccessKeyName={0};SharedAccessKey={1}=;TransportType=Amqp"}';
	$mgmtUri.ManagementCredentialId = $mc.Id;
	$svc.Core.UpdateObject($mgmtUri);
	$svc.Core.SaveChanges();
}

function Nodes($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	# Delete children nodes from botton to top
	$svc.Core.Nodes.AddQueryOption('$expand', 'Children');
	$nodes = $svc.Core.Nodes |? { ($_.ParentId -ne $null) -And ($_.Children.count -eq 0) };
	while ($nodes.count > 0) {
		DeleteItems -svc $svc -items $nodes;
		$svc = Enter-AppclusiveServer;
		$svc.Core.Nodes.AddQueryOption('$expand', 'Children');
		$nodes = $svc.Core.Nodes |? { ($_.ParentId -ne $null) -And ($_.Children.count -eq 0) };
	}
	
	# Delete root nodes
	$svc = Enter-AppclusiveServer;
	$svc.Core.Nodes.AddQueryOption('$expand', 'Children');
	$nodes = $svc.Core.Nodes |? { ($_.ParentId -eq $null) -And ($_.Children.count -eq 0) }	
	DeleteItems -svc $svc -items $nodes;

	if(!$Recreate)
	{
		return;
	}
	
	$svc = Enter-AppclusiveServer;
	
	$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
	$svc.Core.AddToNodes($node);
	$node.Name = 'TenantNode 11111111-1111-1111-1111-111111111111';
	$node.Description = 'This is the root node of tenant 11111111-1111-1111-1111-111111111111';
	$node.Parameters = '{}';
	$node.Type = $node.GetType().FullName;
	$node.Created = [System.DateTimeOffset]::Now;
	$node.Modified = $node.Created;
	$node.CreatedBy = "SYSTEM";
	$node.ModifiedBy = $node.CreatedBy;
	$node.Tid = "11111111-1111-1111-1111-111111111111";
	$node.Id = 0;
	$svc.Core.UpdateObject($node);
	$svc.Core.SaveChanges();

	$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
	$svc.Core.AddToNodes($node);
	$node.Name = 'myNode';
	$node.Description = 'This is a node';
	$node.Parameters = '{}';
	$node.Type = $node.GetType().FullName;
	$node.Created = [System.DateTimeOffset]::Now;
	$node.Modified = $node.Created;
	$node.CreatedBy = "SYSTEM";
	$node.ModifiedBy = $node.CreatedBy;
	$node.Tid = "1";
	$node.Id = 0;
	$svc.Core.UpdateObject($node);
	$svc.Core.SaveChanges();

	$nodeParent = $node;

	$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
	$svc.Core.AddToNodes($node);
	$svc.Core.SetLink($node, 'Parent', $nodeParent);
	$node.ParentId = $nodeParent.Id;
	$node.Name = 'ChildNode2';
	$node.Description = 'This is a child node2';
	$node.Parameters = '{}';
	$node.Type = $node.GetType().FullName;
	$node.Created = [System.DateTimeOffset]::Now;
	$node.Modified = $node.Created;
	$node.CreatedBy = "SYSTEM";
	$node.ModifiedBy = $node.CreatedBy;
	$node.Tid = "1";
	$node.Id = 0;
	$svc.Core.UpdateObject($node);
	$svc.Core.SaveChanges();
}

function Orders($Recreate)
{
	$svc = Enter-AppclusiveServer;
	
	$orders = $svc.Core.Orders | Select;
	DeleteItems -svc $svc -items $orders;

	if(!$Recreate)
	{
		return;
	}
	
	# create new entries as applicable
}

function Products($Recreate) 
{
	$svc = Enter-AppclusiveServer;

	$products = $svc.Core.Products | Select;
	DeleteItems -svc $svc -items $products;
	
	if(!$Recreate)
	{
		return;
	}

	$product = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$svc.Core.AddToProducts($product);
	$product.Type = 'VDI';
	$product.Version = '1';
	$product.Name = 'VDI Personal';
	$product.Description = 'VDI (Virtual Desktop Infrastructure) for personal use';
	$product.Created = [System.DateTimeOffset]::Now;
	$product.Modified = $product.Created;
	$product.ValidFrom = [System.DateTimeOffset]::MinValue;
	$product.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$product.EndOfSale = [System.DateTimeOffset]::MaxValue;
	$product.EndOfLife = [System.DateTimeOffset]::MaxValue;
	$product.CreatedBy = "SYSTEM";
	$product.ModifiedBy = $product.CreatedBy;
	$product.Tid = "1";
	$product.Id = 0;
	$svc.Core.UpdateObject($product);
	$svc.Core.SaveChanges();

	$product = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$svc.Core.AddToProducts($product);
	$product.Type = 'VDI';
	$product.Version = '1';
	$product.Name = 'VDI Technical';
	$product.Description = 'VDI (Virtual Desktop Infrastructure) for someone else';
	$product.Created = [System.DateTimeOffset]::Now;
	$product.Modified = $product.Created;
	$product.ValidFrom = [System.DateTimeOffset]::MinValue;
	$product.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$product.EndOfSale = [System.DateTimeOffset]::MaxValue;
	$product.EndOfLife = [System.DateTimeOffset]::MaxValue;
	$product.CreatedBy = "SYSTEM";
	$product.ModifiedBy = $product.CreatedBy;
	$product.Tid = "1";
	$product.Id = 0;
	$svc.Core.UpdateObject($product);
	$svc.Core.SaveChanges();
	
	$product = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$svc.Core.AddToProducts($product);
	$product.Type = 'SCCM';
	$product.Version = '1';
	$product.Name = 'DSWR Autocad 12 Production';
	$product.Description = 'DSWR Autocad 12 Production';
	$product.Created = [System.DateTimeOffset]::Now;
	$product.Modified = $product.Created;
	$product.ValidFrom = [System.DateTimeOffset]::MinValue;
	$product.ValidUntil = [System.DateTimeOffset]::MaxValue;
	$product.EndOfSale = [System.DateTimeOffset]::MaxValue;
	$product.EndOfLife = [System.DateTimeOffset]::MaxValue;
	$product.CreatedBy = "SYSTEM";
	$product.ModifiedBy = $product.CreatedBy;
	$product.Tid = "1";
	$product.Id = 0;
	$svc.Core.UpdateObject($product);
	$svc.Core.SaveChanges();
}

function DeleteItems($svc, $items) 
{
	foreach($item in $items)
	{
		try
		{
			$svc.Core.DeleteObject($item);
			$svc.Core.SaveChanges();
		}
		catch
		{
			Write-Host ("Removing item '{0}' [{1}] FAILED.{2}{3}" -f $item.Name, $item.Id, [Environment]::NewLine, ($item | Out-String));
		}
	}
}

Aces($Recreate);
Acls($Recreate);
Approvals($Recreate);
AuditTrails($Recreate);
Carts($Recreate);
Catalogues($Recreate);
Products($Recreate);
CatalogueItems($Recreate);
EntityTypes($Recreate);
Gates($Recreate);
Jobs($Recreate);
KeyNameValues($Recreate);
Assocs($Recreate);
ManagementCredentials($Recreate);
ManagementUris($Recreate);
Nodes($Recreate);
Orders($Recreate);

#
# Copyright 2015 d-fens GmbH
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

# SIG # Begin signature block
# MIIXDwYJKoZIhvcNAQcCoIIXADCCFvwCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUOeRMqdGeKjFFprCtOeKokCr
# nbygghHCMIIEFDCCAvygAwIBAgILBAAAAAABL07hUtcwDQYJKoZIhvcNAQEFBQAw
# VzELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExEDAOBgNV
# BAsTB1Jvb3QgQ0ExGzAZBgNVBAMTEkdsb2JhbFNpZ24gUm9vdCBDQTAeFw0xMTA0
# MTMxMDAwMDBaFw0yODAxMjgxMjAwMDBaMFIxCzAJBgNVBAYTAkJFMRkwFwYDVQQK
# ExBHbG9iYWxTaWduIG52LXNhMSgwJgYDVQQDEx9HbG9iYWxTaWduIFRpbWVzdGFt
# cGluZyBDQSAtIEcyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAlO9l
# +LVXn6BTDTQG6wkft0cYasvwW+T/J6U00feJGr+esc0SQW5m1IGghYtkWkYvmaCN
# d7HivFzdItdqZ9C76Mp03otPDbBS5ZBb60cO8eefnAuQZT4XljBFcm05oRc2yrmg
# jBtPCBn2gTGtYRakYua0QJ7D/PuV9vu1LpWBmODvxevYAll4d/eq41JrUJEpxfz3
# zZNl0mBhIvIG+zLdFlH6Dv2KMPAXCae78wSuq5DnbN96qfTvxGInX2+ZbTh0qhGL
# 2t/HFEzphbLswn1KJo/nVrqm4M+SU4B09APsaLJgvIQgAIMboe60dAXBKY5i0Eex
# +vBTzBj5Ljv5cH60JQIDAQABo4HlMIHiMA4GA1UdDwEB/wQEAwIBBjASBgNVHRMB
# Af8ECDAGAQH/AgEAMB0GA1UdDgQWBBRG2D7/3OO+/4Pm9IWbsN1q1hSpwTBHBgNV
# HSAEQDA+MDwGBFUdIAAwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93d3cuZ2xvYmFs
# c2lnbi5jb20vcmVwb3NpdG9yeS8wMwYDVR0fBCwwKjAooCagJIYiaHR0cDovL2Ny
# bC5nbG9iYWxzaWduLm5ldC9yb290LmNybDAfBgNVHSMEGDAWgBRge2YaRQ2XyolQ
# L30EzTSo//z9SzANBgkqhkiG9w0BAQUFAAOCAQEATl5WkB5GtNlJMfO7FzkoG8IW
# 3f1B3AkFBJtvsqKa1pkuQJkAVbXqP6UgdtOGNNQXzFU6x4Lu76i6vNgGnxVQ380W
# e1I6AtcZGv2v8Hhc4EvFGN86JB7arLipWAQCBzDbsBJe/jG+8ARI9PBw+DpeVoPP
# PfsNvPTF7ZedudTbpSeE4zibi6c1hkQgpDttpGoLoYP9KOva7yj2zIhd+wo7AKvg
# IeviLzVsD440RZfroveZMzV+y5qKu0VN5z+fwtmK+mWybsd+Zf/okuEsMaL3sCc2
# SI8mbzvuTXYfecPlf5Y1vC0OzAGwjn//UYCAp5LUs0RGZIyHTxZjBzFLY7Df8zCC
# BCkwggMRoAMCAQICCwQAAAAAATGJxjfoMA0GCSqGSIb3DQEBCwUAMEwxIDAeBgNV
# BAsTF0dsb2JhbFNpZ24gUm9vdCBDQSAtIFIzMRMwEQYDVQQKEwpHbG9iYWxTaWdu
# MRMwEQYDVQQDEwpHbG9iYWxTaWduMB4XDTExMDgwMjEwMDAwMFoXDTE5MDgwMjEw
# MDAwMFowWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MjCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKPv0Z8p6djTgnY8YqDS
# SdYWHvHP8NC6SEMDLacd8gE0SaQQ6WIT9BP0FoO11VdCSIYrlViH6igEdMtyEQ9h
# JuH6HGEVxyibTQuCDyYrkDqW7aTQaymc9WGI5qRXb+70cNCNF97mZnZfdB5eDFM4
# XZD03zAtGxPReZhUGks4BPQHxCMD05LL94BdqpxWBkQtQUxItC3sNZKaxpXX9c6Q
# MeJ2s2G48XVXQqw7zivIkEnotybPuwyJy9DDo2qhydXjnFMrVyb+Vpp2/WFGomDs
# KUZH8s3ggmLGBFrn7U5AXEgGfZ1f53TJnoRlDVve3NMkHLQUEeurv8QfpLqZ0BdY
# Nc0CAwEAAaOB/TCB+jAOBgNVHQ8BAf8EBAMCAQYwEgYDVR0TAQH/BAgwBgEB/wIB
# ADAdBgNVHQ4EFgQUGUq4WuRNMaUU5V7sL6Mc+oCMMmswRwYDVR0gBEAwPjA8BgRV
# HSAAMDQwMgYIKwYBBQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3Jl
# cG9zaXRvcnkvMDYGA1UdHwQvMC0wK6ApoCeGJWh0dHA6Ly9jcmwuZ2xvYmFsc2ln
# bi5uZXQvcm9vdC1yMy5jcmwwEwYDVR0lBAwwCgYIKwYBBQUHAwMwHwYDVR0jBBgw
# FoAUj/BLf6guRSSuTVD6Y5qL3uLdG7wwDQYJKoZIhvcNAQELBQADggEBAHmwaTTi
# BYf2/tRgLC+GeTQD4LEHkwyEXPnk3GzPbrXsCly6C9BoMS4/ZL0Pgmtmd4F/ximl
# F9jwiU2DJBH2bv6d4UgKKKDieySApOzCmgDXsG1szYjVFXjPE/mIpXNNwTYr3MvO
# 23580ovvL72zT006rbtibiiTxAzL2ebK4BEClAOwvT+UKFaQHlPCJ9XJPM0aYx6C
# WRW2QMqngarDVa8z0bV16AnqRwhIIvtdG/Mseml+xddaXlYzPK1X6JMlQsPSXnE7
# ShxU7alVrCgFx8RsXdw8k/ZpPIJRzhoVPV4Bc/9Aouq0rtOO+u5dbEfHQfXUVlfy
# GDcy1tTMS/Zx4HYwggSfMIIDh6ADAgECAhIRIQaggdM/2HrlgkzBa1IJTgMwDQYJ
# KoZIhvcNAQEFBQAwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24g
# bnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzIw
# HhcNMTUwMjAzMDAwMDAwWhcNMjYwMzAzMDAwMDAwWjBgMQswCQYDVQQGEwJTRzEf
# MB0GA1UEChMWR01PIEdsb2JhbFNpZ24gUHRlIEx0ZDEwMC4GA1UEAxMnR2xvYmFs
# U2lnbiBUU0EgZm9yIE1TIEF1dGhlbnRpY29kZSAtIEcyMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAsBeuotO2BDBWHlgPse1VpNZUy9j2czrsXV6rJf02
# pfqEw2FAxUa1WVI7QqIuXxNiEKlb5nPWkiWxfSPjBrOHOg5D8NcAiVOiETFSKG5d
# QHI88gl3p0mSl9RskKB2p/243LOd8gdgLE9YmABr0xVU4Prd/4AsXximmP/Uq+yh
# RVmyLm9iXeDZGayLV5yoJivZF6UQ0kcIGnAsM4t/aIAqtaFda92NAgIpA6p8N7u7
# KU49U5OzpvqP0liTFUy5LauAo6Ml+6/3CGSwekQPXBDXX2E3qk5r09JTJZ2Cc/os
# +XKwqRk5KlD6qdA8OsroW+/1X1H0+QrZlzXeaoXmIwRCrwIDAQABo4IBXzCCAVsw
# DgYDVR0PAQH/BAQDAgeAMEwGA1UdIARFMEMwQQYJKwYBBAGgMgEeMDQwMgYIKwYB
# BQUHAgEWJmh0dHBzOi8vd3d3Lmdsb2JhbHNpZ24uY29tL3JlcG9zaXRvcnkvMAkG
# A1UdEwQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwQgYDVR0fBDswOTA3oDWg
# M4YxaHR0cDovL2NybC5nbG9iYWxzaWduLmNvbS9ncy9nc3RpbWVzdGFtcGluZ2cy
# LmNybDBUBggrBgEFBQcBAQRIMEYwRAYIKwYBBQUHMAKGOGh0dHA6Ly9zZWN1cmUu
# Z2xvYmFsc2lnbi5jb20vY2FjZXJ0L2dzdGltZXN0YW1waW5nZzIuY3J0MB0GA1Ud
# DgQWBBTUooRKOFoYf7pPMFC9ndV6h9YJ9zAfBgNVHSMEGDAWgBRG2D7/3OO+/4Pm
# 9IWbsN1q1hSpwTANBgkqhkiG9w0BAQUFAAOCAQEAgDLcB40coJydPCroPSGLWaFN
# fsxEzgO+fqq8xOZ7c7tL8YjakE51Nyg4Y7nXKw9UqVbOdzmXMHPNm9nZBUUcjaS4
# A11P2RwumODpiObs1wV+Vip79xZbo62PlyUShBuyXGNKCtLvEFRHgoQ1aSicDOQf
# FBYk+nXcdHJuTsrjakOvz302SNG96QaRLC+myHH9z73YnSGY/K/b3iKMr6fzd++d
# 3KNwS0Qa8HiFHvKljDm13IgcN+2tFPUHCya9vm0CXrG4sFhshToN9v9aJwzF3lPn
# VDxWTMlOTDD28lz7GozCgr6tWZH2G01Ve89bAdz9etNvI1wyR5sB88FRFEaKmzCC
# BNYwggO+oAMCAQICEhEhDRayW4wRltP+V8mGEea62TANBgkqhkiG9w0BAQsFADBa
# MQswCQYDVQQGEwJCRTEZMBcGA1UEChMQR2xvYmFsU2lnbiBudi1zYTEwMC4GA1UE
# AxMnR2xvYmFsU2lnbiBDb2RlU2lnbmluZyBDQSAtIFNIQTI1NiAtIEcyMB4XDTE1
# MDUwNDE2NDMyMVoXDTE4MDUwNDE2NDMyMVowVTELMAkGA1UEBhMCQ0gxDDAKBgNV
# BAgTA1p1ZzEMMAoGA1UEBxMDWnVnMRQwEgYDVQQKEwtkLWZlbnMgR21iSDEUMBIG
# A1UEAxMLZC1mZW5zIEdtYkgwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIB
# AQDNPSzSNPylU9jFM78Q/GjzB7N+VNqikf/use7p8mpnBZ4cf5b4qV3rqQd62rJH
# RlAsxgouCSNQrl8xxfg6/t/I02kPvrzsR4xnDgMiVCqVRAeQsWebafWdTvWmONBS
# lxJejPP8TSgXMKFaDa+2HleTycTBYSoErAZSWpQ0NqF9zBadjsJRVatQuPkTDrwL
# eWibiyOipK9fcNoQpl5ll5H9EG668YJR3fqX9o0TQTkOmxXIL3IJ0UxdpyDpLEkt
# tBG6Y5wAdpF2dQX2phrfFNVY54JOGtuBkNGMSiLFzTkBA1fOlA6ICMYjB8xIFxVv
# rN1tYojCrqYkKMOjwWQz5X8zAgMBAAGjggGZMIIBlTAOBgNVHQ8BAf8EBAMCB4Aw
# TAYDVR0gBEUwQzBBBgkrBgEEAaAyATIwNDAyBggrBgEFBQcCARYmaHR0cHM6Ly93
# d3cuZ2xvYmFsc2lnbi5jb20vcmVwb3NpdG9yeS8wCQYDVR0TBAIwADATBgNVHSUE
# DDAKBggrBgEFBQcDAzBCBgNVHR8EOzA5MDegNaAzhjFodHRwOi8vY3JsLmdsb2Jh
# bHNpZ24uY29tL2dzL2dzY29kZXNpZ25zaGEyZzIuY3JsMIGQBggrBgEFBQcBAQSB
# gzCBgDBEBggrBgEFBQcwAoY4aHR0cDovL3NlY3VyZS5nbG9iYWxzaWduLmNvbS9j
# YWNlcnQvZ3Njb2Rlc2lnbnNoYTJnMi5jcnQwOAYIKwYBBQUHMAGGLGh0dHA6Ly9v
# Y3NwMi5nbG9iYWxzaWduLmNvbS9nc2NvZGVzaWduc2hhMmcyMB0GA1UdDgQWBBTN
# GDddiIYZy9p3Z84iSIMd27rtUDAfBgNVHSMEGDAWgBQZSrha5E0xpRTlXuwvoxz6
# gIwyazANBgkqhkiG9w0BAQsFAAOCAQEAAApsOzSX1alF00fTeijB/aIthO3UB0ks
# 1Gg3xoKQC1iEQmFG/qlFLiufs52kRPN7L0a7ClNH3iQpaH5IEaUENT9cNEXdKTBG
# 8OrJS8lrDJXImgNEgtSwz0B40h7bM2Z+0DvXDvpmfyM2NwHF/nNVj7NzmczrLRqN
# 9de3tV0pgRqnIYordVcmb24CZl3bzpwzbQQy14Iz+P5Z2cnw+QaYzAuweTZxEUcJ
# bFwpM49c1LMPFJTuOKkUgY90JJ3gVTpyQxfkc7DNBnx74PlRzjFmeGC/hxQt0hvo
# eaAiBdjo/1uuCTToigVnyRH+c0T2AezTeoFb7ne3I538hWeTdU5q9jGCBLcwggSz
# AgEBMHAwWjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYtc2Ex
# MDAuBgNVBAMTJ0dsb2JhbFNpZ24gQ29kZVNpZ25pbmcgQ0EgLSBTSEEyNTYgLSBH
# MgISESENFrJbjBGW0/5XyYYR5rrZMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEM
# MQowCKACgAChAoAAMBkGCSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQB
# gjcCAQsxDjAMBgorBgEEAYI3AgEVMCMGCSqGSIb3DQEJBDEWBBSh/Kp/ohaCsQ4l
# hg7ygodiLK3TeDANBgkqhkiG9w0BAQEFAASCAQAX+gGEA1pHjyVb9bOvWMlcbtBr
# 1EXd/PLiTUl3hxEAjVgB3zTpKVwpW8RQ+LPzlqy0a/D8ZRmmGTpAJ4VbsuxPVWf/
# DKkyTOBUxAlqQEMaQHjFhXfJfGiGvs8SzVLhVodZkGxBY1dyGBmWoAX1I3ZEAmlS
# +EtLn94walvlowj4WV7idsLkeLSZMltITtLai1rNc7u+r/6jNGWbQcr5xUxm20wa
# i5vFEZCxIUT6lyrno1b3HZCM8PannBF/83hAcOM20dzm/ua0bABDGVaJ4VpoNbke
# ywpUGDG/G0irAVTbwTRNZDHcr4Pbhl1RYKH7J5YOyaHCffY043kuq9J0w/2koYIC
# ojCCAp4GCSqGSIb3DQEJBjGCAo8wggKLAgEBMGgwUjELMAkGA1UEBhMCQkUxGTAX
# BgNVBAoTEEdsb2JhbFNpZ24gbnYtc2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGlt
# ZXN0YW1waW5nIENBIC0gRzICEhEhBqCB0z/YeuWCTMFrUglOAzAJBgUrDgMCGgUA
# oIH9MBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJKoZIhvcNAQkFMQ8XDTE1
# MTEyNDA3MTkzMFowIwYJKoZIhvcNAQkEMRYEFGNyIgjFn+81qDUGk/PDqAushFZk
# MIGdBgsqhkiG9w0BCRACDDGBjTCBijCBhzCBhAQUs2MItNTN7U/PvWa5Vfrjv7Es
# KeYwbDBWpFQwUjELMAkGA1UEBhMCQkUxGTAXBgNVBAoTEEdsb2JhbFNpZ24gbnYt
# c2ExKDAmBgNVBAMTH0dsb2JhbFNpZ24gVGltZXN0YW1waW5nIENBIC0gRzICEhEh
# BqCB0z/YeuWCTMFrUglOAzANBgkqhkiG9w0BAQEFAASCAQB1sRDfKcjCrY13xDat
# MA6NL5Gwz9gGSL8KSIolwHQNG+F0BpRVnVM2KMI61sTAQGsbEADdKC392FVzgN4M
# p+4/PTt/qEB47pG41SLy7NlcHCigxpgj6LatTyZfgDMmb5xmVIRibpPXRU+GDk54
# gtOMOezKH/sKZj9c1ogu+GwTY6l4+7VZvkPDJvj5+uvcnlao+py8ANrk0txylh+H
# wQlIzyxJv738h69Vc2T8q7h7XbCMDuGbMNPoBhFgOeGDLbeP0VaUh2Z8JNiPL5Lx
# QRyijXkTrnh1BGEKc179xpJxsjdCA4uxX/L625ys/HYR3qejx3zQ1gJc3xFh3Cum
# TvlB
# SIG # End signature block
