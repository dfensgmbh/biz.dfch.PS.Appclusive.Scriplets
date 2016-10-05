############################################################################################
# Script Name:     Copy-VmdkFiles.ps1
# Script Funktion: 
# Version:         1.0
# Datum:           05.07.2016
# Autor:           BUSINESS IT AG - K. Schwender (c) 2016
# Aenderungen:     - 
#                  
############################################################################################

$CfgFile = ".\Copy-VmdkFiles.ini"

############################################################################################
# Definition aller Standard Funktionen
############################################################################################

Function InitAndConnectVi {
#   Version 1.2
    if ( !(Get-PSSnapin -Name VMware.* -ErrorAction SilentlyContinue) ) {
        $ErrCtr = $error.count
        Add-PSSnapin -Name VMware.* -erroraction SilentlyContinue | out-null 
    } 
    CheckForError $ErrCtr
    LogWrite "INFO - Enter login for vCenter $vCenter ..."
    Connect $vCenter
}

Function Connect {
#   Version 1.0
    Param ([string]$Server)
    Try {
        Connect-VIServer -server $Server -ea 1 -WarningAction 0 | out-null
        LogWrite "INFO - Successfull connection to vCenter $Server ..."
    }
    Catch {
        $TErr = $_.Exception.innerexception.message
        LogWrite "ERROR - Failed to connect vCenter $Server, script will terminate!"
        LogWrite "ERROR - $TErr"
    CleanUp
    Exit
    }
}

Function LogWrite {
#   Version 1.0
    Param ([string]$logString)
    $iErrCtr = $error.count
    Add-Content $LogFile -Value ($(Get-Date -format "yyyy-MM-dd - HH:mm:ss --> ") + $logString)
    Write-Host $logString
    CheckForError $iErrCtr
}

Function CheckForError {
#   Version 1.0
    Param($ErrorCount)
    
    If ($error.count -gt $ErrorCount) {
        $LogError = $error[0]
        $ErrorCount = $error.count
        LogWrite $LogError
    }
}

Function GetScriptName {
#   Version 1.0
    $ScriptName = (Get-Variable MyInvocation -Scope 1).Value.mycommand.Definition
    Return, $ScriptName
}

Function GetSciptConfig {
#   Version 1.0
    $iErrCtr = $error.count
	$aCfg = Get-Content $CfgFile
    CheckForError $iErrCtr
    Return, $aCfg
}

Function GetCsv {
#   Version 1.0
    $iErrCtr = $error.count
	[Array]$aRules = Import-CSV $RuleFile -Delimiter $CsvDelimit
    CheckForError $iErrCtr
    Return, $aRules
}

Function ReadIni ($aInput, $sFind) {
#   Version 1.0
    $iErrCtr = $error.count
	$aOutput = (%{$aInput} | Where-Object {$_ -like '*'+$sFind+'*'}).split("=")[1]
    CheckForError $iErrCtr
    Return, $aOutput
}

Function CleanUp {
#   Version 1.0
    If ($defaultVIServers) {
        $tvCenters = foreach($defaultserver in $defaultVIServers) {write $defaultserver.name}
        Disconnect-VIServer -Server $defaultVIServers -Confirm:$false
        LogWrite $("INFO - Disconnected all vCenter(s) " + $tvCenters)
    }
    $ErrCtr = $error.count
    Remove-PSSnapin VMware.* -ErrorAction SilentlyContinue | out-null
    CheckForError $ErrCtr
    LogWrite "INFO - Removed all VMware PSSnapins ..."
    LogWrite "INFO - Script has ended normally!"
}

############################################################################################
# End of standard functions
############################################################################################

############################################################################################
# Start Main Programm
############################################################################################

$iErrCtr = $error.count
$aCfg = GetSciptConfig
CheckForError $iErrCtr
$vCenter = ReadIni $aCfg "vCenter"
$BackupFolder = ReadIni $aCfg "BackupFolder"
$MasterVMs = ReadIni $aCfg "MasterVMs"
$AppVolumesFolder = ReadIni $aCfg "AppVolumesFolder"
$LogFile = ReadIni $aCfg "LogFile"


LogWrite "********************************************************************************************"
InitAndConnectVi
$sScriptName = GetScriptName
LogWrite "INFO - Script $sScriptName started..."
LogWrite "INFO - Connected to vCenter: $global:defaultVIServer"

If ( $BackupFolder ) {
	LogWrite "INFO - Using Folder '$BackupFolder' as Backup Device."
	If ( $MasterVMs ) {
		ForEach ($VM in $MasterVMs.Split(",")) {
			$aVM = Get-VM -Name $VM
			If ( $aVM.PowerState -eq "PoweredOff" ) {
				$srcDs = Get-Datastore -VM $aVM
				$srcFolder = $aVM.ExtensionData.Config.Files.VmPathName.Split("] ,/")[2]
				LogWrite "INFO - Copy VM '$VM' from Datastore '$srcDs' to '$BackupFolder'."
				New-PSDrive -Location $srcDs -Name SourceDs -PSProvider VimDatastore -Root "\"
				Copy-DatastoreItem -Item SourceDs:\$srcFolder\* -Destination "$BackupFolder\$srcFolder\" -Force
				Remove-PSDrive -Name SourceDs
			} Else { LogWrite "WARNING - VM '$VM' will not be backed up because it's Powered-On." }
		} 
	} Else { LogWrite "INFO - No VMs to copy." } 
	If ( $AppVolumesFolder ) {
		$srcDs = Get-Datastore -Name $AppVolumesFolder.Split("\")[0]
		$srcFolder = $AppVolumesFolder.Split("\")[1]
		LogWrite "INFO - Copy VMDKs from Datastore '$srcDs\$srcFolder' to '$BackupFolder'."
		New-PSDrive -Location $srcDs -Name SourceDs -PSProvider VimDatastore -Root "\"
		Copy-DatastoreItem -Item SourceDs:\$srcFolder\* -Destination "$BackupFolder\$srcFolder\" -Force -Recurse
		Remove-PSDrive -Name SourceDs
	} Else { LogWrite "INFO - No VMDKs to copy." }
} Else { LogWrite "ERROR - No Backup Folder." }

CleanUp
