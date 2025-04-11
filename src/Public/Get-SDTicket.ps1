Function Get-SDTicket{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [parameter(ParameterSetName = 'ByKey')] [string]$Key,
        [parameter(ParameterSetName = 'ByPage')] [int]$Page,
        [parameter(ParameterSetName = 'ByStatus')] [string]$Status,
        [parameter(ParameterSetName = 'ByStatus')] [string]$Role,
        [parameter(ParameterSetName = 'ByDateRange')] [string]$StartDate,
        [parameter(ParameterSetName = 'ByDateRange')] [string]$EndDate,
        [parameter(ParameterSetName = 'BySearch')] [string]$Search,
        [parameter(ParameterSetName = 'All')] [switch]$All, # Get all tickets. Value is ignored. This is the default if no other params are sent.

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )

    # TODO: Validate the parameters if provided
    $resource = 'tickets'
    If($PSCmdlet.ParameterSetName -eq 'ByKey'){
        $resource = "$resource/$key"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByPage') {
        $resource = "${resource}?page=${Page}"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByStatus') {
        $resource = "${resource}?status=${Status}"
        If ($Role) {
            $resource = "${resource}&role=${Role}"
        }
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByDateRange') {
        If ($StartDate -And $EndDate) {
            $resource = "${resource}?start_date=${StartDate}&end_date=${EndDate}"
        } ElseIf ($StartDate) {
            $resource = "${resource}?start_date=${StartDate}"
        } ElseIf ($EndDate) {
            $resource = "${resource}?end_date=${EndDate}"
        }
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'BySearch') {
        $resource = "${resource}?search=${Search}"
    }

     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey

}