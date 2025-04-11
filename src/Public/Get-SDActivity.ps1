Function Get-SDActivity {
    [cmdletbinding()]
    Param(
        [parameter(ParameterSetName = 'ByUserID')] [string]$UserID,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'activity'
    If($PSCmdlet.ParameterSetName -eq 'ByUserID'){
        $resource = "${resource}?user=${key}"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}