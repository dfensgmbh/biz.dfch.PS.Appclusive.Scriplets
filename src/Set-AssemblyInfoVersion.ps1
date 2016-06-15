# requires biz.dfch.PS.System.Utilities, biz.dfch.PS.System.Logging
function Set-AssemblyInfoVersion {
	[CmdletBinding(
		SupportsShouldProcess = $true
		,
		ConfirmImpact = 'Low'
		,
		HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Scriplets/Set-AssemblyVersion/'
	)]
	PARAM
	(
		[ValidateScript( { Test-Path -Path $_; } )]
		[Parameter(Mandatory = $true, Position = 0)]
		$InputObject
		,
		[Parameter(Mandatory = $true, Position = 1)]
		[Version] $Version
		,
		[Parameter(Mandatory = $false)]
		[switch] $KeepRevision = $true
	)
	
	trap { Log-Exception $_; break; }
	
	$OutputParameter = $null;
	
	$pattern = '(?ms)^(\[assembly:\ AssemblyVersion\()(\")(\d+\.\d+\.\d+\.[\d+|\*])(\")(\)\])';
	
	$assemblyInfoFile = Get-Item $InputObject;
	Contract-Assert (!!$assemblyInfoFile)
	
	$assemblyInfoContent = Get-Content -Raw $assemblyInfoFile -Encoding Default;
	Contract-Assert (!!$assemblyInfoContent)
	
	# Write-Host $assemblyInfoContent;
	$isAssemblyVersionDeclarationFound = $assemblyInfoContent -match $pattern;
	Contract-Assert ($isAssemblyVersionDeclarationFound)
	
	$currentVersionString = $Matches[3];
	if($currentVersionString.EndsWith('*') -And $KeepRevision)
	{
		$newVersionString = '{0}.{1}.{2}.*' -f $Version.Major, $Version.Minor, $Version.Build;
	}
	else
	{
		$newVersionString = $Version.ToString();
	}

	$replacement = '$1"{0}"$5' -f $newVersionString;
	Write-Host $currentVersion;

	$newContent = [regex]::Replace($assemblyInfoContent, $pattern, $replacement, [System.Text.RegularExpressions.RegexOptions]::Multiline);
	
	$message = "Replace '{0}' with '{1}'" -f $currentVersionString, $newVersionString;
	if(!$PSCmdlet.ShouldProcess($message))
	{
		return $OutputParameter;
	}
	
	$OutputParameter = Set-Content -Path $InputObject -Value $newContent -Encoding Default;
	return $OutputParameter;
}
