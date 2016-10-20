# $arrangedDisk01WithoutIndexNames = New-Object biz.dfch.Appclusive.Products.Infrastructure.V001.Disk;
# $arrangedDisk01WithoutIndexNames.Name = "Disk01 Name";
# $arrangedDisk01WithoutIndexNames.Description = "Disk01 Description";
# $arrangedDisk01WithoutIndexNames.Size = 42;

# $arrangedDisk01ParametersWithoutIndexNames = [biz.dfch.CS.Appclusive.Public.Converters.EntityBagConverter]::Convert($arrangedDisk01WithoutIndexNames);
# $json = $arrangedDisk01ParametersWithoutIndexNames.SerializeObject();

# $dic = New-Object biz.dfch.CS.Appclusive.Public.DictionaryParameters($json);
# [biz.dfch.CS.Appclusive.Public.Converters.EntityBagConverter]::Convert
# # $baseDisk = [biz.dfch.CS.Appclusive.Public.Converters.EntityBagConverter]::Convert[biz.dfch.Appclusive.Products.Infrastructure.V001.Disk]($dic);
# [Type[]] $types = @([biz.dfch.CS.Appclusive.Public.DictionaryParameters])
# $mi = [biz.dfch.CS.Appclusive.Public.Converters.EntityBagConverter].GetMethod("Convert", $types);
# $gmi = $mi.MakeGenericMethod([biz.dfch.Appclusive.Products.Infrastructure.V001.Disk]);
# $baseDisk = $gmi.Invoke([biz.dfch.CS.Appclusive.Public.Converters.EntityBagConverter], $dic)

# $serialisedBaseDisk = $baseDisk.SerializeObject();
# # $disk01 = [biz.dfch.CS.Appclusive.Public.BaseDto]::DeserializeObject[biz.dfch.Appclusive.Products.Infrastructure.V001.Disk01]($serialisedBaseDisk);
# [Type[]] $types = @([string])
# $mi = [biz.dfch.CS.Appclusive.Public.BaseDto].GetMethod("DeserializeObject", $types);
# $gmi = $mi.MakeGenericMethod([biz.dfch.Appclusive.Products.Infrastructure.V001.Disk]);
# $disk01 = $gmi.Invoke([biz.dfch.CS.Appclusive.Public.BaseDto], $serialisedBaseDisk)
# $disk01
# // Assert
# $disk01Parameters = EntityBagConverter.Convert($disk01);

function Invoke-GenericMethod {
[CmdletBinding(
	SupportsShouldProcess = $true
	,
	ConfirmImpact = 'Low'
	,
	HelpURI = 'http://dfch.biz/biz/dfch/PS/System/Utilities/Invoke-GenericMethod/'
	,
	DefaultParameterSetName = 'statement'
)]
PARAM
(
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'statement')]
	[string] $statement
	,
	[Parameter(Mandatory = $true, Position = 0, ParameterSetName = 'parameters')]
	[Object] $InputObject
	,
	[Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'parameters')]
	[Type[]] $TypeParameters
	,
	[Parameter(Mandatory = $false, Position = 2, ParameterSetName = 'parameters')]
	[Object[]] $Arguments
)

	$pattern = '^(\[(?<Type>[^\]]+)\](?<InstanceOrStatic>::)|(?<Instance>\$[^\.]+)(?<InstanceOrStatic>\.))(?<MethodName>[^\[]+)\[(?<GenericTypes>[^\]]+)\]\((?<Parameters>[^\)]+)\)$';
	$isValidStatement = $statement -match $pattern;
	Contract-Assert $isValidStatement
	$MethodParameters = $Matches;
	
	$isStatic = $false;
	if($MethodParameters.InstanceOrStatic -eq '::')
	{
		$isStatic = $true;
	
		$typeInfo = Invoke-Expression "[$($MethodParameters.Type)]";
		$memberDefinition = $typeInfo |gm -Type Method -Static |? Name -eq $MethodParameters.MethodName
	}
	elseif($MethodParameters.InstanceOrStatic -eq '.')
	{
		$isStatic = $false;
	
		$instanceValue = Get-Variable $Matches.Instance.TrimStart('$') -ValueOnly;
		$typeInfo = $instanceValue.GetType();
		$memberDefinition = $instanceValue |gm -Type Method |? Name -eq $MethodParameters.MethodName
	}
	else
	{
		$isValidStatement = $false
		Contract-Assert $isValidStatement
	}
	Contract-Assert (!!$memberDefinition) "Specified method name not found"
	
	$parameterValues = New-Object 'System.Collections.Generic.List`1[object]';
	$parameterNames = New-Object System.Text.StringBuilder;
	foreach($name in $MethodParameters.Parameters.Split(',')) 
	{
		if($name.Contains('['))
		{
			$isValidParamterDefinition = $name.Trim() -match '^(?<type>\[[^\]]+\])[^\$]+(?<name>\$\w+)$'
			Contract-Assert $isValidParamterDefinition

			$value = Get-Variable $Matches.name.TrimStart('$') -ValueOnly;
			
			$typeName = $Matches.type;
		}
		else
		{
			Contract-Assert $name.StartsWith('$')
			
			$value = Get-Variable $name.TrimStart('$') -ValueOnly;
			
			$typeName = "[{0}]" -f $value.GetType().FullName;
		}
		$parameterValues.Add($value);
		$null = Invoke-Expression $typeName;
		$null = $parameterNames.Append($typeName);
		$null = $parameterNames.Append(',');
	}
	[Type[]] $parameterTypes = Invoke-Expression "($($parameterNames.ToString().TrimEnd(',')))";
	
	$mi = $typeInfo.GetMethod($MethodParameters.MethodName, $parameterTypes);
	
	Contract-Assert (!!$mi) "MethodName not found"

	$typeNames = New-Object System.Text.StringBuilder;
	foreach($name in $MethodParameters.GenericTypes.Split(',')) 
	{
		$typeName = "[{0}]" -f $name;
		$null = Invoke-Expression $typeName;
		$null = $typeNames.Append($typeName);
		$null = $typeNames.Append(',');
	}
	[Type[]] $genericTypes = Invoke-Expression "($($typeNames.ToString().TrimEnd(',')))";
	$gmi = $mi.MakeGenericMethod($genericTypes);
	Contract-Assert (!!$gmi) "MakeGenericMethod FAILED"

	if($isStatic)
	{
		$OutputParameter = $gmi.Invoke($typeInfo, $parameterValues)
	}
	else
	{
		$OutputParameter = $gmi.Invoke($Matches.Instance, $parameterValues)
	}
    return $OutputParameter;
}

# Invoke-GenericMethod '[biz.dfch.CS.Appclusive.Public.BaseDto]::DeserializeObject[biz.dfch.Appclusive.Products.Infrastructure.V001.Disk01]($serialisedBaseDisk)';
