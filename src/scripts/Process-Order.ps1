$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# DFTODO - I would not dotsource these scripts but write scripts with PARAM block, so they can be called like Cmdlets
. "$here\Process-VDIAssignment.ps1"

function ProcessOrder($svc, $orderJob) {
	
	$tenantNodeName = 'TenantNode';
	
	# Check if tenantNode exists
	$filterQuery = "startswith(Name, '{0}') eq true" -f $tenantNodeName;
	$tenantNode = $svc.Core.Nodes.AddQueryOption('$filter', $filterQuery) | Select;
	
	if($null -eq $tenantNode)
	{
		$msg = "TenantNode does not exist for tenant '{0}'" -f $orderJob.Tid;
		Write-Host $msg;
		return;
	}
	
	# Load order based on job
	$order = $svc.Core.Orders.AddQueryOption('$filter', "Id eq " + $orderJob.ReferencedItemId) | Select;
	
	# Set order status to 'Running'
	UpdateOrder -order $order -status 'Continue';
	
	####
	# DFTODO - Replace with call to 'RemoveIfNeeded' as soon it's implemented in API
	$svc = Enter-Appclusive;
	$tenantNode = $svc.Core.Nodes.AddQueryOption('$filter', $filterQuery) | Select;
	$order = $svc.Core.Orders.AddQueryOption('$filter', "Id eq " + $orderJob.ReferencedItemId) | Select;
	####
	

	# Load VDI order item
	$orderItems = $svc.Core.LoadProperty($order, 'OrderItems') | Select;
	$vdiOrderItem = $orderItems |? Type -Match 'VDI';
	
	if($vdiOrderItem)
	{
		# Load product of orderItem
		$catalogueItem = $vdiOrderItem.Parameters -join "`n" | ConvertFrom-Json;
		$product = $catalogueItem.Product;
		
		$result = ProcessVDIEntitlement -username $order.Requester;
		
		# Create inventory entry for VDI
		if($result -eq $true)
		{			
			CreateInventoryEntry -svc $svc -parentNode $tenantNode -product $product;
		}
		else 
		{
			UpdateOrder -order $order -status 'Cancel' -errorMsg $result;
			return;
		}
	}
	
	$nonVDIorderItems = $orderItems |? Type -ne 'VDI';
	foreach($orderItem in $nonVDIorderItems)
	{
		# DFTODO - Implement handling of SW Package OrderItems
		# DFTODO - Be aware of time offset between deployment of VDI and SW package assignment
		# DFTODO - Set VDI node item as parent
		# DFTODO - Handle requester of Order (Impersonate creation?)
	}
	
	UpdateOrder -order $order -status 'Continue';
}

function CreateInventoryEntry($svc, $parentNode, $product) 
{
	$node = New-Object biz.dfch.CS.Appclusive.Api.Core.Node;
	$svc.Core.AddToNodes($node);
	$node.Name = $product.Name;
	$node.Description = $product.Description;
	$node.Parameters = '{}';
	$node.Type = $product.Type;
	$node.Created = [System.DateTimeOffset]::Now;
	$node.Modified = $node.Created;
	$node.CreatedBy = "SYSTEM";
	$node.ModifiedBy = $node.CreatedBy;
	$node.Tid = "1";
	$node.Id = 0;
	$node.ParentId = $parentNode.Id;
	$svc.Core.UpdateObject($node);
	$svc.Core.SaveChanges();
}

function UpdateOrder($order, $status, $errorMsg = '')
{
	$svc2 = Enter-Appclusive;
	try
	{
		# DFTODO - Create class of contracts package!
		$error = $errorMsg;
		$orderToBeUpdated = $svc2.Core.Orders.AddQueryOption('$filter', "Id eq " + $order.Id) | Select;
		$orderToBeUpdated.Status = $status;
		$orderToBeUpdated.Parameters = $error;
		$svc2.Core.UpdateObject($orderToBeUpdated);
		$svc2.Core.SaveChanges();
	}
	catch
	{
		if (!$error[0].Exception.InnerException.InnerException.Message.EndsWith("is not valid for the expected payload kind 'Entry'."))
		{
			Write-Host ("Changing status of order '{0}' [{1}] FAILED.{2}{3}" -f $order.Name, $order.Id, [Environment]::NewLine, ($order | Out-String));
		}
	}
}

#
# Copyright 2015 d-fens GmbH
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
