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
Get-CimiTarget -CimiId "06ffa86b-e5e7-49d3-9f6a-72d79416bce6"

CimiID       : https://cmabrmp-lab3ch-1.mgmt.sccloudpoc.net:9001/v1/cimi/2/machines/06ffa86b-e5e7-49d3-9f6a-72d79416bce6
Name         : TestProdukteJuergRHEL7
OrchTempID   : 37
OrchTenantID : 9e210b40-3b9c-466a-bc4d-9f9243933350
Status       : Impelented

Retrieves the cimi machine with ID 06ffa86b-e5e7-49d3-9f6a-72d79416bce6 and returns all properties of it.


.EXAMPLE
Get-CimiTarget -ServerName "hipatest19.6"

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
	DefaultParameterSetName = 'ListAvailable'
)]
PARAM 
(
	# Lists all available CIMI-Machines
	[Parameter(Mandatory = $false, ParameterSetName = 'ListAvailable')]
	[Switch] $ListAvailable = $true
	,
	# CimiId or part of it to check if the machine is available
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'CimiId')]
	[ValidateNotNullOrEmpty()]
	[string] $CimiId = $null
	,
	# Server name or part of it to check if the machine is available
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'ServerName')]
	[ValidateNotNullOrEmpty()]
	[string] $Name = $null
	,
	# Service reference to Appclusive
	[Parameter(Mandatory = $false)]
	[Alias('Services')]
	[hashtable] $svc = (Get-Variable -Name $MyInvocation.MyCommand.Module.PrivateData.MODULEVAR -ValueOnly).Services
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
	
	Contract-Requires ($svc.Cmp -is [biz.dfch.CS.Appclusive.Api.Cmp.Cmp]) "Connect to the server before using the Cmdlet"
	$EntitySetName = 'CimiTargets';
}
# Begin

Process 
{
	trap { Log-Exception $_; break; }
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	
	if($PSCmdlet.ParameterSetName -eq 'ListAvailable') 
	{
		$Response = $svc.Cmp.$EntitySetName.AddQueryOption('$orderby','Name') | Select;
	}	
	else
	{
		$Exp = @();
		If ($PSCmdlet.ParameterSetName -eq 'CimiId') 
		{
			$Exp += ("substringof('{0}', CimiId)" -f $CimiId);
		}
		
		If ($PSCmdlet.ParameterSetName -eq 'ServerName') 
		{
			$Exp += ("substringof('{0}', tolower(Name))" -f $Name.ToLower());
		}

		$FilterExpression = [String]::Join(' and ', $Exp);
		$Response = $svc.Cmp.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
	}
	
	# $OutputParameter = $result
	$OutputParameter = Format-ResultAs $Response $As
	$fReturn = $true;
}
# Process

End 
{
	$datEnd = [datetime]::Now;
	Log-Debug -fn $fn -msg ("RET. fReturn: [{0}]. Execution time: [{1}]ms. Started: [{2}]." -f $fReturn, ($datEnd - $datBegin).TotalMilliseconds, $datBegin.ToString('yyyy-MM-dd HH:mm:ss.fffzzz')) -fac 2;
	
	# Return values are always and only returned via OutputParameter.
	return $OutputParameter;
}

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-CimiTarget; } 