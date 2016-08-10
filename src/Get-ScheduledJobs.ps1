PS > $svc = Enter-ApcServer
PS > $q = ("Nodes eq {0}" -f [biz.dfch.CS.Appclusive.Public.Constants+EntityKindId]::ScheduledJob.value__)
PS > $schjobs = $svc.Core.ScheduledJobs | Select
PS > $schjobs.Count
2
PS > $schjobs[0]

Crontab                      : * * * * *
Action                       : ExternalWorkflow
ScheduledJobParameters       : {"Id":"com.example.cms.patching.configuration.InvokePatchRun","Parameters":"{\"nodeId\":\"1842\"}"}
ParallelInvocation           : DoNotStartNewInstance
MaximumRuntimeMinutes        : 60
AutoDeleteIfNotScheduledDays : 10
MaxRestartAttempts           : 0
MaxRestartWaitTimeMinutes    : 1
HistoryDepth                 : 0
ManagementCredential         :
EntityId                     :
Parameters                   : {}
EntityKindId                 : 35
ParentId                     : 1842
Id                           : 1862
Tid                          : ad8f50df-2a5d-4ea5-9fcc-05882f16a9fe
Name                         : SAGEX Test Scheduler
Description                  : SAGEX Test Scheduler
CreatedById                  : 1
ModifiedById                 : 1
Created                      : 13.05.2016 11:30:18 +02:00
Modified                     : 15.06.2016 15:15:56 +02:00
RowVersion                   : {0, 0, 0, 0...}
Parent                       :
EntityKind                   :
Children                     : {}
IncomingAssocs               : {}
OutgoingAssocs               : {}
Tenant                       :
CreatedBy                    :
ModifiedBy                   :

PS > $schjobs[0].ScheduledJobParameters
{"Id":"com.example.cms.patching.configuration.InvokePatchRun","Parameters":"{\"nodeId\":\"1842\"}"}
PS > $schjobs[0].ScheduledJobParameters | ConvertFrom-Json

Id                                                     Parameters
--                                                     ----------
com.example.cms.patching.configuration.InvokePatchRun {"nodeId":"1842"}

PS > $scheduledJobParameters = $schjobs[0].ScheduledJobParameters | ConvertFrom-Json
PS > $scheduledJobParameters

Id                                                     Parameters
--                                                     ----------
com.example.cms.patching.configuration.InvokePatchRun {"nodeId":"1842"}

PS > $workflowParameters = $scheduledJobParameters.Parameters | ConvertFrom-Json
PS > $workflowParameters

nodeId
------
1842

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
