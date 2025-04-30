Function Get-SDAccountStatistics {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true, ParameterSetName = 'ByAccount')] [string]$Account,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'accounts/statistics'
    If($PSCmdlet.ParameterSetName -eq 'ByAccount'){
        $resource = "$resource/$Account"
    } 

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}