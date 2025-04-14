Function Get-SDActivity {
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [parameter(ParameterSetName = 'ByUserID')] [string]$UserID,
        [parameter(ParameterSetName = 'All')] [switch]$All, # Get all activity. Value is ignored. This is the default if no other params are sent.


        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'activity'
    If($PSCmdlet.ParameterSetName -eq 'ByUserID'){
        $resource = "${resource}?user=${UserID}"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}