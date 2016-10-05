#Requires -Modules biz.dfch.PS.Appclusive.Client
#Requires -Modules biz.dfch.PS.System.Logging

PARAM
(
	[Parameter(Mandatory = $false)]
	[string] $PathToNotifications = 'C:\data\ServiceBusQueues\NOTIFY-WFE\PICKUP'
)

trap { Log-Exception $_; break; }

[string] $fn = $MyInvocation.MyCommand.Name;

# Init script variables
Contract-Requires (!!$PathToNotifications);
$pathToProcessedNotifications =  "{0}\PROCESSED" -f (Split-Path $PathToNotifications );
$pathToFailedNotifications =  "{0}\FAILED" -f (Split-Path $PathToNotifications );

# Load notifications from PICKUP directory
$notifications = Get-ChildItem $PathToNotifications;

foreach($notification in $notifications)
{
	$svc = Enter-Apc;

	# Process notifications
	Log-Debug $fn ("Processing notification '{0}'..." -f $notification.Name);
	$notificationContent = Import-Clixml -Path $notification.FullName;
	
	$msg = ConvertFrom-Json -InputObject $notificationContent.Message;
	
	if ($msg.Header.Type -ne "JobTransitionEvent") 
	{
		continue;
	}
	
	try
	{
		$query = "Id eq {0}" -f $msg.body.Id;
		$job = $svc.Core.Jobs.AddQueryOption('$filter', $query) | Select;
		Contract-Assert (!!$job);
		
		switch ($job.EntityKindId)
		{
			1
			{
				# Node job notification handling
				$Message = "State transition succeeded";
				$jobResult = @{Version = "1"; Message = $Message; Succeeded = $true};
				$null = Invoke-ApcEntityAction -InputObject $job -EntityActionName "JobResult" -InputParameters $jobResult;
			}
			default 
			{
				$warnMsg = "No explicitly defined handling defined for notification '{0}'" -f $notification.Name;
				Log-Warn $fn ($warnMsg);
			}
		}
		
		$successMsg = "Processing notification '{0}' SUCCEEDED" -f $notification.Name;
		Log-Info $fn ($successMsg);
		$notificationContent.LastResult = $successMsg;
		$notificationContent | Export-Clixml -Path $notification.FullName;
		
		# Move file to processed directory
		Log-Debug $fn ("Move file '{0}' to '{1}' ..." -f $notification.Name, $pathToProcessedNotifications);
		Move-Item -path $notification.FullName -destination $pathToProcessedNotifications;
	}
	catch
	{
		$errorMsg = $error[0].Exception;
		if($error[0].Exception.InnerException) 
		{
			$errorMsg = $error[0].Exception.InnerException;
		}
		$notificationContent.LastResult = "Error occured while processing notification - {0} [{1}]" -f $errorMsg, [System.DateTimeOffset]::Now.ToString('yyyy-MM-ddTHH:mm:ss.fffzzz');
		$notificationContent | Export-Clixml -Path $notification.FullName;
		
		Log-Debug $fn ("Move file '{0}' to '{1}' ..." -f $notification.Name, $pathToFailedNotifications);
		Move-Item -path $notification.FullName -destination $pathToFailedNotifications;
		
		Exit 1;
	}
}

Exit 0;

#
# Copyright 2016 d-fens GmbH
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
