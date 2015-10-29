function ProcessVDIEntitlement($username) 
{
	$username = $username.split('\')[1];
	$key = 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI';
	
	$stubMode = Get-AppclusiveKeyNameValue -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'StubMode';
	
	if($stubMode.Value -eq 'True')
	{
		return $true;
	}

	$connectionServerName = Get-AppclusiveKeyNameValue -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'ConnectionServerName';
	$psSessionConfig = Get-AppclusiveKeyNameValue -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'PsSessionConfig';
	$poolId = Get-AppclusiveKeyNameValue -Key 'biz.dfch.PS.Sunrise.Daas.Scripts.VDI' -Name 'PoolId';
	
	# DFTODO - Implement fallback to other connection server (also defined in ManagementUri)
	Enter-PSSession -ComputerName $connectionServerName.Value -ConfigurationName $psSessionConfig.Value
	
	Add-PSSnapin VMware.View.Broker -ErrorAction:Stop;
	
	$user = Get-User -name $username -ErrorAction:SilentlyContinue;
	if ($user -eq $null)
	{
		$errorMsg = "User '{0}' not found" -f $username;
		return $errorMsg;
	}
	
	# Check, if user already has a VDI
	$entitlement = GetExistingEntitlement -user $user;
	if($entitlement)
	{
		$errorMsg = "User '{0}' is already entitled." -f $username;
		return $errorMsg;
	}
	
	$pool = Get-Pool -pool_id $poolId.Value -ErrorAction:SilentlyContinue;
	if($pool -eq $null)
	{
		$errorMsg = "Pool with id '{0}' not found" -f $poolId.Value;
		return $errorMsg;
	}
	
	$result = $user | Add-PoolEntitlement -pool_id $poolId.Value;
	
	if($result.EntitlementsAdded -ne 1) 
	{
		$errorMsg = "Entitlement FAILED (PoolId: {0}, Username: {1})" -f $poolId.Value, $username;
		return $errorMsg;
	}
	
	return $true;
}

function GetExistingEntitlement($user) 
{
	return Get-PoolEntitlement |? sid -eq $user.sid;
}

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
