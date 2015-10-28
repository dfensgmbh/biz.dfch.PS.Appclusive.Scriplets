function ProcessVDIEntitlement($username) 
{
	$result = $true;
		
	$result = CheckForExistingVDI -username $username;
	if($true -eq $result)
	{
		$errorMsg = "User {0} has already a VDI assigned" -f $username;
		return $errorMsg;
	}
	
	# DFTODO - Decide stubbing based on KNV entry
	# DFTODO - Get the following properties from KNV? (add to seed.ps1?) + error handling
	$computerName = '';
	$psSessionConfig = '';
	$poolId = ''
	
	# DFTODO - Implement fallback to other connection server
	Enter-PSSession -ComputerName $computerName -ConfigurationName $psSessionConfig
	
	$pool = Get-Pool -pool_id $poolId;
	
	
	
	Add-PSSnapin VMware.View.Broker
	# DFTODO - Entitle VDI
	
	return $result;
}

function CheckForExistingVDI($username) 
{
	$result = $true;
	
	# DFTODO - Check if a VDI already exists for the given user
	# DFTODO - Get connection server from MgmtUri or KNV!
	
	return $result
}
