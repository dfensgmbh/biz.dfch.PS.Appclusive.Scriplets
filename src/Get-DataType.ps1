function Get-DataType {
PARAM
(
	# Data Type to search for. Input is treated as regular expression
	# unlesse otherwise specified in '-Literal'
	[Parameter(Mandatory = $false, Position = 0)]
	[string] $InputObject = '.*'
	,
	# perform case sensitive search if specified
	[Parameter(Mandatory = $false)]
	[Alias('case')]
	[switch] $CaseSensitive = $false
	,
	# perform literal search (i.e. not regex) if specified
	[Parameter(Mandatory = $false)]
	[Alias('noregex')]
	[switch] $Literal = $false
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
			
			$definedTypeFullName = $definedType.FullName;
			if($Literal)
			{
				if($CaseSensitive)
				{
					if($definedTypeFullName -cne $InputObject)
					{
						continue;
					}
				}
				else
				{
					if($definedTypeFullName -ine $InputObject)
					{
						continue;
					}
				}
			}
			else
			{
				if($CaseSensitive)
				{
					if($definedTypeFullName -cnotmatch $InputObject)
					{
						continue;
					}
				}
				else
				{
					if($definedTypeFullName -inotmatch $InputObject)
					{
						continue;
					}
				}
			}
			$null = $result.Add($definedTypeFullName);
		}
	}
	
	return $result | Sort;
}

#
# Copyright 2012-2016 d-fens GmbH
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
