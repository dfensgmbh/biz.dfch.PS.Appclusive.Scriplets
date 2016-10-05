#Requires -Modules @{ ModuleName = "biz.dfch.PS.Appclusive.Client"; ModuleVersion = "2.8.1" }
PARAM
(
	$Name = 'ch.srgssr.cms.Solution'
	,
	$Description = ''
	,
	$Version = ('{0}.V0001' -f $Name)
	,
	$CatalogueId = 1
)

# optionally login
# Import-Module biz.dfch.PS.Appclusive.Client
# $svc = Enter-ApcServer
# $svc

# make sure the specified catalogue is available 
$q = "CatalogueId eq {0}" -f $CatalogueId;
$catalogue = $svc.Core.CatalogueItems.AddQueryOption('$filter', $q) | Select;
Contract-Assert (!!$catalogue)

# get the template for a catalogueItem
$catalogueItemTemplate = $svc.Core.InvokeEntitySetActionWithSingleResult('CatalogueItems', 'Template', [biz.dfch.CS.Appclusive.Api.Core.CatalogueItem], $null);

$catalogueItemTemplate
# CatalogueId  : 0
# ProductId    : 0
# ValidFrom    : 01.01.0001 00:00:00 +00:00
# ValidUntil   : 31.12.9999 23:59:59 +00:00
# EndOfLife    : 31.12.9999 23:59:59 +00:00
# Parameters   : optional
# Id           : 0
# Tid          : 22222222-2222-2222-2222-222222222222
# Name         : required
# Description  : optional
# CreatedById  : 1
# ModifiedById : 1
# Created      : 06.06.2016 08:37:05 +02:00
# Modified     : 06.06.2016 08:37:05 +02:00
# RowVersion   :
# Catalogue    :
# Product      :
# Tenant       :
# CreatedBy    :
# ModifiedBy   :

# create a new CatalogueItem
$c = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem;
$c.CatalogueId = $CatalogueId
$c.ValidFrom = $catalogueItemTemplate.ValidFrom;
$c.ValidUntil = $catalogueItemTemplate.ValidUntil;
$c.EndOfLife = $catalogueItemTemplate.EndOfLife;
$c.Name = $Name;
$c.Description = $Description;
$c.ProductId = $ProductId;

# save it to Appclusive
$svc.Core.AddToCatalogueItems($c);
$svc.Core.UpdateObject($c);
$svc.Core.SaveChanges();

# $svc.Core.Products.AddQueryOption('$filter', "Id eq 11");
# $svc.Core.EntityKinds.AddQueryOption('$filter', "Id eq 4108");
# $svc.Core.Products
# $svc.Core.Products | Select Name
# $svc.Core.Products | Select Name, Type, Id
# $svc.Core.Products | Get-Member

$entityKindTemplate = $svc.Core.InvokeEntitySetActionWithSingleResult('EntityKinds', 'Template', [biz.dfch.CS.Appclusive.Api.Core.EntityKind], $null);
$entityKindTemplate
# Version      : required
# Parameters   : optional
# Id           : 0
# Tid          : 22222222-2222-2222-2222-222222222222
# Name         : required
# Description  : optional
# CreatedById  : 1
# ModifiedById : 1
# Created      : 06.06.2016 08:47:19 +02:00
# Modified     : 06.06.2016 08:47:19 +02:00
# RowVersion   :
# Tenant       :
# CreatedBy    :
# ModifiedBy   :

# create a new EntityKind
$ek = New-Object biz.dfch.CS.Appclusive.Api.Core.EntityKind;
$ek.Version = $Version;
$ek.Name = $Name;
$ek.Description = $Description;
$svc.Core.AddToEntityKinds($ek);
$svc.Core.UpdateObject($ek);
$svc.Core.SaveChanges();

$e
$svc.Core.EntityKinds.AddQueryOption('$filter', "Id eq 4111")
$p = $svc.Core.Products.AddQueryOption('$filter', "Name eq 'Solution'") | select
$p
$p = $svc.Core.Products.AddQueryOption('$filter', "Name eq 'Solution'") | select
cls
$svc.Core.Products | Get-Member
$p = New-Object biz.dfch.CS.Appclusive.Api.Core.Product
$p
$svc.Core.Products
$p
$p.Type = 'ch.srgssr.cloud.solution'
$p = $svc.Core.EntityKind.AddQueryOption('$filter', "Name eq 'Solution'") | select
$p = $svc.Core.EntityKinds.AddQueryOption('$filter', "Name eq 'Solution'") | select
$p
$p = $svc.Core.EntityKinds.AddQueryOption('$filter', "Name eq 'Solution'") | select
$e
$p = New-Object biz.dfch.CS.Appclusive.Api.Core.Product
$p.Name = 'ch.srgssr.cloud.solution'
$p.EntityKindId = 4111
$p.Description = "Create a new solution"
$svc.Core.AddToProducts($p);
$svc.Core.UpdateObject($p);
$svc.Core.SaveChanges();
$p
$Error[0].Exception.InnerException.InnerException
$p.Type = 'ch.srgssr.cloud.solution'
$svc.Core.AddToProducts($p);
$svc.Core.UpdateObject($p);
$svc.Core.SaveChanges();
$Error[0].Exception.InnerException.InnerException
$svc.Core.SaveChanges();
$p
$c
$svc.Core.DeleteObject($c)
$svc.Core.SaveChanges()
$c
$c = New-Object biz.dfch.CS.Appclusive.Api.Core.CatalogueItem
$c
$c.ProductId = 14
$c.Name = "Solution"
$c.Description = 'Use this product to create a new solution.'
$svc.Core.AddToCatalogueItems($c);
$svc.Core.UpdateObject($c);
$svc.Core.SaveChanges();
$svc.Core.InvokeEntitySetActionWithSingleResult('CatalogueItems', 'Template', [biz.dfch.CS.Appclusive.Api.Core.CatalogueItem], $null)
$c
$c.CatalogueId = 1
$c.ValidUntil = [System.DateTimeOffset]::MaxValue
$c.EndOfLife = [System.DateTimeOffset]::MaxValue
$svc.Core.UpdateObject($c)
$svc.Core.SaveChanges();

#
# Copyright 2016 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
