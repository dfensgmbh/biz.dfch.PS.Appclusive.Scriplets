Import-Module biz.dfch.PS.Appclusive.Client;
#$svc = Enter-ApcServer;
$svc = Enter-Appclusive LAB3;

$here = Split-Path -Parent $MyInvocation.MyCommand.Path;
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".");

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "CatalogueandCatalogueItems.Tests" "CatalogueandCatalogueItems.Tests" {

	Mock Export-ModuleMember { return $null; }
	. "$here\$sut"

    <#Context "TestServer" {
	
		It "ServiceReference-MustBeInitialised" -Test {
			$svc | Should Not Be $null;
		}
	}#>

    Context "#CLOUDTCL-2191-Catalogue" {	
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