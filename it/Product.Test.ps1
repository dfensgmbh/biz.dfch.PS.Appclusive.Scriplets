
$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")

function Stop-Pester($message = "EMERGENCY: Script cannot continue.")
{
	$msg = $message;
	$e = New-CustomErrorRecord -msg $msg -cat OperationStopped -o $msg;
	$PSCmdlet.ThrowTerminatingError($e);
}

Describe -Tags "Node.Tests" "Node.Tests" {

	Mock Export-ModuleMember { return $null; }

	. "$here\$sut"
	
	# DFTODO - naming
	Context "ManagementCredential.Tests" {
		
		BeforeEach {
			$moduleName = 'biz.dfch.PS.Appclusive.Client';
			Remove-Module $moduleName -ErrorAction:SilentlyContinue;
			Import-Module $moduleName;
			$svc = Enter-AppclusiveServer;
		}
		
		It "Node-AddAndDeleteNewNode" -Test {
		
		}
		
	}
	
}