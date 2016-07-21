function Get-DataType {
PARAM
(
	[string] $InputObject
)
	$result = New-Object System.Collections.ArrayList;
	
	$assemblies = [System.AppDomain]::CurrentDomain.GetAssemblies();
	foreach($assembly in $assemblies)
	{
		foreach($definedType in $assembly.DefinedTypes)
		{
			if(!(($definedType.IsPublic -eq $true -Or $definedType.IsNestedPublic -eq $true) -And $definedType.IsInterface -ne $true))
			{
				continue;
			}
			
			if($definedType -notmatch $InputObject)
			{
				continue;
			}
			
			$null = $result.Add($definedType.FullName);
		}
	}
	
	return $result | Sort;
}

# Get-DataType Health

