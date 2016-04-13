function Get-Tenant {
<#
.SYNOPSIS
Get tenant from the systems.

.DESCRIPTION
Get tenant from the systems.

You can search for tenants in the appclusive orch. There fore you can enter a name, guid or list all available tenants.

.INPUTS
The Cmdlet can either return all available tenants or filter entities on 
specified conditions.
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
Get-Tenant

Id           : 33333333-3333-3333-3333-333333333333
Name         : GROUP_TENANT
Description  : GROUP_TENANT
ExternalId   : 33333333-3333-3333-3333-333333333333
ExternalType : Internal
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 16:12:47 +00:00
Modified     : 14.12.2015 16:12:47 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 33333333-3333-3333-3333-333333333333
CustomerId   :
Parent       :
Customer     :
Children     : {}

Id           : 22222222-2222-2222-2222-222222222222
Name         : HOME_TENANT
Description  : HOME_TENANT
ExternalId   : 22222222-2222-2222-2222-222222222222
ExternalType : Internal
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 16:12:47 +00:00
Modified     : 14.12.2015 16:12:47 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 22222222-2222-2222-2222-222222222222
CustomerId   :
Parent       :
Customer     :
Children     : {}

Return all available tenants. This is the same as Get-ApcTenant -ListAvailable.

.EXAMPLE
Get-ApcTenant -Id 'bb7580a0-5d34-40b2-9851-86c66443f304'

Id           : bb7580a0-5d34-40b2-9851-86c66443f304
Name         : Managed Service Tenant
Description  : Manage Service Tenant
               (previously 2e2435b9-5a68-4d15-acc2-ca42aaa000fe)
ExternalId   : d3a08f77-f848-4757-b7f2-1600ad851a0a
ExternalType : External
CreatedById  : 1
ModifiedById : 1014
Created      : 07.03.2016 00:00:00 +01:00
Modified     : 15.03.2016 10:54:04 +01:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 11111111-1111-1111-1111-111111111111
CustomerId   :
Parent       :
Customer     :
Children     : {}

Return the tenant with the id "bb7580a0-5d34-40b2-9851-86c66443f304".

.EXAMPLE
Get-ApcTenant -Name "Te" -TenantTyp Internal

Id           : 11111111-1111-1111-1111-111111111111
Name         : SYSTEM_TENANT
Description  : SYSTEM_TENANT
ExternalId   : 11111111-1111-1111-1111-111111111111
ExternalType : Internal
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 16:12:47 +00:00
Modified     : 06.01.2016 18:13:00 +01:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 11111111-1111-1111-1111-111111111111
CustomerId   : 2
Parent       :
Customer     :
Children     : {}

Id           : 22222222-2222-2222-2222-222222222222
Name         : HOME_TENANT
Description  : HOME_TENANT
ExternalId   : 22222222-2222-2222-2222-222222222222
ExternalType : Internal
CreatedById  : 1
ModifiedById : 1
Created      : 14.12.2015 16:12:47 +00:00
Modified     : 14.12.2015 16:12:47 +00:00
RowVersion   : {0, 0, 0, 0...}
ParentId     : 22222222-2222-2222-2222-222222222222
CustomerId   :
Parent       :
Customer     :
Children     : {}

Id           : 33333333-3333-3333-3333-333333333333
Name         : GROUP_TENANT
...

This call return all tenants where the name "te" include and the ExternalType "Internal" is.

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Tenant/

.NOTES
See module manifest for required software versions and dependencies.
#>
# Requires biz.dfch.PS.Appclusive.Client
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Tenant/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Lists all available products
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[Switch] $ListAvailable = $true
	,
	# Tenant id to search fore
	[Parameter(Mandatory = $true, ParameterSetName = 'Id')]
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
	[String] $Id = $null
	,
	# Id from the parent tenant
	[Parameter(Mandatory = $true, ParameterSetName = 'ParentTenant')]
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
	[String] $ParentTenantId = $null
	,
	# External Tenant id
	[Parameter(Mandatory = $true, ParameterSetName = 'ExternalId')]
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
	[String] $ExternalId = $null
	,
	# Tenant name or a part of it to search for
	[Parameter(Mandatory = $true, ParameterSetName = 'Name')]
	[ValidateNotNullOrEmpty()]
	[String] $Name = $null
	,
	# Typ of tenants to search for
	[ValidateSet('All', 'External', 'Internal')]
	[Parameter(Mandatory = $false)]
	[string] $TenantTyp = 'All'
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
	
	Contract-Requires ($svc.Core -is [biz.dfch.CS.Appclusive.Api.Core.Core]) "Connect to the server before using the Cmdlet"
	
	$EntitySetName = 'Tenants';
}
# Begin

Process 
{
	trap { Log-Exception $_; break; }
	# Default test variable for checking function response codes.
	[Boolean] $fReturn = $false;
	
	if($PSCmdlet.ParameterSetName -eq 'list') 
	{
		$Response = $svc.Core.$EntitySetName.AddQueryOption('$orderby','Name') | Select;
	}	
	else
	{
		$Exp = @();
		If ($PSCmdlet.ParameterSetName -eq 'Id') 
		{
			$Exp += ("Id eq guid'{0}'" -f $Id);
			# write-warning $Exp;
		}
		elseIf ($PSCmdlet.ParameterSetName -eq 'ParentTenant') 
		{
			$Exp += ("ParentId eq guid'{0}'" -f $ParentTenantId);
		}
		elseIf ($PSCmdlet.ParameterSetName -eq 'ExternalId') 
		{
			$Exp += ("ExternalId eq '{0}'" -f $ExternalId);
		}
		elseIf ($PSCmdlet.ParameterSetName -eq 'Name') 
		{
			$Exp += ("substringof('{0}', tolower(Name))" -f $Name.ToLower());
		}
		
		if ($TenantTyp -ne 'All')
		{
			$Exp += ("ExternalType eq '{0}'" -f $TenantTyp);
		}
		
		$FilterExpression = [String]::Join(' and ', $Exp);
		$Response = $svc.Core.$EntitySetName.AddQueryOption('$filter', $FilterExpression) | Select;
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-Tenant; } 