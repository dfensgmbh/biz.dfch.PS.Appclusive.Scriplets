function Test-MetadataIcon
{
	PARAM
	(
		[long] $ProductId = 20265L
		,
		[string] $Environment = 'DEV'
	)

	$svc = Enter-Appclusive $Environment;

	$q = "Id eq {0}" -f $ProductId;
	$product = $svc.Core.Products.AddQueryOption('$filter', $q) | Select;
	Contract-Assert (!!$product)
	
	$q = "Id eq {0}" -f $product.EntityKindId;
	$entityKind = $svc.Core.EntityKinds.AddQueryOption('$filter', $q);
	Contract-Assert (!!$entityKind)

	$knv = Get-ApcKeyNameValue -Key 'com.swisscom.cms.mssql2012.dbms.v001' -Name 'Icon-default';

	$action = New-Object biz.dfch.CS.Appclusive.Public.OdataServices.Core.MetadataManagerBaseParameters;
	$action.Request = "Icon";
	$iconName = $svc.Core.InvokeEntityActionWithSingleResult("Products", $ProductId, "Metadata", [string], $action);
	# $iconName = $svc.Core.InvokeEntityActionWithSingleResult("EntityKinds", $entityKind.Id, "Metadata", [string], $action);

	$OutputParameter = $iconName;
	return $OutputParameter;
}
