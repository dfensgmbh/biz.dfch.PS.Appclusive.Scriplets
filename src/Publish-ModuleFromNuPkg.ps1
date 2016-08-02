PARAM
(
	$Nupkg = 'biz.dfch.PS.Appclusive.Client.4.4.1.nupkg'
	,
	[string] $NuGetApiKey = "tralala"
)

copy $Nupkg $ENV:TEMP
Push-Location $ENV:TEMP
$zip = '{0}.zip' -f $Nupkg
Rename-Item $Nupkg $zip
Expand-Archive $zip
Push-Location $Nupkg
[xml] $nuspecxml = Get-Content -Raw (Get-ChildItem *.nuspec -File | Select -First 1)

Push-Location tools
$psd1 = (Get-ChildItem *.psd1 -File | Select -First 1).FullName

$module = Get-Module $psd1 -ListAvailable;
$module | Publish-Module -IconUri $nuspecxml.package.metadata.iconUrl -LicenseUri $nuspecxml.package.metadata.licenseUrl -ReleaseNotes $nuspecxml.package.metadata.releaseNotes -Tags $nuspecxml.package.metadata.tags -RequiredVersion $module.Version -NuGetApiKey $nugetApiKey -Confirm:$false;

