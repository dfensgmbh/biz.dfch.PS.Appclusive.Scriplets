$here = Split-Path -Parent $MyInvocation.MyCommand.Path

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
	
	# Set order status to 'Running'
	UpdateOrder -svc $svc -order $order -status 'Continue';
	
	# Load order based on job
	$order = $svc.Core.Orders.AddQueryOption('$filter', "Id eq " + $orderJob.ReferencedItemId) | Select;

	# Load VDI order item
	# DFTODO - Adjust query to load orderItems of type VDI ($product.Type -eq 'VDI')
	$vdiOrderItem = $svc.Core.LoadProperty($order, 'OrderItems') | Select;
	
	if($vdiOrderItem)
	{
		# Load product of orderItem
		$product = $svc.Core.LoadProperty($vdiOrderItem, 'Product') | Select;
		
		$result = ProcessVDIEntitlement -username $order.Requester;
		
		# Create inventory entry for VDI
		if($result -eq $true)
		{			
			CreateInventoryEntry -svc $svc -parentNode $tenantNode -product $product;
		}
		else 
		{
			UpdateOrder -svc $svc -order $order -status 'Cancel' -errorMsg $result;
			return;
		}
	}
	
	# DFTODO - Load non VDI orderItems
	$orderItems = $svc.Core.LoadProperty($order, 'OrderItems') | Select;
	foreach($orderItem in $orderItems)
	{
		# DFTODO - Implement handling of SW Package OrderItems
		# DFTODO - Be aware of time offset between deployment of VDI and SW package assignment
		# DFTODO - Set VDI node item as parent
		# DFTODO - Handle requester of Order (Impersonate creation?)
	}
	
	UpdateOrder -svc $svc -order $order -status 'Continue';
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

function UpdateOrder($svc, $order, $status, $errorMsg = '')
{
	try
	{
		$order.Status = $status;
		$order.Parameters = $errorMsg;
		$svc.Core.UpdateObject($order);
		$svc.Core.SaveChanges();
	}
	catch
	{
		# DFTODO - Handle exception correctly -> an exception is thrown in any case because of PATCH/PUT Order returns Job!
		# DFTODO - Handle exception, if status change already in progress (i.e. when trying to change to running status)
		# Write-Host ("Changing status of order '{0}' [{1}] FAILED.{2}{3}" -f $order.Name, $order.Id, [Environment]::NewLine, ($order | Out-String));
	}
}