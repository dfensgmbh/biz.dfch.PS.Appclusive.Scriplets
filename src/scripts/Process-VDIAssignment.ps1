function ProcessVDIEntitlement($username) 
{
	$username = $username.split('\')[1];

	# DFTODO - Decide stubbing based on KNV entry
	# DFTODO - Get the following properties from KNV? (add to seed.ps1?) + error handling
	# these entries will be read from a ManagementUri (and associated ManagementCredential if necessary)
	# pool names may be read from KNV
	$connectionServerName = '';
	$psSessionConfig = '';
	$poolId = '';
	
	# DFTODO - Implement fallback to other connection server (also defined in ManagementUri)
	Enter-PSSession -ComputerName $connectionServerName -ConfigurationName $psSessionConfig
	
	Add-PSSnapin VMware.View.Broker -ErrorAction:Stop;
	
	$user = $null;
	try 
	{
		# DFTODO - here I suggest to use ErrorAction:SilentlyContinue and then just check for $null
		# smae holds true for all other try/catch statements with ErrorAction:Stop
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
	
	try
	{
		$pool = Get-Pool -pool_id $poolId -ErrorAction Stop;
	}
	catch
	{
		$errorMsg = "Pool with Id '{0}' not found" -f $poolId;
		return $errorMsg;
	}
	
	$result = $user | Add-PoolEntitlement -pool_id $poolId;
	
	if ($result.EntitlementsAdded -ne 1) 
	{
		$errorMsg = "Entitlement FAILED (PoolId: {0}, Username: {1})" -f $poolId, $username;
		return $errorMsg;
	}
	
	return $true;
}

function GetExistingEntitlement($user) 
{
	return Get-PoolEntitlement |? sid -eq $user.sid;
}
