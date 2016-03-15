function Get-CimiTarget {
<#
.SYNOPSIS
Check if a machine exist in CIMI and if they is reachable from the orch

.DESCRIPTION
Check if a machine exist in CIMI and if they is reachable from the orch

You can check if a machine exist in CIMI. Therefor you can search by name oder cimi id.

.INPUTS
The Cmdlet can either return all available entities or filter entities on 
specified conditions.
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

In addition output can be filtered on specified properties.

.EXAMPLE
Get-CimiTarget -ListAvailable

CimiID       : https://cmabrmp-lab3ch-1.mgmt.sccloudpoc.net:9001/v1/cimi/2/machines/65c90f2b-12b1-4f45-b0db-f5de62478a4b
Name         : rijutestrhel73
OrchTempID   : 33
OrchTenantID : 9e210b40-3b9c-466a-bc4d-9f9243933350
Status       : Impelented

CimiID       : https://cmabrmp-lab3ch-1.mgmt.sccloudpoc.net:9001/v1/cimi/2/machines/99dd86e6-ed88-4ca8-9594-5ad1fd6aee66
Name         : CMS-Test-Erich-W2012R2-Test-1
OrchTempID   : 34
OrchTenantID : 9e210b40-3b9c-466a-bc4d-9f9243933350
Status       : Impelented

CimiID       : https://cmabrmp-lab3ch-1.mgmt.sccloudpoc.net:9001/v1/cimi/2/machines/f73bae78-248a-486c-ba5a-48cfce2ec4ad
Name         : Template-Test-Erich-RHEL6
OrchTempID   : 35
OrchTenantID : 9e210b40-3b9c-466a-bc4d-9f9243933350
Status       : Impelented

CimiID       : https://cmabrmp-lab3ch-1.mgmt.sccloudpoc.net:9001/v1/cimi/2/machines/548d1086-db9d-4d7b-b4a3-62382a8d581f
Name         : CMS-Test-Erich-RHEL7-Test-3
OrchTempID   : 36
OrchTenantID : 9e210b40-3b9c-466a-bc4d-9f9243933350
Status       : Impelented

Return all machines with a bunch of information

.EXAMPLE
Get-CimiTarget -cimiID "06ffa86b-e5e7-49d3-9f6a-72d79416bce6"

CimiID       : https://cmabrmp-lab3ch-1.mgmt.sccloudpoc.net:9001/v1/cimi/2/machines/06ffa86b-e5e7-49d3-9f6a-72d79416bce6
Name         : TestProdukteJuergRHEL7
OrchTempID   : 37
OrchTenantID : 9e210b40-3b9c-466a-bc4d-9f9243933350
Status       : Impelented

Retrieves the cimi machine with ID 06ffa86b-e5e7-49d3-9f6a-72d79416bce6 and returns all properties of it.


.EXAMPLE
Get-CimiTarget -ServerName "-ServerName "hipatest19.6""

CimiID       : https://cmabrmp-lab3ch-1.mgmt.sccloudpoc.net:9001/v1/cimi/2/machines/47019f6a-0038-4d40-a92a-56d8873fd405
Name         : hipatest19.6
OrchTempID   : 112
OrchTenantID : 9e210b40-3b9c-466a-bc4d-9f9243933350
Status       : Impelented

Retrieves the cimi machine with the name -ServerName "hipatest19.6" and returns all properties of it.

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-CimiTarget/

.NOTES
See module manifest for required software versions and dependencies.
#>
# Requires biz.dfch.PS.Appclusive.Client
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-CimiTarget/'
	,
	DefaultParameterSetName = 'CimiID'
)]
PARAM 
(
	# Lists all available CIMI-Machines
	[Parameter(Mandatory = $true, ParameterSetName = 'ListAvailable')]
	[Switch] $ListAvailable = $false
	,
	# List of Cimi IDs to check if they are available
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'CimiID')]
	[ValidateNotNullOrEmpty()]
	[string[]] $cimiID = $null
	,
	# List of server names to check if they are available
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ServerName')]
	[ValidateNotNullOrEmpty()]
	[string[]] $ServerName = $null
	,
	# ORCH credentials to connect to Appclusive
	[Parameter(Mandatory = $false, Position = 1)]
	[ValidateNotNullOrEmpty()]
	[System.Management.Automation.PSCredential] $Credentials
	,
	# Specifies the return format of the Cmdlet
	[ValidateSet('default', 'json', 'json-pretty', 'xml', 'xml-pretty')]
	[Parameter(Mandatory = $false)]
	[alias('ReturnFormat')]
	[string] $As = 'default'
)

Begin 
{
	trap { Log-Exception $_; break; }

	$datBegin = [datetime]::Now;
	[string] $fn = $MyInvocation.MyCommand.Name;
	Log-Debug -fn $fn -msg ("CALL. svc '{0}'. Name '{1}'." -f ($svc -is [Object]), $Name) -fac 1;
	
	# Import-Module biz.dfch.PS.Appclusive.Client -force;
	
	# Workaround to load appclusive credentials if it is not passed
	# if ([string]::IsNullOrEmpty($Credentials))
	# {
		# $credFile = (Join-Path -Path $env:USERPROFILE -ChildPath ("appclusiveCred-{0}.xml" -f $env:USERNAME))
		# If(!(Test-Path $credFile))
		# {
			# Write-Warning "Empty credential input and no credential file is available. Abort...";
			# Exit
		# }
		# $Credentials = (Import-Clixml $credFile)
	# }
	
	# $svc = Enter-Apc -Credential $Credentials;
	
	# Contract-Requires ($svc.CMP -is [biz.dfch.CS.Appclusive.Api.CMP) "Connect to the server before using the Cmdlet"
	
	function checkIntergrationByName ($ServerName) 
	{
		$result = Foreach ($server in $ServerName)
		{
			$machine = $svc.CMP.CimiTargets.AddQueryOption('$filter',("Name eq '{0}'" -f $server)) | Select
			
			If (!([string]::IsNullOrEmpty($machine)))
			{
				[PSCustomObject] @{
					CimiID = $machine.CimiId;
					Name = $machine.Name;
					OrchTempID = $machine.Id;
					OrchTenantID = $machine.Tid;
					Status = "Impelented"
				}
			}
			else
			{
				[PSCustomObject] @{
					CimiID = "Not found"
					Name = "Not found";
					OrchTempID = "Not found";
					OrchTenantID = "Not found";
					Status = "Unknown"
				}
			}
		}
		return $result;
	}
	
	function checkIntergrationByCimiID ($cimiIDs) 
	{
		$result = Foreach ($cimiID in $cimiIDs)
		{
			$machine = $svc.CMP.CimiTargets.AddQueryOption('$filter',("substringof('{0}', CimiId)" -f $cimiIDs)) | Select
			
			If (!([string]::IsNullOrEmpty($machine)))
			{
				[PSCustomObject] @{
					CimiID = $machine.CimiId;
					Name = $machine.Name;
					OrchTempID = $machine.Id;
					OrchTenantID = $machine.Tid;
					Status = "Impelented"
				}
			}
			else
			{
				[PSCustomObject] @{
					CimiID = "Not found"
					Name = "Not found";
					OrchTempID = "Not found";
					OrchTenantID = "Not found";
					Status = "Unknown"
				}
			}
		}
		return $result;
	}
	
	function availableCimiMachines () 
	{
		$machines = $svc.CMP.CimiTargets | Select
		
		$result = foreach ($machine in $machines)
		{
			If (!([string]::IsNullOrEmpty($machine)))
			{
				[PSCustomObject] @{
					CimiID = $machine.CimiId;
					Name = $machine.Name;
					OrchTempID = $machine.Id;
					OrchTenantID = $machine.Tid;
					Status = "Impelented"
				}
			}
			else
			{
				[PSCustomObject] @{
					CimiID = "Not found"
					Name = "Not found";
					OrchTempID = "Not found";
					OrchTenantID = "Not found";
					Status = "Unknown"
				}
			}
		}
		return $result;
	}
}
# Begin

Process 
{
	If (!([string]::IsNullOrEmpty($cimiID)))
	{
		$result = checkIntergrationByCimiID -cimiIDs $cimiID
	}
	elseif (!([string]::IsNullOrEmpty($ServerName)))
	{
		$result = checkIntergrationByName -ServerName $ServerName
	}
	elseif ($ListAvailable)
	{
		$result = availableCimiMachines
	}
	else
	{
		Write-Warning "Something went wrong - no search parameter fount. Abort..."
		Exit
	}
	
	# $OutputParameter = $result
	$OutputParameter = Format-ResultAs $result $As
	$fReturn = $true;
}
# Process

End 
{
	# Return values are always and only returned via OutputParameter.
	return $OutputParameter;
}

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-CimiTarget; } 