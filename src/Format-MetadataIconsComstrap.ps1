$domains = Invoke-RestMethod http://data.iana.org/TLD/tlds-alpha-by-domain.txt
$items = $domains.Split([System.Environment]::NewLine);

$output = New-Object System.Text.StringBuilder;
$c = 1;
while($c -lt $items.Count)
{ 
	$line = New-Object System.Text.StringBuilder;
	do
	{
		$item = $items[$c]; 
		if(!$item) 
		{ 
			$c++;
			continue;
		}
	
		$null = $line.Append('"');
		$null = $line.Append($item);
		$null = $line.Append('"');
		$null = $line.Append(',');
		$c++;
	}
	while(80 -gt $line.Length -and $c -lt $items.Count);
	$null = $output.AppendLine($line.ToString());
}
$output.ToString();


$itemsXml = Invoke-RestMethod https://comstrap-cdn.scapp.io/fonts/pictograms.svg
$items = $itemsXml.svg.defs.font.glyph.'glyph-name' | Sort | Get-Unique
$output = ""
foreach($item in $items) { $output = $output + '"' + $item + '",' }
$output
