function Get-Product {
<#
.SYNOPSIS
Retrieves one or more entities from the product entity set.

.DESCRIPTION
Retrieves one or more entities from the product entity set.

You can retrieve one ore more entities from the entity set by specifying 
Id, Name or other properties.

.INPUTS
The Cmdlet can either return all available entities or filter entities on 
specified conditions.
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
Get-Product

Type           : com.swisscom.cms.rhel6
EntityKindId   : 4862
ValidFrom      : 01.01.0001 00:00:00 +00:00
ValidUntil     : 31.12.9999 00:00:00 +01:00
EndOfLife      : 31.12.9999 00:00:00 +01:00
Parameters     : {}
Id             : 50
Tid            : 11111111-1111-1111-1111-111111111111
Name           : RHEL6
Description    :
CreatedById    : 1011
ModifiedById   : 1011
Created        : 14.02.2016 11:21:49 +01:00
Modified       : 14.02.2016 11:21:49 +01:00
RowVersion     : {0, 0, 0, 0...}
CatalogueItems : {}
EntityKind     :
Tenant         :
CreatedBy      :
ModifiedBy     :

Type           : com.swisscom.cms.rhel7
EntityKindId   : 4097
ValidFrom      : 01.01.0001 00:00:00 +00:00
ValidUntil     : 31.12.9999 00:00:00 +01:00
EndOfLife      : 31.12.9999 00:00:00 +01:00
Parameters     : {}
Id             : 11
Tid            : 11111111-1111-1111-1111-111111111111
Name           : RHEL7
Description    :
CreatedById    : 2
ModifiedById   : 2
Created        : 21.12.2015 09:17:45 +01:00
Modified       : 21.12.2015 12:24:19 +01:00
RowVersion     : {0, 0, 0, 0...}
CatalogueItems : {}
EntityKind     :
Tenant         :
CreatedBy      :
ModifiedBy     :

List all Products

.EXAMPLE
Get-ApcProduct -Id 12

Type           : com.swisscom.cms.win
EntityKindId   : 4098
ValidFrom      : 01.01.0001 00:00:00 +00:00
ValidUntil     : 01.01.2020 00:00:00 +01:00
EndOfLife      : 01.01.2020 00:00:00 +01:00
Parameters     :
Id             : 12
Tid            : 11111111-1111-1111-1111-111111111111
Name           : WIN2012R2
Description    :
CreatedById    : 2
ModifiedById   : 2
Created        : 21.12.2015 16:00:10 +01:00
Modified       : 18.01.2016 01:13:44 +01:00
RowVersion     : {0, 0, 0, 0...}
CatalogueItems : {}
EntityKind     :
Tenant         :
CreatedBy      :
ModifiedBy     :

Retrieves the product with id 12

.EXAMPLE
Get-ApcProduct -Name "WIN2012R2"

Type           : com.swisscom.cms.win
EntityKindId   : 4098
ValidFrom      : 01.01.0001 00:00:00 +00:00
ValidUntil     : 01.01.2020 00:00:00 +01:00
EndOfLife      : 01.01.2020 00:00:00 +01:00
Parameters     :
Id             : 12
Tid            : 11111111-1111-1111-1111-111111111111
Name           : WIN2012R2
Description    :
CreatedById    : 2
ModifiedById   : 2
Created        : 21.12.2015 16:00:10 +01:00
Modified       : 18.01.2016 01:13:44 +01:00
RowVersion     : {0, 0, 0, 0...}
CatalogueItems : {}
EntityKind     :
Tenant         :
CreatedBy      :
ModifiedBy     :

Retrieves the product with the Name WIN2012R2

.EXAMPLE
Get-ApcProduct -SearchByName "WIN"

Type           : com.swisscom.cms.win
EntityKindId   : 4098
ValidFrom      : 01.01.0001 00:00:00 +00:00
ValidUntil     : 01.01.2020 00:00:00 +01:00
EndOfLife      : 01.01.2020 00:00:00 +01:00
Parameters     :
Id             : 12
Tid            : 11111111-1111-1111-1111-111111111111
Name           : WIN2012R2
Description    :
CreatedById    : 2
ModifiedById   : 2
Created        : 21.12.2015 16:00:10 +01:00
Modified       : 18.01.2016 01:13:44 +01:00
RowVersion     : {0, 0, 0, 0...}
CatalogueItems : {}
EntityKind     :
Tenant         :
CreatedBy      :
ModifiedBy     :

Type           : com.swisscom.cms.win2008r2
EntityKindId   : 4864
ValidFrom      : 01.01.0001 00:00:00 +00:00
ValidUntil     : 31.12.9999 23:59:59 +00:00
EndOfLife      : 31.12.9999 23:59:59 +00:00
Parameters     :
Id             : 53
Tid            : 11111111-1111-1111-1111-111111111111
Name           : WIN2008R2
Description    : Managed Windows Server 2008 R2
CreatedById    : 2
ModifiedById   : 2
Created        : 15.02.2016 19:03:11 +01:00
Modified       : 15.02.2016 19:03:11 +01:00
RowVersion     : {0, 0, 0, 0...}
CatalogueItems : {}
EntityKind     :
Tenant         :
CreatedBy      :
ModifiedBy     :

Retrieves all products which contains WIN

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Product/

.NOTES
See module manifest for required software versions and dependencies.
#>
# Requires biz.dfch.PS.Appclusive.Client
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-Product/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Id of the product
	[Parameter(Mandatory = $false, ParameterSetName = 'Id')]
	[ValidateNotNullOrEmpty()]
	[Int] $Id = $null
	,
	# Name of the product
	[Parameter(Mandatory = $false, ParameterSetName = 'Parameter')]
	[ValidateNotNullOrEmpty()]
	[String] $Name = $null
	,
	# Name of the product type
	[Parameter(Mandatory = $false, ParameterSetName = 'Parameter')]
	[ValidateNotNullOrEmpty()]
	[String] $ProductType = $null
	,
	# Part of the name of the product type you want to search - this is not case sensitive
	[Parameter(Mandatory = $false, ParameterSetName = 'SearchByName')]
	[ValidateNotNullOrEmpty()]
	[String] $SearchByName = $null
	,
	# Lists all available products
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[Switch] $ListAvailable = $true
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
	
	$EntitySetName = 'Products';
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
			$Exp += ("Id eq {0}" -f $Id);
		}
		
		If ($PSCmdlet.ParameterSetName -eq 'SearchByName') 
		{
			$Exp += ("substringof('{0}', tolower(Name))" -f $SearchByName.ToLower());
		}
		
		if (!([string]::IsNullOrEmpty($ProductType)))
		{
			$Exp += ("tolower(Type) eq '{0}'" -f $ProductType.ToLower());
		}
		
		if (!([string]::IsNullOrEmpty($Name)))
		{
			$Exp += ("tolower(Name) eq '{0}'" -f $Name.ToLower());
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
# End

} # function

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-Product; } 