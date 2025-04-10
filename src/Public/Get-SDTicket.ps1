Function Get-SDTicket{
    [cmdletbinding(DefaultParameterSetName = 'ByKey')]
    Param(
        [parameter(ParameterSetName = 'ByKey')] [string]$Key,
        [parameter(ParameterSetName = 'ByPage')] [int]$Page,
        [parameter(ParameterSetName = 'ByStatus')] [string]$Status,
        [parameter(ParameterSetName = 'BySearch')] [string]$Search,
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )

    # Validate the key parameter if provided
    $resource = 'tickets'
    If($PSCmdlet.ParameterSetName -eq 'ByKey'){
        $resource = "$resource/$key"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByPage') {
        $resource = "${resource}?page=${Page}"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByStatus') {
        $resource = "${resource}?status=${Status}"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'BySearch') {
        $resource = "${resource}?search=${Search}"
    }

     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey

}