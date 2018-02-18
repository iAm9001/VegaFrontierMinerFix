# Specifies a path to one or more locations. Wildcards are permitted.
Param(
[Parameter(Mandatory=$false,
           
           ParameterSetName="VegaParams",
           ValueFromPipeline=$false,
           ValueFromPipelineByPropertyName=$false,
           HelpMessage="Sets the script to intiate DDU removal")]
[ValidateNotNullOrEmpty()]
[switch]
$ParameterName)



