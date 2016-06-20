$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Appclusive.Products.Metadata" "Appclusive.Products.Metadata" {
	. "$here\$sut"

	Context "" {
		
		BeforeEach {
			# N/A
		}
		
		It "Warmup" -Test {
			1 | Should Be 1;
		}
		
		It "Get-Metadata" -Test {
			$svc = Enter-ApcServer;
			
			$parameters = @{};
			$parameters.Request = 'EntCloudPortalUIDefinition';
			$parameters.Action = 'Continue';
			
			$metadata = $svc.Core.InvokeEntityActionWithSingleResult('Products', 1, 'Metadata', [string], $parameters);
			$error[0].Exception.InnerException.InnerException;
			
		}
	}
}