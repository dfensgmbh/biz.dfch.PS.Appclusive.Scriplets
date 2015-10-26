function CreateOrder {
[CmdletBinding()]
PARAM
(
	[Parameter(Mandatory = $false, Position = 0)]
	[string] $OrderName = 'Arbitrary Order'
)

	$order = New-Object biz.dfch.CS.Appclusive.Api.Core.Order;
	$order.Tid = "1";
	$order.CreatedBy = $ENV:USERNAME;
	$order.ModifiedBy = $order.CreatedBy;
	$order.Created = [DateTimeOffset]::Now;
	$order.Modified = $order.Created;
	$order.Name = $OrderName;
	$order.Parameters = '{}';
	return $order;
}