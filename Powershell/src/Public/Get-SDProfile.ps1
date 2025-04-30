Function Get-SDProfile {
    [cmdletbinding()]
    Param(
        [parameter(ParameterSetName = 'ByID')] [string]$ID,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'profile'
    If($PSCmdlet.ParameterSetName -eq 'ByID'){
        $resource = "$resource/$key"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}