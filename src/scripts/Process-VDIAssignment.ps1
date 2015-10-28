function ProcessVDIEntitlement($username) 
{
	$success = $true;
	$username = $username.split('\')[1];

	# DFTODO - Decide stubbing based on KNV entry
	# DFTODO - Get the following properties from KNV? (add to seed.ps1?) + error handling
	$connectionServerName = '';
	$psSessionConfig = '';
	$poolId = '';
	
	# DFTODO - Implement fallback to other connection server
	Enter-PSSession -ComputerName $connectionServerName -ConfigurationName $psSessionConfig
	
	Add-PSSnapin VMware.View.Broker;
	
	$user = $null;
	try 
	{
		$user = Get-User -name $username -ErrorAction Stop;
	}
	catch
	{
		$errorMsg = "User '{0}' not found" -f $username;
		return $errorMsg;
	}
	
	# Check if user already has a VDI
	$entitlement = GetExistingEntitlement -user $user;
	if($entitlement)
	{
		$errorMsg = "User '{0}' is already entitled." -f $username;
		return $errorMsg;
	}
	
	# DFTODO - Implement fallback to other pools
	try
	{
		$pool = Get-Pool -pool_id $poolId -ErrorAction Stop;
	}
	catch
	{
		$errorMsg = "Pool with Id '{0}' not found" -f $poolId;
		return $errorMsg;
	}
	
	# DFTODO - Entitle VDI
	$user | Add-PoolEntitlement -pool_id $poolId;
	
	
	return $success;
}

function GetExistingEntitlement($user) 
{
	return Get-PoolEntitlement |? sid -eq $user.sid;
}
