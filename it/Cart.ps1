function CreateCartItem($catItem) {
	$cartItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CartItem;
	$cartItem.Tid = "1";
	$cartItem.Quantity = 1;
	$cartItem.CreatedBy = $ENV:USERNAME;
	$cartItem.ModifiedBy = $catItem.CreatedBy;
	$cartItem.Created = [DateTimeOffset]::Now;
	$cartItem.Modified = $catItem.Created;
	$cartItem.Name = $catItem.Name;
	$cartItem.CatalogueItemId = $catItem.Id;
	$cartItem.Parameters = '{}';
	return $cartItem;
}

function GetCartOfUser($svc) {
	$user = "{0}\{1}" -f $ENV:USERDOMAIN, $ENV:USERNAME;
	return $svc.Core.Carts |? CreatedBy -eq $user;
}

function GetCartItemsOfCart($svc, $cart) {
	return $svc.Core.LoadProperty($cart, 'CartItems') | Select;
}