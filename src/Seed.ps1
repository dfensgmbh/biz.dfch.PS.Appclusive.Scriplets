# Catalogue
$svc = Enter-AppclusiveServer;

$catName = 'Default DaaS'
$cat = $svc.Core.Catalogues |? Name -eq $catName;
$cat;
$svc.Core.DeleteObject($cat);
$svc.Core.SaveChanges();

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

# CatalogueItems
$svc = Enter-AppclusiveServer;

$cat = $svc.Core.Catalogues |? Name -eq $catName;
$cat

$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
$svc.Core.AddToCatalogueItems($catItem);
$svc.Core.SetLink($catItem, "Catalogue", $cat);
$catItem.CatalogueId = $cat.Id;
$catItem.Type = 'VDI';
$catItem.Version = 1;
$catItem.Name = 'VDI Personal';
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


# KeyNameValue
$svc = Enter-AppclusiveServer;

$knvs = Get-KeyNameValue -svc $svc -ListAvailable;
foreach($knv in $knvs) { Remove-KeyNameValue -svc $svc -Confirm:$false -Key $knv.Key -Name $knv.Name -Value $knv.Value; }

New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.Appclusive.Core.Managers.UpdateNotificationSubscriptions' -Name 'biz.dfch.CS.Appclusive.Core.Managers.OrderEntityManager' -Value 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Job';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Blacklist' -Value 'Pilot$';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Blacklist' -Value 'Test$';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Whitelist' -Value 'DSWR.+Production$';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems' -Name 'Whitelist' -Value 'DSWR.+\d$';
New-KeyNameValue -svc $svc -Key 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController' -Name 'Properties' -Value '{}';
Get-KeyNameValue -svc $svc -ListAvailable;

# ManagementCredential
$mc = New-Object biz.dfch.CS.Appclusive.Api.Core.ManagementCredential;
$mc
$svc.Core.AddToManagementCredentials($mc);
$mc.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController';
$mc.Description = 'ManagementCredential for Active Directory acsess';
$mc.Username = 'SWI\sDaaSPa';
$mc.Password = "tralala";
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
$mc
$svc.Core.AddToManagementCredentials($mc);
$mc.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.ActiveDirectoryUsersController';
$mc.Description = 'ManagementCredential for Active Directory acsess';
$mc.Username = 'SWI\sDaaSPa';
$mc.Password = "tralala";
$mc.EncryptedPassword = $mc.Password;
$mc.Created = [System.DateTimeOffset]::Now;
$mc.Modified = $mc.Created;
$mc.CreatedBy = "SYSTEM";
$mc.ModifiedBy = $mc.CreatedBy;
$mc.Tid = "1";
$mc.Id = 0;
$svc.Core.UpdateObject($mc);
$svc.Core.SaveChanges();

# Node
$svc = Enter-AppclusiveServer;

$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node
$node
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

$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node
$node
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

# SCCM
# http://thedesktopteam.com/blog/heinrich/sccm-2012-r2-powershell-basics-part-1/
CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
# Import-Module .\ConfigurationManager.psd1 -verbose;
Import-Module .\ConfigurationManager.psd1;
CD P02:

# EntityTypes
$svc = Enter-AppclusiveServer;

$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
$et;
$svc.Core.AddToEntityTypes($et);
$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Order';
$et.Description = 'Order entity definition';
$et.Parameters = '{"Executing-Continue":"Completed","Executing-Cancel":"Failed"}';
$et.Created = [System.DateTimeOffset]::Now;
$et.Modified = $et.Created;
$et.CreatedBy = "SYSTEM";
$et.ModifiedBy = $et.CreatedBy;
$et.Tid = "1";
$et.Id = 0;
$svc.Core.UpdateObject($et);
$svc.Core.SaveChanges();

$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
$et;
$svc.Core.AddToEntityTypes($et);
$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Approval';
$et.Description = 'Approval entity definition';
$et.Parameters = '{"Created-Continue":"Approval","Created-Cancel":"Failed","Approval-Continue":"WaitingToRun","Approval-Cancel":"Declined","WaitingToRun-Continue":"Completed","WaitingToRun-Cancel":"Failed"}';
$et.Created = [System.DateTimeOffset]::Now;
$et.Modified = $et.Created;
$et.CreatedBy = "SYSTEM";
$et.ModifiedBy = $et.CreatedBy;
$et.Tid = "1";
$et.Id = 0;
$svc.Core.UpdateObject($et);
$svc.Core.SaveChanges();

$et = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityType
$et;
$svc.Core.AddToEntityTypes($et);
$et.Name = 'biz.dfch.CS.Appclusive.Core.OdataServices.Core.Default';
$et.Description = 'This is the definition for the default entity type';
$et.Parameters = '{"Created-Continue":"Running","Created-Cancel":"InternalErrorState","Running-Continue":"Completed"}';
$et.Created = [System.DateTimeOffset]::Now;
$et.Modified = $et.Created;
$et.CreatedBy = "SYSTEM";
$et.ModifiedBy = $et.CreatedBy;
$et.Tid = "1";
$et.Id = 0;
$svc.Core.UpdateObject($et);
$svc.Core.SaveChanges();


# load software packages from Sccm
$svc = Enter-AppclusiveServer;

$fn = "SccmImport";

CD 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
$null = Import-Module .\ConfigurationManager.psd1;
CD P02:

$al = New-Object System.Collections.ArrayList;
$packages = (Get-CMCollection).Name;
Log-Debug $fn ("SCCM: Processing '{0}' packages ..." -f $packages.Count)

$whiteListValues = Get-KeyNameValue -svc $svc -Key biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems -Name Whitelist -Select Value;
$whiteLists = $whiteListValues.Value;
$blackListValues = Get-KeyNameValue -svc $svc -Key biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems -Name Blacklist -Select Value;
$blackLists = $blackListValues.Value;

foreach($package in $packages)
{
	foreach($whiteList in $whiteLists)
	{
		if($package -imatch $whiteList)
		{
			Log-Debug $fn ("{0}: whiteList matched package '{1}'" -f $whiteList, $package);
			$null = $al.Add($package);
			break;
		}
	}
	foreach($blackList in $blackLists)
	{
		if($package -imatch $blackList)
		{
			Log-Debug $fn ("{0}: blackList matched package '{1}'" -f $blackList, $package);
			if($al.Contains($package))
			{
				$null = $al.Remove($package);
			}
			break;
		}
	}
}
Log-Debug $fn ("Found '{0}' matching packages ...'" -f $al.Count);

$catItems = $svc.Core.CatalogueItems.AddQueryOption('$filter', "Type eq 'SCCM'") | Select;
foreach($catItem in $catItems)
{
	try
	{
		$svc.Core.DeleteObject($catItem);
		$svc.Core.SaveChanges();
	}
	catch
	{
		Write-Host ("removing catItem '{0}' FAILED." -f $catItem.Name);
	}
}

if($null -eq $catItem)
{
	$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$svc.Core.AddToCatalogueItems($catItem);
	$svc.Core.SetLink($catItem, "Catalogue", $cat);
}

Log-Debug $fn ("Processing '{0}' matching packages ...'" -f $al.Count);
foreach($catItemName in $al)
{
	$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$svc.Core.AddToCatalogueItems($catItem);
	$svc.Core.SetLink($catItem, "Catalogue", $cat);
	$catItem.CatalogueId = $cat.Id;
	$catItem.Type = 'SCCM';
	$catItem.Version = 1;
	$catItem.Name = $catItemName;
	$catItem.Description = $catItemName;
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

