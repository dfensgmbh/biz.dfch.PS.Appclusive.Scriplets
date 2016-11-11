#Requires -Modules biz.dfch.PS.Appclusive.Client
[CmdletBinding(
    ConfirmImpact = 'Medium'
	,
	SupportsShouldProcess = $true
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/Appclusive/Client/New-Role/'
	,
	DefaultParameterSetName = 'list'
)]
PARAM
(
	[Parameter(Mandatory = $true, Position = 0)]
	[string] $Name
	,
	[Parameter(Mandatory = $false)]
	[string] $Description
	,
	[Parameter(Mandatory = $false, Position = 1)]
	[string[]] $PermissionNames
	,
	[Guid] $TenantId
)

$fn = "New-Role";

$svc = Enter-Apc;
$null = Set-ApcSessionTenant -Id $TenantId -svc $svc;

$q = "Name eq '{0}'" -f $Name;
$role = $svc.Core.Roles.AddQueryOption('$filter', $q).AddQueryOption('$top', 1) | Select;
Contract-Assert (!$role) "Role already exists. Aborting ..."

$role = [biz.dfch.CS.Appclusive.Api.Core.Role]::new();
$role.Name = $Name;
$role.Description = $Description;
$role.RoleType = [biz.dfch.CS.Appclusive.Public.Security.RoleTypeEnum]::Default;
$svc.Core.AddToRoles($role);
$null = $svc.Core.SaveChanges();

$message = "Role '{0}'. Permissions '{1}'" -f $Name, [string]::Join([System.Environment]::NewLine, $PermissionNames);

if(!$PSCmdlet.ShouldProcess($message))
{
	return;
}

foreach($permissionName in ($permissionNames | Select -Unique))
{
	$q = "Name eq '{0}'" -f $permissionName;
	$permission = $svc.Core.Permissions.AddQueryOption('$filter', $q).AddQueryOption('$top', 1) | Select;
	if($null -eq $permission) 
	{
		Log-Error $fn "Permission not found";
		continue;
	}
	
	$svc.Core.AddLink($role, 'Permissions', $permission);
	$null = $svc.Core.SaveChanges();
}
