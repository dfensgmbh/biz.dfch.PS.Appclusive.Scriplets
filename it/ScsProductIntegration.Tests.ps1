
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "ScsProductIntegration.Tests" "ProductIntegration.Tests" {

	Mock Export-ModuleMember { return $null; }
	
	Context "ScsProductIntegrationTests" {
	
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-ApcServer;
		}
		
		It "AddCartItemAndPlaceOrder-Succeeds" -Test {
			
			$svc = Enter-Apc;
			$cartItem = New-Object biz.dfch.CS.Appclusive.Api.Core.CartItem;
			$cartItem.Quantity = 1;
			$cartItem.CatalogueItemId = 11;
			$cartItem.Name = 'Managed Red Hat Enterprise Linux 7';
			$cartItem.Description = 'Managed Red Hat Enterprise Linux 7';
			
			$cartItem.Parameters = '{"vm":{"id":"3294","name":"TestNiklaus8","CimiId":"http://cminv-lab3ch-1.mgmt.sccloudpoc.net:8080/inventory/cimi/2/machines/7e31ef0d-6fe7-45d2-a06a-0d66022a1a2d"},"username":"admin","password":"admin","managementLevel":"full","supportTime":"officeHours","maintenanceWindow":"weekend3OfMonth","autoApplyPatches":true,"emergencyPatches":true,"frozenZone":[{"dateTimeFrom":"2016-02-16T23:00:00.000Z","dateTimeTo":"2016-02-23T23:00:00.000Z"}],"customerAlarmingTargetList":"managedservices.cloud@swisscom.com"}';
			
			$svc.Core.AddToCartItems($cartItem);
			$svc.Core.SaveChanges();
			$svc.core.Carts

			$order = New-Object biz.dfch.CS.Appclusive.Api.Core.Order;
			$order.Name = "Managed Red Hat Enterprise Linux 7";
			$order.Description = "Managed Red Hat Enterprise Linux 7";
			$order.Parameters = @{NodeId = "1680"} | ConvertTo-Json -Compress;
			$svc.Core.AddToOrders($order);
			$svc.Core.SaveChanges();

			# $approvals = $svc.Core.Approvals | Select
			# $approval = $approvals[$approvals.Count - 1]
			# $params = @{Name = "Continue"; Parameters="my reason"}
			# Invoke-ApcEntityAction -InputObject $approval -EntityActionName "InvokeAction" -InputParameters $params;
		}
	}
}
