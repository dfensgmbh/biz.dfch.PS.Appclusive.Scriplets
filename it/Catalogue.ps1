function GetCatalogueByName($svc, $catName) {
	return $svc.Core.Catalogues |? Name -eq $catName;
}

function GetCatalogueItemsOfCatalog($svc, $cat) {
	return $svc.Core.LoadProperty($cat, 'CatalogueItems') | Select;
}

function GetCatalogueItemByName($svc, $name) {
	return $svc.Core.CatalogueItems |? Name -eq $name;
}

function CreateCatalogueItem($catalogue) {
	$catItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$catItem.Tid = "1";
	$catItem.CreatedBy = $ENV:USERNAME;
	$catItem.ModifiedBy = $catItem.CreatedBy;
	$catItem.Created = [DateTimeOffset]::Now;
	$catItem.Modified = $catItem.Created;
	$catItem.Name = 'Arbitrary Item';
	$catItem.CatalogueId = $catalogue.Id;
	$catItem.Type = 'Arbitrary Type';
	$catItem.Version = '1.0';
	$catItem.ValidFrom = [DateTimeOffset]::Now;
	$catItem.ValidUntil = [DateTimeOffset]::Now;
	$catItem.EndOfSale = [DateTimeOffset]::Now;
	$catItem.EndOfLife = [DateTimeOffset]::Now;
	$catItem.Parameters = '{}';
	
	return $catItem;
}