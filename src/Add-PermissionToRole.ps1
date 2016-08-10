PARAM
(
	[hashtable] $svc
	,
	[string] $RoleName
	,
	[string] $PermissionName
)
Contract-Assert (!!$svc)
Contract-Assert (!!$RoleName)
Contract-Assert (!!$PermissionName)

# searches for the *START* of the given permission name
$q = "startswith(Name, '{0}')" -f $PermissionName;
$permissions = $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select;
Contract-Assert (!!$permissions)

# searches for the role name, unless you are UberAdmin you will only retrieve the role inside your tenant
$q = "Name eq '{0}'" -f $RoleName;
$roles = $svc.Core.Roles.AddQueryOption('$filter', $q).AddQueryOption('$expand', "Permissions") | Select;
Contract-Assert (!!$roles)

foreach($role in $roles)
{
	foreach($permission in $permissions) 
	{ 
		$svc.Core.AddLink($role, 'Permissions', $permission); 
		$svc.Core.SaveChanges(); 
	}
}

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
