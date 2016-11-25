#Requires -Modules biz.dfch.PS.Appclusive.Client

# Test-SchemaGenerator.ps1

<#
 #
 # PS > # The following versions are required:
 # PS > Get-ApcVersion

Name                           Value
----                           -----
biz.dfch.PS.Appclusive.Client  4.8.0.20160830
biz.dfch.CS.Appclusive.Api     4.10.0.13393
biz.dfch.CS.Appclusive.Public  3.18.0.14009
BaseUri                        3.18.0.8265

 #
 #>

$svc = $biz_dfch_PS_Appclusive_Client.Services;
# use an Id gt 4096 for a dynamically defined entity kind
$entityKindId = 4835;
$body = @{}
$body.Request = [biz.dfch.CS.Appclusive.Public.Constants+Metadata]::ACTION_SCS_ANGULAR_SCHEMA_FORM_TRANSITION;
$body.Action = [biz.dfch.CS.Appclusive.Public.Constants]::INITIAL_CONDITION;
$svc.Core.InvokeEntityActionWithSingleResult("EntityKinds", $entityKindId, "Metadata", [string], $body);

# make sure 'Metadata' action exists
[xml] $edmx = $svc.Core.GetMetadata();
$metadataActions = ($edmx.Edmx.DataServices.Schema |? Namespace -eq 'Default').EntityContainer.FunctionImport |? Name -eq 'Metadata';

foreach($metadataAction in $metadataActions) 
{ 
	$bindingParameter = $metadataAction.Parameter |? Name -eq 'bindingParameter'; 
	if($bindingParameter.Type.EndsWith('EntityKind')) 
	{ 
		break; 
	} 
}
Contract-Assert (!!$metadataAction)
