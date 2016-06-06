#Requires -Modules @{ ModuleName = "biz.dfch.PS.Appclusive.Client"; ModuleVersion = "2.8.1" }, @{ ModuleName = "PSScheduledJob"; ModuleVersion = "1.0.0.0" }

PARAM
(
	[Parameter(Mandatory = $false, Position = 0)]
	[Uri] $ServerBaseUri = 'http://appclusive/Appclusive/'
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[string] $Username = 'Administrator'
	,
	[Parameter(Mandatory = $false, Position = 2)]
	[string] $Password = 'P@ssw0rd'
)

# trap { Log-Exception $_; break; }

$biz_dfch_PS_Appclusive_Client.ServerBaseUri = $ServerBaseUri
$cred = New-Object System.Net.NetworkCredential($Username, $Password)
$svc = Enter-Apc -Credential $cred

Test-ApcStatus -Authenticate
$serverDateTimeOffset = Get-ApcTime -As DateTimeOffset
Contract-Assert (!!$serverDateTimeOffset)
Contract-Assert (60 -ge ($serverDateTimeOffset - [System.DateTimeOffset]::Now).Seconds)

$ScheduledJobs = $svc.Core.ScheduledJobs | select
Contract-Assert (!!$ScheduledJobs)
Contract-Assert (0 -lt $ScheduledJobs.Count)
$ScheduledJobs.Count

$ScheduledJob = $ScheduledJobs[-1]
Contract-Assert (!!$ScheduledJob)
$ScheduledJob
Contract-Assert ($ScheduledJob.Action -eq [biz.dfch.CS.Appclusive.Public.OdataServices.Core.JobActionEnum]::InternalWorkflow)

$scheduledJobParameters = [biz.dfch.CS.Appclusive.Public.BaseDto]::DeserializeObject($ScheduledJob.ScheduledJobParameters, [biz.dfch.CS.Appclusive.Public.OdataServices.Core.JobActionInternalWorkflow]);
Contract-Assert ($scheduledJobParameters.IsValid())
$scheduledJobParameters

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
