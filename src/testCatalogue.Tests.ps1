Import-Module biz.dfch.PS.Appclusive.Client
#enter credentials to connect to lab3 (domain of lab3 = w2012r2-t6-10) & connect to server
#$credentials = Get-Credential -UserName "w2012r2-t6-10\Administrator" -Message "Login To Lab3" 
#$svc = Enter-ApcServer -ServerBaseUri "http://172.19.115.33/appclusive" -Credential $credentials


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
			#create catalog object
			$newCatalogue = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
			#add mandatory properties
			$newCatalogue.Name = "PBCatalogue";
			$newCatalogue.Version = "1";
			$newCatalogue.Status = "Published";
			
			#ACT - create new catalogue
			$svc.Core.AddToCatalogues($newCatalogue);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT
			$newCatalogue | Should Not Be $null;
			$newCatalogue.Id | Should Not Be $null;
			$newCatalogue.Tid |Should Not Be $null;
			$result.StatusCode | Should Be 201;
			
		}
		
		It "DeleteCatalogue" -Test {
			#ARRANGE
			#create catalog object
			$newCatalogue = New-Object biz.dfch.CS.Appclusive.Api.Core.Catalogue;
			#add mandatory properties
			$newCatalogue.Name = "PBCatalogue";
			$newCatalogue.Version = "1";
			$newCatalogue.Status = "Published";
			$newCatalogue.Tid = "ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe";
			
			#ACT - create new catalogue
			$svc.Core.AddToCatalogues($newCatalogue);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT
			$newCatalogue | Should Not Be $null;
			$newCatalogue.Id | Should Not Be $null;
			$newCatalogue.Tid |Should Not Be $null;
			$result.StatusCode | Should Be 201;
			
			#ACT - DeleteCatalogue
			$svc.Core.DeleteObject($newCatalogue);
			$result = $svc.Core.SaveChanges();
			
			#ASSERT
			$query = "Id eq {0}" -f $newCatalogue.Id;
			$deletedCatalog = $svc.Core.Catalogues.AddQueryOption('$filter', $query);
			$deletedCatalog | Should Be $null;
			
			
		}
		
		
	}
}