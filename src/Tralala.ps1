function Add($p1, $p2)
{
	return $p1 + $p2;
}

function Div($p1, $p2)
{
	return $p1 / $p2;
}

function DoSomething($uri)
{
	$result = Invoke-Restmethod($uri);
	return $result;
}
