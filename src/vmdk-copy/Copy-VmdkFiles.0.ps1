[CmdletBinding(
    SupportsShouldProcess = $false
	,
    ConfirmImpact = 'High'
)]
PARAM
(
	# Specifies the configuration file name
	[ValidateScript( { Test-Path -Path $_; } )]
	[Parameter(Mandatory = $false, Position = 0)]
	[string] $ConfigurationFileName = (Join-Path -Path $PSScriptRoot -ChildPath $MyInvocation.MyCommand.Name.Replace('.ps1', '.xml'))
)

# see below for BEGIN / PROCESS / END 

function Enter-vCenter {

PARAM
(
	# Specifies the vCenter server to connect to
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Server
	#
	# we should also have some credentials passed to the method
	# in order to login with a different user
)

	[string] $fn = $MyInvocation.MyCommand.Name;

	# load snapins if not already loaded
	$snapins = Get-PSSnapin -Registered -Name VMWare.*;
	$snapins | Add-PSSnapin -ErrorAction:SilentlyContinue;

	# check for the main snapin to be loaded
	Contract-Assert (!!(Get-PSSnapin -Name VMware.VimAutomation.Core)) "'VMware.VimAutomation.Core' snapin could not be loaded"

	# login to vCenter
    Log-Debug $fn ("Logging in to '{0}' ..." -f $Server);
    $result = Connect-VIServer $Server -WarningAction 0;
    Log-Info $fn ("Logging in to '{0}' SUCCEEDED. Connected to '{1}'." -f $Server, $global:defaultVIServer);
	
	return $result;
}

function Exit-vCenter {

PARAM
(
	# Specifies the vCenter server to connect to
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Server
)

	[string] $fn = $MyInvocation.MyCommand.Name;

	try
	{
		Log-Debug $fn ("Diconnecting from '{0}' ..." -f $Server);
		Disconnect-VIServer -Server $Server -Confirm:$false;
		Log-Info $fn ("Diconnecting from '{0}' COMPLETED." -f $Server);
	}
	catch
	{
		Log-Error $fn ("Diconnecting from '{0}' FAILED." -f $Server);
	}
	
	# trying to unload snapins
	# Note: why? if it is a scheduled task the process will be terminated 
	# and the snapin unloaded anyway 
    $null = Remove-PSSnapin VMware.* -ErrorAction:SilentlyContinue;
	$snapins = Get-PSSnapin -Name VMWare* -ErrorAction:SilentlyContinue;
	if($snapins)
	{
		Log-Error $fn ("Error unloading snapins.");
	}
}

function ProcessMasterVms {

PARAM
(
	$MasterVms
)

	[string] $fn = $MyInvocation.MyCommand.Name;

	if (!$MasterVms)
	{
		Log-Warn $fn "INFO - No VMs to copy." 
		return;
	} 

	foreach ($MasterVm in $MasterVms) 
	{
		$virtualMachine = Get-VM -Name $MasterVm;
		
		# only copy powered off machines
		if (!$virtualMachine.PowerState -eq "PoweredOff") 
		{
			Log-Warn $fn "WARNING - VM '$MasterVm' will not be backed up because it's Powered-On." 
			continue;
		} 

		# get the target drive
		$srcDs = Get-Datastore -VM $virtualMachine
		$srcFolder = $virtualMachine.ExtensionData.Config.Files.VmPathName.Split("] ,/")[2]
		Log-Info $fn ("INFO - Copy VM '{0}' from Datastore '{1}' to '{2}'." -f $MasterVm, $srcDs, $ConfigurationFileName.BackupFolder)
		$null = New-PSDrive -Location $srcDs -Name 'SourceDs' -PSProvider VimDatastore -Root "\"
		
		# make sure target drive exists
		$psDrive = Get-PSDrive -Name 'SourceDs';
		Contract-Assert (!!$psDrive);
		
		# switch to target drive
		Push-Location SourceDs:\
		
		# prepare file paths
		$sourePath = Join-Path -Path SourceDs: -ChildPath $srcFolder;
		$destinationPath = Join-Path -Path $ConfigurationFileName.BackupFolder -ChildPath $srcFolder
		
		# iterate over each source file
		$sourceFileItems = Get-ChildItem -Path SourceDs:\
		foreach($sourceFileItem in $sourceFileItems)
		{
			try
			{
				CopyFile -sourceFileItem $sourceFileItem -destinationPath $destinationPath;
			}
			catch
			{
				Log-Exception $_;
			}
		}
		
		Pop-Location
		Remove-PSDrive -Name SourceDs -ErrorAction:SilentlyContinue;
	} 
}

function CopyFile {
PARAM
(
	$SourceFileItem
	,
	$DestinationPath
)

	[string] $fn = $MyInvocation.MyCommand.Name;

	# check if file exists in destination and copy if not exists
	$destinationPathAndFileName = (Join-Path -Path $DestinationPath -ChildPath $SourceFileItem);
	$fileExistsInDestination = Test-Path $destinationPathAndFileName;
	if(!$fileExistsInDestination)
	{
		Copy-DatastoreItem -Item $SourceFileItem.FullName -Destination $destinationPathAndFileName -Force
		return;
	}
	
	$destinationFileItem = Get-Item $destinationPathAndFileName
	Contract-Assert (!!$destinationFileItem)
	
	# if file already exists in destination compare last write time
	$timespanDifference = $SourceFileItem.LastWriteTimeUtc - $destinationFileItem.LastWriteTimeUtc;
	# copy only if difference is more than configured value
	if($timespanDifference.TotalMinutes -gt $ConfigurationFileName.TimespanDifferenceMinutes)
	{
		Copy-DatastoreItem -Item $SourceFileItem.FullName -Destination $destinationPathAndFileName -Force
		return;
	}
}

function ProcessAppVolumesFolder {

PARAM
(
	$AppVolumesFolder
)

	[string] $fn = $MyInvocation.MyCommand.Name;

	if(!$AppVolumesFolder)
	{
		Log-Warn $fn "INFO - No VMDKs to copy." 
		return;
	} 

	$srcDs = Get-Datastore -Name $AppVolumesFolder.Split("\")[0]
	$srcFolder = $AppVolumesFolder.Split("\")[1]
	Log-Info $fn ("INFO - Copy VMDKs from Datastore '{0}\{1}' to '{2}'." -f $srcDs, $srcFolder, $ConfigurationFileName.BackupFolder)
	New-PSDrive -Location $srcDs -Name SourceDs -PSProvider VimDatastore -Root "\"
	
	# switch to target drive
	Push-Location SourceDs:\

	# prepare file paths
	$sourePath = Join-Path -Path SourceDs: -ChildPath $srcFolder;
	$destinationPath = Join-Path -Path $ConfigurationFileName.BackupFolder -ChildPath $srcFolder
	
	# iterate over each source file
	$sourceFileItems = Get-ChildItem -Path SourceDs:\
	foreach($sourceFileItem in $sourceFileItems)
	{
		try
		{
			CopyFile -sourceFileItem $sourceFileItem -destinationPath $destinationPath;
		}
		catch
		{
			Log-Exception $_;
		}
	}
		
	# Copy-DatastoreItem -Item SourceDs:\$srcFolder\* -Destination "$BackupFolder\$srcFolder\" -Force -Recurse
	
	Pop-Location
	Remove-PSDrive -Name SourceDs
}

trap { Log-Exception $_; break; }

[string] $fn = $MyInvocation.MyCommand.Name;
Log-Info $fn "START"

# load the configuration file
Contract-Assert ((Test-Path $ConfigurationFileName)) "No configuration file found"
$configuration = Import-CliXml $ConfigurationFileName;

# assert its parameters
Contract-Assert (!!$configuration.BackupFolder)  "No backup folder specified"
Contract-Assert ((Test-Path -Path $configuration.BackupFolder)) "No backup folder found"

try
{
	Log-Info  "INFO - Using Folder '$BackupFolder' as Backup Device."

	$vi = Enter-vCenter -Server $configuration.vCenter;
	Contract-Assert (!!$vi);
	
	return;
	
	ProcessMasterVms -MasterVMs $configuration.MasterVms;
	
	ProcessAppVolumesFolder -AppVolumesFolder $configuration.AppVolumesFolder;

}
finally
{
	Exit-vCenter
}

Log-Info $fn "END"
