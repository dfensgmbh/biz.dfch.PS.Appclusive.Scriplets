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

$q = "startswith(Name, '{0}')" -f $PermissionName;
$permissions = $svc.Core.Permissions.AddQueryOption('$filter', $q) | Select;
Contract-Assert (!!permissions)

$q = "Name eq '{0}'" -f $RoleName;
$roles = $svc.Core.Roles.AddQueryOption('$filter', $q).AddQueryOption('$expand', "Permissions") | Select;
Contract-Assert (!!roles)

foreach($role in $roles)
{
	foreach($permission in $permissions) 
	{ 
		$svc.Core.AddLink($role, 'Permissions', $permission); 
		$svc.Core.SaveChanges(); 
	}
}
