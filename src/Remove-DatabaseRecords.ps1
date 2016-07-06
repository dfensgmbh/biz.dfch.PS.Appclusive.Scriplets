[xml] $webConfig = Get-Content -Raw C:\inetpub\wwwroot\Appclusive\web.config -Encoding Default
Contract-Assert (!!$webConfig)

$connectionStringValue = $webConfig.configuration.connectionStrings.add |? name -eq 'core';
Contract-Assert (!!$connectionStringValue)

$connectionString = $connectionStringValue.connectionString;
Contract-Assert (!!$connectionString)

$q = "SELECT ID FROM [Core].[Machine] ORDER BY ID DESC";
$machineIds = Invoke-SqlCmd -ConnectionString $connectionString -IntegratedSecurity:$false $q;
Contract-Assert (0 -lt $machineIds.Count)

foreach($machineId in $machineIds)
{
	$id = $machineId.ID;

	$q = "DELETE FROM [Core].[Machine] WHERE ID = {0}" -f $id
	try
	{
		Invoke-SqlCmd -ConnectionString $connectionString -IntegratedSecurity:$false $q;
	}
	catch
	{
		Write-Host $id
	}
}

$q = "SELECT ID FROM [Core].[Node] WHERE ((EntityKindId <> 29) AND (EntityKindId <> 33)) ORDER BY ID DESC";
$nodeIds = Invoke-SqlCmd -ConnectionString $connectionString -IntegratedSecurity:$false $q;
Contract-Assert (0 -lt $nodeIds.Count)

foreach($nodeId in $nodeIds)
{
	$id = $nodeId.ID;

	$q = "DELETE FROM [Core].[Node] WHERE ID = {0}" -f $id
	try
	{
		Invoke-SqlCmd -ConnectionString $connectionString -IntegratedSecurity:$false $q;
	}
	catch
	{
		Write-Host $id
	}
}

$rootNodes = ($svc.Core.Nodes | Select Id).Id;

$q = "SELECT ID FROM [Core].[Job]ORDER BY ID DESC";
$jobIds = Invoke-SqlCmd -ConnectionString $connectionString -IntegratedSecurity:$false $q;
Contract-Assert (0 -lt $jobIds.Count)

foreach($jobId in $jobIds)
{
	$id = $jobId.ID;

	if($rootNodes.Contains($id -as [long]))
	{
		continue;
	}
	
	$q = "DELETE FROM [Core].[Job] WHERE ID = {0}" -f $id
	try
	{
		Invoke-SqlCmd -ConnectionString $connectionString -IntegratedSecurity:$false $q;
	}
	catch
	{
		Write-Host $id
	}
}

$q = "SELECT * FROM [Core].[Ace] ORDER BY ID DESC";
$aces = Invoke-SqlCmd -ConnectionString $connectionString -IntegratedSecurity:$false $q;

$q = "SELECT * FROM [Core].[Acl] ORDER BY ID DESC";
$acls = Invoke-SqlCmd -ConnectionString $connectionString -IntegratedSecurity:$false $q;

foreach($acl in $acls)
{
	
}
