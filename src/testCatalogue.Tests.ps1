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
	
	$catVersion = "1";
	$catStatus = "Published";
	
	#create catalog object
	$newCatalogue = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
	
	#add mandatory properties
	$newCatalogue.Name = $Name;
	$newCatalogue.Version = $catVersion;
	$newCatalogue.Status = $catStatus;
	$newCatalogue.Tid = "11111111-1111-1111-1111-111111111111";
	
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
	#add properties
	$newProduct = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$newProduct.Name = $productName;
	$newProduct.Description = "Aritrary Product";
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
	
	#get the product
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
	
	$template = $svc.Core.InvokeEntitySetActionWithSingleResult('CatalogueItems', 'Template', [biz.dfch.CS.Appclusive.Api.Core.CatalogueItem], $null);
	
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
	Param(
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
			$catName = "newTestCatalogue";
			
			#ACT
			$newCatalogue = Create-Catalogue -svc $svc -Name $catName;
			$catalogueId = $newCatalogue.Id;
			
			#ACT - DeleteCatalogue
			Delete-Catalogue -svc $svc -catalogueId $catalogueId;
			
		}
		
		It "CreateCatalogueItemInCatalogue" -Test {
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
		<#
		It "UpdateCatalogue" -Test {
			
			#ARRANGE
			$catName = "EmptyCatalogue";
			$catNewName = "EmptyCatalogue Updated";
			$catNewDescription = "This is the new description for catalogue";
			
			#ACT - create catalogue
			#$newCatalogue = Create-Catalogue -Name $catName;
			$catVersion = "1";
			$catStatus = "Published";
	
			#create catalog object
			$newCatalogue = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
	
			#add mandatory properties
			$newCatalogue.Name = $catName;
			$newCatalogue.Version = $catVersion;
			$newCatalogue.Status = $catStatus;
	
			#ACT - create new catalogue
			$svc.Core.AddToCatalogues($newCatalogue);
			$result = $svc.Core.SaveChanges();
	
			$result.StatusCode | Should Be 201;
			
			#ASSERT
			$newCatalogue | Should Not Be $null;
			$newCatalogue.Id | Should Not Be $null;
			$newCatalogue.Tid |Should Not Be $null;
			$newCatalogue.Name | Should Not Be $null;
			Write-Host $catalogue.Name;
			
			#$catalogue.Name = $catNewName;
			$newcatalogue.Description = $catNewDescription;
			
			#ACT - update empty 
			$svc.Core.UpdateObject($newCatalogue);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT - update
			$query = "Id eq {0}" -f $newCatalogue.Id;
			$updatedCatalogue = $svc.core.Catalogues.AddQueryOption('$filter', $query);
			$updatedCatalogue.Description | Should Be $catNewDescription;
			
			#create product
			#$newProduct = Create-Product;
			$newProduct = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
			$newProduct.Name = "new Product";
			$newProduct.Description = "Test Product";
			$newProduct.Type = "Test Product";
			$newProduct.EntityKindId = 4864;
			$newProduct.Tid = "11111111-1111-1111-1111-111111111111";
			
			$newProduct = $svc.Core.AddToProducts($newProduct);
			$result = $svc.Core.SaveChanges();

			$result.StatusCode | Should Be 201;
			
			#create catalogue item
			$newCatalogueItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
			$newCatalogueItem.Name = "NewCatalogueItem";
			$newCatalogueItem.ProductId = $newProduct.Id;
			$newCatalogueItem.CatalogueId = $newCatalogue.Id;

			$svc.Core.AddToCatalogueItems($newCatalogueItem);
			$result = $svc.Core.SaveChanges();
			
			$result.StatusCode | Should be 201;
			
			#update catalogue with a catalogue item
			
			#delete catalogue item
			
			#delete product
			
			#delete catalogue
			
			
		}
		#>
		<#
		It "UpdateCatalogueItem" -Test {
			#ARRANGE
			$catName = "TestCatalogue";
			
			#ACT - create catalogue
			$catalogue = Create-Catalogue -Name $catName;
	
			#ASSERT for catalogue creation
			$catalogue | Should Not Be $null;
			$catalogue.Id | Should Not Be $null;
			$catalogue.Tid |Should Not Be $null;
			
			#ACT - create product
			$newProduct = Create-Product;
			
			#ASSERT product
			$newProduct | Should Not Be $null;
			$newProduct.Id | Should Not Be $null;
			
			#create catalogue item
			$newCatalogueItem = Create-CatalogueItem -productId $newProduct.Id -catalogId $catalogue.Id;
			
			#ASSERT catalogue item
			$newCatalogueItem.Id | Should Not Be $null;
			
			#ACT update catalogue item
			$newDescription = "updated Description"
			$newCatalogueItem.description = $newDescription;
			$svc.Core.Update($newCatalogueItem);
			$result = $svc.Core.SaveChanges();
			
		
		}#>
	}
}