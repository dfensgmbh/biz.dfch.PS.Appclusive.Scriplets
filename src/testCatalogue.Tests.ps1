Import-Module biz.dfch.PS.Appclusive.Client
#enter credentials to connect to lab3 (domain of lab3 = w2012r2-t6-10) & connect to server
#$credentials = Get-Credential -UserName "w2012r2-t6-10\Administrator" -Message "Login To Lab3" 
#$svc = Enter-ApcServer -ServerBaseUri "http://172.19.115.33/appclusive" -Credential $credentials



function Create-Catalogue {
	Param
	(
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
	
	#ACT - create new catalogue
	$svc.Core.AddToCatalogues($newCatalogue);
	$result = $svc.Core.SaveChanges();
	
	$result.StatusCode | Should Be 201;
	
	return $newCatalogue;
}

function Delete-Catalogue{
	Param
	(
	$catalogue
	)
	
	#Write-Host $catalogToDelete;
	#delete catalogue
	$svc.Core.DeleteObject($catalogue);
	$result = $svc.Core.SaveChanges();
	
	return $result;
}

function Create-Product {
	$newProduct = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
	$newProduct.Name = "new Product";
	$newProduct.Description = "Test Product";
	$newProduct.Type = "Test Product";
	$newProduct.EntityKindId = 4864;
	$newProduct.Tid = "11111111-1111-1111-1111-111111111111";
	
	$svc.Core.AddToProducts($newProduct);
	$result = $svc.Core.SaveChanges();

	$result.StatusCode | Should Be 201;

	return $newProduct;

}

function Delete-Product {
	Param 
	(
		$product
	)
	$svc.Core.DeleteObject($product);
	$result = $svc.Core.SaveChanges();
	
	return $result;
}

function Create-CatalogueItem {
	Param
	(
		$productId
		,
		$catalogId
	)
	
	$template = $svc.Core.InvokeEntitySetActionWithSingleResult('CatalogueItems', 'Template', [biz.dfch.CS.Appclusive.Api.Core.CatalogueItem], $null);
	
	$newCatalogueItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
	$newCatalogueItem.ValidFrom = $template.ValidFrom
	$newCatalogueItem.ValidUntil = $template.ValidUntil
	$newCatalogueItem.EndOfLife = $template.EndOfLife
	$newCatalogueItem.Name = "NewCatalogueItem";
	$newCatalogueItem.Parameters = '{}';
	$newCatalogueItem.Description = 'some description';
	$newCatalogueItem.ProductId = $productId;
	$newCatalogueItem.CatalogueId = $catalogId;
	
	$svc.Core.AddToCatalogueItems($newCatalogueItem);
	$result = $svc.Core.SaveChanges();
	
	$result.StatusCode | Should be 201;
	
	return $newCatalogueItem;

}

function Delete-CatalogueItem {
	Param(
	$catalogueItem
	)
	$svc.Core.DeleteObject($catalogueItem);
	$result = $svc.Core.SaveChanges();
	
	return result;
}



Describe -Tags "testCatalogue.Tests" "testCatalogue.Tests" {

    Context "#CLOUDTCL-Warmup" {
	
		It "ServiceReference-MustBeInitialised" -Test {
			$svc | Should Not Be $null;
		}
	}

    Context "#CLOUDTCL-Catalogue" {
	
        <#
		It "CreateCatalogue" -Test {
		
			#ARRANGE
			$catName = "TestCatalogue";
			
			#ACT
			$sut = Create-Catalogue -Name $catName;
						
			#ASSERT
			$sut | Should Not Be $null;
			$sut.Id | Should Not Be $null;
			$sut.Tid |Should Not Be $null;
		}
		#>
		<#
		It "DeleteCatalogue" -Test {
			#ARRANGE
			$catName = "TestCatalogue-tobeDeleted";
			
			#ACT
			$newCatalogue = Create-Catalogue -Name $catName;
			
			#ASSERT for catalogue creation
			$newCatalogue | Should Not Be $null;
			$newCatalogue.Id | Should Not Be $null;
			$newCatalogue.Tid |Should Not Be $null;
			
			#ACT - DeleteCatalogue
			#$result = Delete-Catalogue -catalogue $newCatalogue;
			$catalogToDelete = $svc.Core.DeleteObject($newCatalogue);
			#$result = $svc.Core.SaveChanges();
			
			#ASSERT for catalogue deletion
			#$query = "Id eq {0}" -f $newCatalogue.Id;
			#$deletedCatalog = $svc.Core.Catalogues.AddQueryOption('$filter', $query);
			#$deletedCatalog | Should Be $null;
			
			$query = "Id eq 98";
			$deletedCatalog = $svc.Core.Catalogues.AddQueryOption('$filter', $query);
			
			
		}#>
		
		#<#
		It "CreateCatalogueItemInCatalogue" -Test {
			
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
			
			#delete catalogue item
			Delete-CatalogueItem -catalogueItem $newCatalogueItem;
			
			#delete product
			Delete-Product -product $newProduct;
			
			#delete catalogue
			Delete-Catalogue -catalogue $catalogue;
		}#>
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