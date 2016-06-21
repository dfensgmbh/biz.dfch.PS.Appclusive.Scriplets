$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

Import-Module biz.dfch.PS.Appclusive.Client

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Appclusive.Products.Metadata" "Appclusive.Products.Metadata" {
	. "$here\$sut"

	Context "MetaData_PinDown" {
	
		BeforeAll {
			$svc = Enter-ApcServer;
			
			# New EntityKind
			$entityKindName = "com.swisscom.metadata";
			$entityKindVersionSuffix = 'V0001';
			$entityKindVersion = '{0}.{1}' -f $entityKindName, $entityKindVersionSuffix;
			
			$actionOnline = "goingOnline";
			$actionOffline = "goingOffline";
			$iconType = "status";
			
			$locale = '1033';
			$translationKey1 = "Arbitrary-Key-1";
			$translationKey2 = "Arbitrary-Key-2";
			
			$actionIcon = "Arbitrary-ActionIcon";
			$icon = "Arbitrary-Icon";
			
			$entityKind = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind
			$entityKind.Version = $entityKindVersion;
			# with Workflow:
			$entityKind.Parameters = '{{"InitialState-Initialise":"On","On-{0}":"Off","Off-{1}":"On"}}' -f $actionOffline, $actionOnline;
			$entityKind.Name = $entityKindName;
			
			$svc.Core.AddToEntityKinds($entityKind);
			$null = $svc.Core.SaveChanges();
			
			Write-Host ("Created EntityKind with Id:{0} and Version:'{1}'" -f $entityKind.Id, $entityKind.Version);
					
			# Add KeyValues for EntityKind
			$scheme = Get-Content -Raw "action-on.json" -Encoding Default
			New-ApcKeyNameValue -Key $entityKindVersion -Name ("Action-{0}" -f $actionOnline) -Value $scheme
			$scheme = Get-Content -Raw "action-off.json" -Encoding Default
			New-ApcKeyNameValue -Key $entityKindVersion -Name ("Action-{0}" -f $actionOffline) -Value $scheme
			New-ApcKeyNameValue -Key $entityKindVersion -Name "ActionIcon-default" -Value $actionIcon
			New-ApcKeyNameValue -Key $entityKindVersion -Name "Icon-default" -Value $icon
			New-ApcKeyNameValue -Key $entityKindVersion -Name ("Translation-{0}" -f $locale) -Value ('{{ "{0}": "Arbitrary-Text-1", "{1}": "Arbitrary-Text-2" }}' -f $translationKey1,$translationKey2);
			$scheme = Get-Content -Raw "EntCloudPortalUIProductDetails-default.json" -Encoding Default
			New-ApcKeyNameValue -Key $entityKindVersion -Name ("EntCloudPortalUIProductDetails-default" -f $actionOnline) -Value $scheme
					
			# Add new Product based on EntityKind
			$product = New-Object biz.dfch.CS.Appclusive.Api.Core.Product;
			$product.Type = 'Arbitrary';
			$product.Name = '{0}.product' -f $entityKindName;
			$product.EntityKindId = $entityKind.Id;
			$product.ValidFrom = [System.DateTimeOffset]::MinValue;
			$product.ValidUntil = [System.DateTimeOffset]::MaxValue;
			$product.EndOfLife = [System.DateTimeOffset]::MaxValue;
			
			$svc.Core.AddToProducts($product);
			$null = $svc.Core.SaveChanges();

			Write-Host ("Created Product with Id:{0} and Name:'{1}'" -f $product.Id, $product.Name);			
		}
		
		AfterAll {
			# Tear Down
			Write-Host "Removing Created Test Objects ... " -NoNewLine;
			$svc.Core.DeleteObject($product);
			$null = $svc.Core.SaveChanges();
			
			$kvps = $svc.Core.KeyNameValues.AddQueryOption('$filter',("Key eq '{0}'" -f $entityKindVersion))
			$kvps | ForEach { $svc.Core.DeleteObject($_); }
			$null = $svc.Core.SaveChanges();
			
			$svc.Core.DeleteObject($entityKind);
			$null = $svc.Core.SaveChanges();
			Write-Host "Done" -Foregroundcolor 'green';
		}
		
		It "Warmup" -Test {
			1 | Should Be 1;
		}
		
		It "Get-Metadata-Offline-UIDefinition" -Test {
			$parameters = @{};
			$parameters.Request = 'EntCloudPortalUIDefinition';
			$parameters.Action = $actionOffline;
			
			$metadata = $svc.Core.InvokeEntityActionWithSingleResult('Products', $product.Id, 'Metadata', [string], $parameters);
			
			$jsonValue = ConvertFrom-Json $metadata
			$fcontent = Get-Content -Raw "action-off.json" -Encoding Default
			$metadata | Should be $fcontent;
		}
		
		It "Get-Metadata-Online-UIDefinition" -Test {
			$parameters = @{};
			$parameters.Request = 'EntCloudPortalUIDefinition';
			$parameters.Action = $actionOnline;
			
			$metadata = $svc.Core.InvokeEntityActionWithSingleResult('Products', $product.Id, 'Metadata', [string], $parameters);
			
			$jsonValue = ConvertFrom-Json $metadata
			$fcontent = Get-Content -Raw "action-on.json" -Encoding Default
			$metadata | Should be $fcontent;			
		}
				
		It "Get-Metadata-Online-Icon" -Test {
			$parameters = @{};
			$parameters.Request = 'Icon';
			
			$metadata = $svc.Core.InvokeEntityActionWithSingleResult('Products', $product.Id, 'Metadata', [string], $parameters);
			
			$metadata | Should be $icon;
		}
				
		It "Get-Metadata-Online-ActionIcon" -Test {
			$parameters = @{};
			$parameters.Request = 'ActionIcon';
			$parameters.Action = $actionOnline;
			
			$metadata = $svc.Core.InvokeEntityActionWithSingleResult('Products', $product.Id, 'Metadata', [string], $parameters);
			
			$metadata | Should be $actionIcon;
		}
			
		It "Get-Metadata-Online-ProductDetails" -Test {
			$parameters = @{};
			$parameters.Request = 'EntCloudPortalUIProductDetails';
			
			$metadata = $svc.Core.InvokeEntityActionWithSingleResult('Products', $product.Id, 'Metadata', [string], $parameters);
			
			$jsonValue = ConvertFrom-Json $metadata
			$fcontent = Get-Content -Raw "EntCloudPortalUIProductDetails-default.json" -Encoding Default
			$metadata | Should be $fcontent;
		}
			
		It "Get-Metadata-Online-Translations" -Test {
			$parameters = @{};
			$parameters.Request = 'Translation';
			$parameters.Locale = $locale;
			$parameters.Keys = @($translationKey1, $translationKey2);
			
			$metadata = $svc.Core.InvokeEntityActionWithSingleResult('Products', $product.Id, 'Metadata', [string], $parameters);
			
			$translations = ConvertFrom-Json $metadata;
			
			$translations.$translationKey1 | Should be "Arbitrary-Text-1";
			$translations.$translationKey2 | Should be "Arbitrary-Text-2";
		}		
	}
}