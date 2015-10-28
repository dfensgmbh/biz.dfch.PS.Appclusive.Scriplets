function ProcessVDIAssignment($username) 
{
	$result = $true;
		
	$result = CheckForExistingVDI -username $username;
	if($true -eq $result)
	{
		$errorMsg = "User {0} has already a VDI assigned" -f $username;
		return $errorMsg;
	}
	
	# DFTODO - Get the following properties from KNV? (add to seed.ps1?) + error handling
	$computerName = '';
	$account = '';
	$psSessionConfig = '';
	
	Enter-PSSession -ComputerName H1102 -Credential $account -ConfigurationName $psSessionConfig
	# DFTODO - Enter Password? HOWTO? -> Get from mgmt credentials!
	
	# DFTODO - Implement fallback to other connection server
	
	Add-PSSnapin VMware.View.Broker
	# DFTODO - Assign VDI
	
	return $result;
}

function CheckForExistingVDI($username) 
{
	$result = $true;
	
	# DFTODO - Check if a VDI already exists for the given user
	# DFTODO - Get connection server from MgmtUri or KNV!
	
	return $result
}
