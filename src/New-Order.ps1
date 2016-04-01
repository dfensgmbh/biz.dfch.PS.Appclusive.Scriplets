function New-Order {
<#
.SYNOPSIS
Place a new order in orch

.DESCRIPTION
Place a new order in orch

You can create a new order for a product in the Appclusive.

.INPUTS
See PARAMETERS section on possible inputs.

.OUTPUTS
default | json | json-pretty | xml | xml-pretty

.EXAMPLE
New-ApcOrder -CatalogueItemId 12 -ProductParmeters ($parameterCart | ConvertTo-Json -Compress)

Status              : Approval
RefId               : 408
Token               : optional
TenantId            : 00000000-0000-0000-0000-000000000000
EntityKindId        : 20
Parameters          : optional
Condition           :
ConditionParameters :
Error               :
EndTime             :
ParentId            : 1647
Id                  : 4436
Tid                 : 9e210b40-3b9c-466a-bc4d-9f9243933350
Name                : InitialStateInitialise succeeded
Description         : InitialStateInitialise succeeded
CreatedById         : 1014
ModifiedById        : 1014
Created             : 23.02.2016 16:20:05 +01:00
Modified            : 23.02.2016 16:20:05 +01:00
RowVersion          : {0, 0, 0, 0...}
EntityKind          :
Parent              :
Children            : {}
Tenant              :
CreatedBy           :
ModifiedBy          :

This order return the job that is created 

.LINK
Online Version: http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Order/

.NOTES
See module manifest for required software versions and dependencies.
#>
# Requires biz.dfch.PS.Appclusive.Client
[CmdletBinding(
    SupportsShouldProcess = $true
	,
    ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Order/'

)]
PARAM 
(
	# Id of the catalogue item, which should be orderd
	[Parameter(Mandatory = $true)]
	[ValidateNotNullOrEmpty()]
	[Int] $CatalogueItemId = $null
	,
	# JSON-String with all from the product required parameters
	[Parameter(Mandatory = $true, ParameterSetName = 'JSON')]
	[ValidateNotNullOrEmpty()]
	[String] $ProductParmeters = $null
	,
	# Id from the folder to place the object to
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[Int] $FolderId = $Null
	,
	# Id from the owner to owner of the system, if it has to be changed 
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[Int] $OwnerId = $Null
	,
	# Id from the tenant to place the order to, if it has to be changed 
	[Parameter(Mandatory = $false)]
	[ValidateNotNullOrEmpty()]
	[Int] $TenantId = $Null
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
}
# Begin

Process 
{
	trap { Log-Exception $_; break; }
	
	If (!(Get-ApcCatalogueItem -Id $CatalogueItemId))
	{
		Write-Warning ("No Catalogue Item with Id {0} found. Abort..." -f $CatalogueItemId);
		Return;
	}
	
	try {
		$testJSON = ConvertFrom-Json $ProductParmeters;
	} catch {
		write-warning "Input is not an JSON-String. Abort..."
		Return
	}
	
	$cartItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CartItem
	$cartItem.Quantity = 1;
	$cartItem.CatalogueItemId = $CatalogueItemId;
	$cartItem.Parameters = $ProductParmeters;
	$cartItem.Id = "0"
	$cartItem.Name = "Migration"
	$cartItem.Description = "Migration"
	
	write-host ($cartItem  | Out-String) ;
	
	$result = $svc.Core.AddToCartItems($cartItem);
	$result = $svc.Core.SaveChanges()
	
	$cart = $svc.Core.Carts

	$parameterOrder = @{}
	If($FolderId)
	{
		$parameterOrder.NodeID = $FolderId;
	} 
	else
	{
		$entityRoot = Get-ApcEntityKind -Name biz.dfch.CS.Appclusive.Core.General.TenantRoot
		
		If ($svc.Core.TenantID)
		{
			$nodeId = $svc.Core.Nodes.AddQueryOption('$filter',("(Tid eq GUID'{0}') and (EntityKindId eq {1})" -f $svc.Core.TenantID,$entityRoot.Id))
		}
		else
		{
			$nodeId = $svc.Core.Nodes.AddQueryOption('$filter',("EntityKindId eq {0}" -f $entityRoot.Id)).AddQueryOption('$top','1')
		}
		
		$parameterOrder.NodeID = $nodeId.Id;
	}
	
	write-host (($parameterOrder | ConvertTo-Json -Compress).ToString())
	
	$order = New-Object biz.dfch.CS.Appclusive.Api.Core.Order
	$order.Parameters = (($parameterOrder | ConvertTo-Json -Compress).ToString())
	$order.Name = "test taahaga1"
	$order.Description = "test taahaga1"
	
	$result = $svc.Core.AddToOrders($order)
	$orderResult = $svc.Core.SaveChanges()
	
	write-host (($orderResult | ConvertTo-Json).ToString())
	# Get the Job from the request return
	$jobUri = [uri] $orderResult.Headers.Location
	If (($jobUri.Segments[-1] -match '^Jobs\((?<JobId>\d+)L?\)$'))
	{
		$job = Get-Job -Id $Matches.JobId
	}
	else
	{
		Write-Warning "Something went wrong - no Job ist created. Abort..."
		Return;
	}
	
	$orderitemJob = Get-ApcJob -ParentId $job.Id -EntityKindId 21;
	$nodeJob = Get-ApcJob -ParentId $orderitemJob.Id -EntityKindId 1;
	$node = Get-ApcNode -Id $nodeJob.RefId;
	
	# If ($OwnerId)
	# {
		# $svc.Core.InvokeEntitySetActionWithVoidResult("SpecialOperations", "SetCreatedBy" , @{EntityId=$node.id;EntitySet="biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node";CreatedById=$OwnerId})
	# }

	# If ($TenantId)
	# {
		# $svc.Core.InvokeEntitySetActionWithVoidResult("SpecialOperations", "SetTenant" , @{EntityId=$node.id;EntitySet="biz.dfch.CS.Appclusive.Core.OdataServices.Core.Node";TenantId=$TenantId})
		# $svc.Core.Tenants.AddQueryOption('$filter','Name eq "Manage Customer Tenant"')
	# }
	
	$OutputParameter = Format-ResultAs $nodeJob $As
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

if($MyInvocation.ScriptName) { Export-ModuleMember -Function New-Order; } 