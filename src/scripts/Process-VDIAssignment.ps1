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
	$vdi = GetExistingVDI -user $user;
	if($vdi)
	{
		$errorMsg = "User '{0}' has already a VDI assigned to." -f $username;
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
	
	
	
	return $success;
}

function GetExistingVDI($user) 
{
	return Get-DesktopVM |? user_sid -eq $user.sid;
}
