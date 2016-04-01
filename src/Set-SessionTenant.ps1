function Set-SessionTenant {
<#
.SYNOPSIS
Set the tenant in the session, so the user can work for this tenant.

.DESCRIPTION
Set the tenant in the session, so the user can work for this tenant. 

You can set a tenant in your user variable. All actions will executed in the name of this tenant. Pay attention the tenant will be set on all entpoint (Core, Cmp, Diagnostics)

.INPUTS
GUID from the tenant.

.OUTPUTS
Retun the tenant you set.

default | json | json-pretty | xml | xml-pretty

.EXAMPLE
Set-SessionTenant 


.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-SessionTenant/

.NOTES
See module manifest for required software versions and dependencies.
#>
# Requires biz.dfch.PS.Appclusive.Client
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Set-SessionTenant/'
	,
	DefaultParameterSetName = 'TenantId'
)]
PARAM 
(
	# List of Cimi IDs to check if they are available
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'TenantId')]
	[ValidateScript({
		try 
		{
			[System.Guid]::Parse($_) | Out-Null
			$true
		} 
		catch 
		{
			write-warning "Input is not from type GUID"
			$false
		}
    })]
	[string] $TenantId = $null
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
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
	Contract-Requires ($svc.Cmp -is [biz.dfch.CS.Appclusive.Api.Cmp.Cmp]) "Connect to the server before using the Cmdlet"
	Contract-Requires ($svc.Diagnostics -is [biz.dfch.CS.Appclusive.Api.Diagnostics.Diagnostics]) "Connect to the server before using the Cmdlet"
}
# Begin

Process 
{

	$tenant = Get-ApcTenant -Id $TenantId;
	If($tenant)
	{
		$svc.Core.TenantID = $TenantId
		$svc.Cmp.TenantID = $TenantId
		$svc.Diagnostics.TenantID = $TenantId	
	}
	else
	{
		Write-warning ("No tenant with id {0} found. Abort..." -f $TenantId)
		Return;
	}
	
	$OutputParameter = Format-ResultAs $tenant $As
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Set-SessionTenant; } 