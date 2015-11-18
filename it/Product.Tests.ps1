$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Product.Tests" "Product.Tests" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"
	. "$here\Catalogue.ps1"
	
	
	Context "Product.Tests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-AppclusiveServer;
		}
		
		It "LoadProductsCreatedBySeed" -Test {
			# Arrange
			
			# Act
			$products = $svc.Core.Products;
			
			# Assert
			$products | Should Not Be $null;
			$products.Name -contains "VDI Personal" | Should Be $true;
			$products.Name -contains "VDI Technical" | Should Be $true;
			$products.Name -contains "DSWR Autocad 12 Production" | Should Be $true;
		}
		
		It "CreateAndDeleteProduct" -Test {
			try 
			{
				# Arrange
				$productName = 'Product PesterTest';
				$productDescription = 'Product created in pester tests';
				
				# Act
				$product = CreateProduct -productName $productName -productDescription $productDescription;
				$svc.Core.AddToProducts($product);
				$result = $svc.Core.SaveChanges();
				
				# Assert
				$result.StatusCode | Should Be 201;
				$product.Id | Should Not Be 0;
			} 
			finally 
			{
				#Cleanup
				$svc.Core.DeleteObject($product);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "LoadCatalogueItemsOfProduct" -Test {
			try 
			{
				# Arrange
				$productName = 'Product PesterTest';
				$productDescription = 'Product created in pester tests';
				$catName = 'NewCatalogueInTest'
			
				# Create catalogue
				$cat = CreateCatalogue -catName $catName
				$svc.Core.AddToCatalogues($cat);
				$result = $svc.Core.SaveChanges();
				
				# Create product
				$product = CreateProduct -productName $productName -productDescription $productDescription;
				$svc.Core.AddToProducts($product);
				$result = $svc.Core.SaveChanges();
				
				# Add catalogue item
				$catItem = CreateCatalogueItem -cat $cat -product $product;
				$svc.Core.AddToCatalogueItems($catItem);
				$result = $svc.Core.SaveChanges();
				
				# Act
				$catalogueItemOfProduct = $svc.Core.LoadProperty($product, 'CatalogueItems') | Select;
				
				# Assert
				$result.StatusCode | Should Be 201;
				$catalogueItemOfProduct | Should Not Be $null;
				$catalogueItemOfProduct.Id | Should Be $catItem.Id;
			} 
			finally 
			{
				# Cleanup
				$svc.Core.DeleteObject($catItem);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($product);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
				
				$svc.Core.DeleteObject($cat);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
		
		It "UpdateProduct" -Test {
			try 
			{
				# Arrange
				$productName = 'Product PesterTest';
				$productDescription = 'Product created in pester tests';
				
				$productNameUpdate = 'Name updated'
				$productDescriptionUpdate = 'Description updated';
				$productVersionUpdate = 2;
				$productTypeUpdate = "Type updated";
				$productValidFromUpdate = [DateTimeOffset]::Now.AddDays(365);
				$productValidUntilUpdate = [DateTimeOffset]::Now.AddDays(365);
				$productEndOfSaleUpdate = [DateTimeOffset]::Now.AddDays(365);
				$productEndOfLifeUpdate = [DateTimeOffset]::Now.AddDays(365);
				$productParameterUpdate = 'New Parameter';
				
				$product = CreateProduct -productName $productName -productDescription $productDescription;
				$svc.Core.AddToProducts($product);
				$result = $svc.Core.SaveChanges();

				# Act
				$product.Name = $productNameUpdate;
				$product.Description = $productDescriptionUpdate
				$product.Type = $productTypeUpdate;
				$product.Version = $productVersionUpdate;
				$product.ValidFrom = $productValidFromUpdate;
				$product.ValidUntil = $productValidUntilUpdate;
				$product.EndOfSale = $productEndOfSaleUpdate;
				$product.EndOfLife = $productEndOfLifeUpdate;
				$product.Parameters = $productParameterUpdate;

				$svc.Core.UpdateObject($product);
				$result = $svc.Core.SaveChanges();
				
				$productReload = $svc.Core.Products.AddQueryOption('$filter', "Id eq {0}" -f $product.Id) | Select;
				
				# Assert
				$result.StatusCode | Should Be 204;
				$product.Id | Should Not Be 0;
				
				$productReload.Name | Should Be $productNameUpdate;
				$productReload.Description | Should Be $productDescriptionUpdate
				$productReload.Type | Should Be $productTypeUpdate;
				$productReload.Version | Should Be $productVersionUpdate;
				$productReload.ValidFrom | Should Be $productValidFromUpdate;
				$productReload.ValidUntil | Should Be $productValidUntilUpdate;
				$productReload.EndOfSale | Should Be $productEndOfSaleUpdate;
				$productReload.EndOfLife | Should Be $productEndOfLifeUpdate;
				$productReload.Parameters | Should Be $productParameterUpdate;
			} 
			finally 
			{
				#Cleanup
				$svc.Core.DeleteObject($product);
				$result = $svc.Core.SaveChanges();
				$result.StatusCode | Should Be 204;
			}
		}
	}
	
}