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
	
	return $newCatalogue;
}



Describe -Tags "testCatalogue.Tests" "testCatalogue.Tests" {

    Context "#CLOUDTCL-Warmup" {
	
		It "ServiceReference-MustBeInitialised" -Test {
			$svc | Should Not Be $null;
		}
	}

    Context "#CLOUDTCL-Catalogue" {
	
		# pass the test set to the test
        It "CreateCatalogue" -Test {
		
			#ARRANGE
			$catName = "PBCatalogue";
			
			#ACT
			$sut = Create-Catalogue -Name $catName;
			
			#ACT - create new catalogue
			$svc.Core.AddToCatalogues($sut);
			$result = $svc.Core.SaveChanges();
						
			#ASSERT
			$sut | Should Not Be $null;
			$sut.Id | Should Not Be $null;
			$sut.Tid |Should Not Be $null;
			$result.StatusCode | Should Be 201;
			
		}
		
		It "DeleteCatalogue" -Test {
			#ARRANGE
			$catName = "PBCatalogue";
			
			#ACT
			$sut = Create-Catalogue -Name $catName;
			
			#ACT - create new catalogue
			$svc.Core.AddToCatalogues($sut);
			$result = $svc.Core.SaveChanges();
						
			#ASSERT
			$sut | Should Not Be $null;
			$sut.Id | Should Not Be $null;
			$sut.Tid |Should Not Be $null;
			$result.StatusCode | Should Be 201;
			
			#ACT - DeleteCatalogue
			$svc.Core.DeleteObject($sut);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT
			$query = "Id eq {0}" -f $sut.Id;
			$deletedCatalog = $svc.Core.Catalogues.AddQueryOption('$filter', $query);
			$deletedCatalog | Should Be $null;
			
			
		}
		
		
		It "CreateCatalogueItemInCatalogue" -Test {
			
			#create product
			$newProduct = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
			$newProduct.Name = "new Product";
			$newProduct.Description = "Test Product";
			$newProduct.Type = "Test Product";
			$newProduct.EntityKindId = 4864;
			$newProduct.Tid = "11111111-1111-1111-1111-111111111111";
			$svc.Core.AddToProducts($newProduct);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT product
			$result.StatusCode | Should Be 201;
			$newCatalogueItem.Id | Should Not Be $null;
			
			#create catalogue item
			$newCatalogueItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
			$newCatalogueItem.Name = "NewCatalogueItem";
			$newCatalogueItem.ProductId = $newProduct.Id;
			$newCatalogueItem.CatalogueId = 37;
			$svc.Core.AddToCatalogueItems($newCatalogueItem);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT catalogue item
			$result.StatusCode | Should be 201;
			$newCatalogueItem.Id | Should Not Be $null;
		
		}
	}
}