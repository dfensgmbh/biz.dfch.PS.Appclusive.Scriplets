Import-Module biz.dfch.PS.Appclusive.Client;
#$svc = Enter-ApcServer;
$svc = Enter-Appclusive LAB3;

function Create-Catalogue {
	Param
	(
		$svc
		,
		[string] $Name
	)
	
	$catalogueVersion = "1";
	$catalogueStatus = "Published";
	$catalogueDescription = "Description"
	
	#create catalog object
	$newCatalogue = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
	
	#add mandatory parameters
	$newCatalogue.Name = $Name;
	$newCatalogue.Version = $catalogueVersion;
	$newCatalogue.Status = $catalogueStatus;
	$newCatalogue.Tid = "11111111-1111-1111-1111-111111111111";
	$newCatalogue.Description = $catalogueDescription;
	
	#ACT - create new catalogue
	$svc.Core.AddToCatalogues($newCatalogue);
	$result = $svc.Core.SaveChanges();
	
	#get the catalogue
	$query = "Id eq {0}" -f $newCatalogue.Id;
	$newCatalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	
	#ASSERT for catalogue creation
	$newCatalogue | Should Not Be $null;
	$newCatalogue.Id | Should Not Be $null;
	$newCatalogue.Tid |Should Not Be $null;
	$result.StatusCode | Should Be 201;
	
	return $newCatalogue;
}

function Delete-Catalogue{
	Param
	(
		$svc
		,
		$catalogueId
	)
	
	#get the catalogue
	$query = "Id eq {0}" -f $catalogueId;
	$catalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	
	#delete catalogue
	$svc.Core.DeleteObject($catalogue);
	$result = $svc.Core.SaveChanges();
	
	#get the catalogue
	$query = "Id eq {0}" -f $catalogueId;
	$deletedCatalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	
	#ASSERT that catalogue is deleted
	$deletedCatalogue | Should Be $null;
	
	return $result;
}

function Create-Product {
	Param
	(
		$svc
		,
		$productName
	)
	#add parameters
	$newProduct = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$newProduct.Name = $productName;
	$newProduct.Description = "Arbitrary Product";
	$newProduct.Type = "Test Product";
	$newProduct.EntityKindId = 4864;
	$newProduct.Tid = "11111111-1111-1111-1111-111111111111";
	
	#create product
	$svc.Core.AddToProducts($newProduct);
	$result = $svc.Core.SaveChanges();
	
	#get product
	$query = "Id eq {0}" -f $newProduct.Id;
	$newProduct = $svc.Core.Products.AddQueryOption('$filter', $query) | select;
	
	#ASSERT product
	$newProduct | Should Not Be $null;
	$newProduct.Id | Should Not Be $null;
	$result.StatusCode | Should Be 201;

	return $newProduct;
}

function Delete-Product {
	Param 
	(
		$svc
		,
		$productId
	)
	
	#get the product
	$query = "Id eq {0}" -f $productId;
	$product = $svc.Core.Products.AddQueryOption('$filter', $query) | select;
	
	#delete product
	$svc.Core.DeleteObject($product);
	$result = $svc.Core.SaveChanges();
	
	#get the deleted product
	$query = "Id eq {0}" -f $productId;
	$deletedProduct = $svc.Core.Products.AddQueryOption('$filter', $query) | select;
	
	#ASSERT that product is deleted
	$deletedProduct | Should Be $null;
	
	return $result;
}

function Create-CatalogueItem {
	Param
	(
		$svc
		,
		$catalogueItemName
		,
		$productId
		,
		$catalogueId
	)
	
	#get Catalogue Item template
	$template = $svc.Core.InvokeEntitySetActionWithSingleResult('CatalogueItems', 'Template', [biz.dfch.CS.Appclusive.Api.Core.CatalogueItem], $null);
	#add parameters
	$newCatalogueItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$newCatalogueItem.ValidFrom = $template.ValidFrom
	$newCatalogueItem.ValidUntil = $template.ValidUntil
	$newCatalogueItem.EndOfLife = $template.EndOfLife
	$newCatalogueItem.Name = $catalogueItemName;
	$newCatalogueItem.Parameters = '{}';
	$newCatalogueItem.Description = 'Test Catalogue Item';
	$newCatalogueItem.ProductId = $productId;
	$newCatalogueItem.CatalogueId = $catalogueId;
	
	#create catalogueItem
	$svc.Core.AddToCatalogueItems($newCatalogueItem);
	$result = $svc.Core.SaveChanges();
	
	#get catalogueItem
	$query = "Id eq {0}" -f $newCatalogueItem.Id;
	$newCatalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#ASSERT catalogue Item
	$newCatalogueItem | Should Not Be $null;
	$newCatalogueItem.Id | Should Not Be $null;
	$result.StatusCode | Should Be 201;
	
	return $newCatalogueItem;

}

function Delete-CatalogueItem {
	Param
	(
		$svc
		,
		$catalogueItemId
	)
	
	#get the Catalogue Item
	$query = "Id eq {0}" -f $catalogueItemId;
	$catalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#delete the Catalogue Item
	$svc.Core.DeleteObject($catalogueItem);
	$result = $svc.Core.SaveChanges();
	
	#get the deleted Catalogue Item
	$query = "Id eq {0}" -f $catalogueItemId;
	$deletedCatalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#ASSERT that Catalogue Item is deleted
	$deletedCatalogueItem | Should Be $null;
	
	return $result;
}

function Update-Catalogue {
	Param
	(
		$svc
		,
		$catalogueId
		,
		$newCatalogueDescription
	)
	
	#get the Catalogue 
	$query = "Id eq {0}" -f $catalogueId;
	$catalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	$catalogueDescription = $catalogue.Description; #get old desription
	
	#update the Catalogue
	$catalogue.Description = $newCatalogueDescription;
	$svc.Core.UpdateObject($catalogue);
	$result = $svc.Core.SaveChanges();
	
	#get the updated Catalogue 
	$query = "Id eq {0}" -f $catalogueId;
	$updatedCatalogue = $svc.Core.Catalogues.AddQueryOption('$filter', $query) | select;
	
	#ASSERT - update
	$updatedCatalogue.Description | Should Be $newCatalogueDescription;
	$updatedCatalogue.Description | Should Not Be $catalogueDescription;
	$updatedCatalogue.Id | Should Be $catalogueId;
	
	return $updatedCatalogue;
}

function Update-CatalogueItem{
	Param
	(
		$svc
		,
		$catalogueItemId
		,
		$newCatalogueItemDescription
	)
	
	#get the Catalogue Item
	$query = "Id eq {0}" -f $catalogueItemId;
	$catalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	$catalogueItemDescription = $catalogueItem.Description; #get old description
	
	#update the Catalogue Item
	$catalogueItem.Description = $newCatalogueItemDescription;
	$svc.Core.UpdateObject($catalogueItem);
	$result = $svc.Core.SaveChanges();
	
	#get the updated Catalogue Item
	$query = "Id eq {0}" -f $catalogueItemId;
	$updatedCatalogueItem = $svc.Core.CatalogueItems.AddQueryOption('$filter', $query) | select;
	
	#ASSERT - update
	$updatedCatalogueItem.Description | Should Be $newCatalogueItemDescription;
	$updatedCatalogueItem.Description | Should Not Be $catalogueItemDescription;
	$updatedCatalogueItem.Id | Should Be $catalogueItemId;
	
	return $updatedCatalogueItem;
}


Describe -Tags "testCatalogue.Tests" "testCatalogue.Tests" {

    Context "#CLOUDTCL-Warmup" {
	
		It "ServiceReference-MustBeInitialised" -Test {
			$svc | Should Not Be $null;
		}
	}

    Context "#CLOUDTCL-Catalogue" {	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-Appclusive LAB3;
			#$svc = Enter-ApcServer;
		}
		
		It "CreateAndDeleteCatalogue" -Test {
			#ARRANGE
			$catalogueName = "newTestCatalogue";
			
			#ACT
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT - DeleteCatalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;	
		}
		
		It "CreateAndDeleteCatalogueItemInCatalogue" -Test {
			#ARRANGE
			$catalogueName = "newTestCatalogue";
			$productName = "newTestProduct";
			$catalogueItemName = "newTestCatalogueItem";
			
			#create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#create product
			$newProduct = Create-Product -svc $svc -productName $productName;
			$productId = $newProduct.Id;
						
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -catalogueItemName $catalogueItemName -productId $productId -catalogueId $catalogueId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#delete catalogue item
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId;
			
			#delete product
			Delete-Product -svc $svc -productId $productId;
			
			#delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		It "UpdateEmptyCatalogue" -Test {
			#ARRANGE
			$catalogueName = "newTestCatalogue";
			$newCatalogueDescription = "Updated Description";
			
			#ACT - create empty catalogue
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT - update description of empty catalogue
			$updatedCatalogue = Update-Catalogue -svc $svc -catalogueId $catalogueId -newCatalogueDescription $newCatalogueDescription;
			
			#ACT - delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		
		It "UpdateCatalogueWithCatalogueItem" -Test {	
			#ARRANGE
			$catalogueName = "newTestCatalogue";
			$productName = "newTestProduct";
			$catalogueItemName = "newTestCatalogueItem";
			$newCatalogueDescription = "Updated Description";
			
			#create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#create product
			$newProduct = Create-Product -svc $svc -productName $productName;
			$productId = $newProduct.Id;
						
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -catalogueItemName $catalogueItemName -productId $productId -catalogueId $catalogueId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#ACT - update description of catalogue
			$updatedCatalogue = Update-Catalogue -svc $svc -catalogueId $catalogueId -newCatalogueDescription $newCatalogueDescription;
			
			#delete catalogue item
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId;
			
			#delete product
			Delete-Product -svc $svc -productId $productId;
			
			#delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
		
		It "UpdateCatalogueItem" -Test {
			#ARRANGE
			$catalogueName = "newTestCatalogue";
			$productName = "newTestProduct";
			$catalogueItemName = "newTestCatalogueItem";
			$newCatalogueItemDescription = "Updated Description for Catalogue Item";
			
			#create catalogue
			$newCatalogue = Create-Catalogue -svc $svc -Name $catalogueName;
			$catalogueId = $newCatalogue.Id;
			
			#create product
			$newProduct = Create-Product -svc $svc -productName $productName;
			$productId = $newProduct.Id;
						
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -svc $svc -catalogueItemName $catalogueItemName -productId $productId -catalogueId $catalogueId;
			$catalogueItemId = $newCatalogueItem.Id;
			
			#ACT - update description of catalogue Item
			$updatedCatalogueItem = Update-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId -newCatalogueItemDescription $newCatalogueItemDescription;
			
			#delete catalogue item
			Delete-CatalogueItem -svc $svc -catalogueItemId $catalogueItemId;
			
			#delete product
			Delete-Product -svc $svc -productId $productId;
			
			#delete catalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
		}
	}
}