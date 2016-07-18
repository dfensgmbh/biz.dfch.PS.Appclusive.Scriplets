Import-Module biz.dfch.PS.Appclusive.Client

$credentials = Get-Credential -UserName "w2012r2-t6-10\Administrator" -Message "Login To Lab3" #enter credentials to connect to lab3 (domain of lab3 = w2012r2-t6-10)
$labSvc = Enter-ApcServer -ServerBaseUri "http://172.19.115.33/appclusive" -Credential $credentials


Describe -Tags "??" "??" {

    Context "#CLOUDTCL-??" {

        It "nodes" -Test {
        #ARRANGE
        #get node
        $newNode = Get-ApcNode -Id 34239;
        #getJob
        Get-ApcJob | Where-Object {$_.RefId -eq $newNode.Id} | Should Not Be $null;
        $newNode.EntityKindId | Should Not Be $null;

        #ACT
        #$newJob = Get-ApcJob | Where-Object {$_.RefId -eq $newNode.Id & $_.Status -eq "Running"};

        #

        		}
	}
}