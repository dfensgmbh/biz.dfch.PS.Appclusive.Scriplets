function Get-CatalogueItem {
<#
.SYNOPSIS
Retrieves one or more entities from the catalogueItem entity set.

.DESCRIPTION
Retrieves one or more entities from the catalogueItem  entity set.

You can retrieve one ore more entities from the entity set by specifying 
Id, Name or other properties.

.INPUTS
The Cmdlet can either return all available entities or filter entities on 
specified conditions.
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
Get-CatalogueItem

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 36
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Personal
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:34:39 +01:00
Modified     : 14.02.2016 15:34:39 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 37
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Technical
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:35:19 +01:00
Modified     : 14.02.2016 15:35:19 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

List all available catalogue items

.EXAMPLE
Get-CatalogueItem -Id 37

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 37
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Technical
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:35:19 +01:00
Modified     : 14.02.2016 15:35:19 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

Retrieves the catalogue item with id 37

.EXAMPLE
Get-ApcProduct -SearchByName "vdi"

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 36
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Personal
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:34:39 +01:00
Modified     : 14.02.2016 15:34:39 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

CatalogueId  : 15
ProductId    : 14
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 01.01.2025 00:00:00 +01:00
EndOfLife    : 01.01.2025 00:00:00 +01:00
Parameters   :
Id           : 37
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : VDI Technical
Description  :
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 15:35:19 +01:00
Modified     : 14.02.2016 15:35:19 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

Retrieves the catalogue items which contains "vdi"

.EXAMPLE
Get-ApcProduct -CatalogueId 4

CatalogueId  : 4
ProductId    : 50
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 02.01.9999 00:00:00 +01:00
EndOfLife    : 02.01.9999 00:00:00 +01:00
Parameters   :
Id           : 35
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : Managed Red Hat Enterprise Linux 6
Description  : Managed Red Hat Enterprise Linux 6
CreatedById  : 1014
ModifiedById : 1014
Created      : 14.02.2016 11:51:25 +01:00
Modified     : 14.02.2016 11:53:08 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

CatalogueId  : 4
ProductId    : 53
ValidFrom    : 01.01.0001 00:00:00 +00:00
ValidUntil   : 31.12.9999 23:59:59 +00:00
EndOfLife    : 31.12.9999 23:59:59 +00:00
Parameters   :
Id           : 40
Tid          : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name         : Managed Windows Server 2008 R2
Description  : Managed Windows Server 2008 R2
CreatedById  : 2
ModifiedById : 2
Created      : 15.02.2016 19:12:47 +01:00
Modified     : 15.02.2016 19:12:47 +01:00
RowVersion   : {0, 0, 0, 0...}
Catalogue    :
Product      :
Tenant       :
CreatedBy    :
ModifiedBy   :

Retrieves all products which are in the catalogue with id 4

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-CatalogueItem/

.NOTES
See module manifest for required software versions and dependencies.
#>
# Requires biz.dfch.PS.Appclusive.Client
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/Get-CatalogueItem/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM 
(
	# Id of the catalogue item
	[Parameter(Mandatory = $false, ParameterSetName = 'Id')]
	[ValidateNotNullOrEmpty()]
	[Int] $Id = $null
	,
	# Full name or part of it, for the item you want to search - this is not case sensitive
	[Parameter(Mandatory = $false, ParameterSetName = 'SearchByName')]
	[ValidateNotNullOrEmpty()]
	[String] $SearchByName = $null
	,
	# Id of the product
	[Parameter(Mandatory = $false, ParameterSetName = 'ProductId')]
	[ValidateNotNullOrEmpty()]
	[String] $ProductId = $null
	,
	# Id of the catalogue
	[Parameter(Mandatory = $false, ParameterSetName = 'CatalogueId')]
	[ValidateNotNullOrEmpty()]
	[String] $CatalogueId = $null
	,
	# Lists all available products
	[Parameter(Mandatory = $false, ParameterSetName = 'list')]
	[Switch] $ListAvailable = $true
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
	
	$EntitySetName = 'CatalogueItems';
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
		
		If ($PSCmdlet.ParameterSetName -eq 'ProductId') 
		{
			$Exp += ("ProductId eq {0}" -f $ProductId);
		}
		
		If ($PSCmdlet.ParameterSetName -eq 'CatalogueId') 
		{
			$Exp += ("CatalogueId eq {0}" -f $CatalogueId);
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function Get-CatalogueItem; } 