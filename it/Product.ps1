function CreateProduct() {
	$product = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$product.Tid = "1";
	$product.CreatedBy = $ENV:USERNAME;
	$product.ModifiedBy = $product.CreatedBy;
	$product.Created = [DateTimeOffset]::Now;
	$product.Modified = $product.Created;
	$product.Name = 'Arbitrary Item';
	$product.Type = 'Arbitrary Type';
	$product.Version = '1.0';
	$product.ValidFrom = [DateTimeOffset]::Now;
	$product.ValidUntil = [DateTimeOffset]::Now;
	$product.EndOfSale = [DateTimeOffset]::Now;
	$product.EndOfLife = [DateTimeOffset]::Now;
	$product.Parameters = '{}';
	
	return $product;
}