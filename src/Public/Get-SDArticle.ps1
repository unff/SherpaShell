Function Get-SDArticle {
    [cmdletbinding()]
    Param(
        [parameter(ParameterSetName = 'BySearch')] [string]$Search,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'article'
    If($PSCmdlet.ParameterSetName -eq 'BySearch'){
        $resource = "${resource}?search=${key}"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}