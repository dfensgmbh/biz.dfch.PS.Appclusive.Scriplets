Param
(
	[string] $CatalogueName = 'Default DaaS'
	,
	$KeyName = 'biz.dfch.CS.DaaS.Backends.Sccm.CatalogueItems'
	,
	$SccmModulePath = 'C:\Program Files (x86)\Microsoft Configuration Manager\AdminConsole\bin'
	,
	$SiteName = 'P02'
)

$datBegin = [datetime]::Now;
[string] $fn = $MyInvocation.MyCommand.Name;
Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;

$svc = Enter-AppclusiveServer;

CD $SccmModulePath
$null = Import-Module .\ConfigurationManager.psd1;
CD ('{0}:' -f $SiteName);

$al = New-Object System.Collections.ArrayList;
Log-Debug $fn ("Loading packages from '{0}' ..." -f $SiteName)
$packages = (Get-CMCollection).Name;
Log-Info $fn ("Loading packages from '{0}' COMPLETED. Found {1} packages." -f $SiteName, $packages.Count)

Log-Debug $fn ("Loading whiteLists from '{0}' ..." -f $KeyName);
$whiteListValues = Get-KeyNameValue -svc $svc -Key $KeyName -Name Whitelist -Select Value;
$whiteLists = $whiteListValues.Value;
Log-Debug $fn ("Loading whiteLists from '{0}' COMPLETED [{1}]." -f $KeyName, whiteLists.Count);
Log-Debug $fn ("Loading blackLists from '{0}' ..." -f $KeyName);
$blackListValues = Get-KeyNameValue -svc $svc -Key $KeyName -Name Blacklist -Select Value;
$blackLists = $blackListValues.Value;
Log-Debug $fn ("Loading blackLists from '{0}' COMPLETED [{1}]." -f $KeyName, blackLists.Count);

Log-Debug $fn ("Matching packages against whiteLists and blackLists ...");
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
Log-Info $fn ("Matching packages against whiteLists and blackLists COMPLETED. '{0}' packages remaining." -f $al.Count);

Log-Debug $fn "Removing existing SCCM packages ...";
$catItems = $svc.Core.CatalogueItems.AddQueryOption('$filter', "Type eq 'SCCM'") | Select;
foreach($catItem in $catItems)
{
	try
	{
		Log-Debug ($fn "Removing SCCM package '{0}' ..." -f $catItem.Name);
		$svc.Core.DeleteObject($catItem);
		$svc.Core.SaveChanges();
		Log-Info ($fn "Removing SCCM package '{0}' SUCCEEDED." -f $catItem.Name);
	}
	catch
	{
		Log-Error ($fn "Removing SCCM package '{0}' FAILED." -f $catItem.Name);
	}
}

Log-Debug $fn ("Attaching packages to catalogue. Resolving '{0}' ..." -f $CatalogueName);
$CatalogueName = 'Default DaaS'
$cat = $svc.Core.Catalogues |? Name -eq $CatalogueName;
if($null -eq $cat)
{
	$e = New-CustomErrorRecord -m $msg -cat ObjectNotFound -o $CatalogueName;
	throw $e;
}
Log-Info $fn ("Attaching packages to catalogue. Resolving '{0}' SUCCEEDED." -f $CatalogueName);

Log-Debug $fn ("Processing '{0}' matching packages ...'" -f $al.Count);
foreach($catItemName in $al)
{
	try
	{
		Log-Debug $fn ("Adding '{0}' to catalogue '{1}' ..." -f $catItemName, $cat.Name);
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
		Log-Info $fn ("Adding '{0}' to catalogue '{1}' SUCCEEDED." -f $catItemName, $cat.Name);
	}
	catch
	{
		Log-Error $fn ("Adding '{0}' to catalogue '{1}' FAILED." -f $catItemName, $cat.Name);
	}
}
