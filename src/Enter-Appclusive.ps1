function Enter-Appclusive {
PARAM
(
	[ValidateSet('LAB3', 'INT11')]
	$Environment = 'LAB3'
	,
	$Username = 'Administrator'
)

	$here = (Get-Item $profile).Directory;
	Push-Location $here;

	try
	{
		$credentialFileName = 'Cred-Appclusive-{0}-{1}.xml' -f $Username, $Environment;
		$credentialPathAndFileName = Join-Path -Path $PWD -ChildPath $credentialFileName;
		
		$fileExists = Test-Path $credentialPathAndFileName;
		if(!$fileExists)
		{
			Write-Error ("Credential file '{0}' does not exist. Cannot login." -f $credentialPathAndFileName);
			return;
		}

		$cred = Import-CliXml $credentialPathAndFileName;

		Remove-Module biz.dfch.PS.Appclusive.Client -Force -ErrorAction:SilentlyContinue;
		Import-Module biz.dfch.PS.Appclusive.Client;

		switch($Environment)
		{
			"LAB3"
			{
				$serverBaseUri = 'http://lab3.appclusive.example.com/Appclusive/';
			}
			"INT11"
			{
				$serverBaseUri = 'http://int11.appclusive.example.com/Appclusive/';
			}
			default
			{
				Write-Error ("Unknown environment '{0}'" -f $Environment);
				return;
			}
		}

		$biz_dfch_PS_Appclusive_Client.ServerBaseUri = $serverBaseUri;
		$svc = Enter-ApcServer -Credential $cred;
		$result = Test-ApcStatus -Authenticate;
		Contract-Assert (!!$result)

		$versions = Get-ApcVersion -All;
		$title = '{0}: {1} - {2} - Server {3} - Client {4}' -f $Environment, $cred.Username, $serverBaseUri, $versions.BaseUri.ToString(), $versions.'biz.dfch.PS.Appclusive.Client'.ToString(); 
		$host.UI.RawUI.WindowTitle = $title;

		return $svc;
	}
	catch
	{
		Write-Error ("Credential file '{0}' does not exist. Cannot login." -f $credentialPathAndFileName);
	}
	finally
	{
		Pop-Location;
	}
}
