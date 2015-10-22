function CreateOrder($requester = $null) {
	$order = New-Object biz.dfch.CS.Appclusive.Api.Core.Order;
	$order.Tid = "1";
	$order.CreatedBy = $ENV:USERNAME;
	$order.ModifiedBy = $order.CreatedBy;
	$order.Created = [DateTimeOffset]::Now;
	$order.Modified = $order.Created;
	$order.Name = 'Arbitrary Order';
	$order.Requester = $requester
	$order.Parameters = '{}';
	return $order;
}