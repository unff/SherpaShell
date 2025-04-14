Function Get-SDClass {
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [parameter(ParameterSetName = 'ByClassID')] [string]$ClassID,
        [parameter(ParameterSetName = 'All')] [switch]$All, # Get all activity. Value is ignored. This is the default if no other params are sent.


        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'classes'
    If($PSCmdlet.ParameterSetName -eq 'ByClassID'){
        $resource = "${resource}/${UserID}"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}