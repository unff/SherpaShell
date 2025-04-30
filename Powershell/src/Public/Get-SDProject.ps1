Function Get-SDProject {
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [parameter(ParameterSetName = 'ByAccount')] [string]$AccountID,
        [parameter(ParameterSetName = 'ByTech')] [string]$TechID,
        [parameter(ParameterSetName = 'HasStatistics')] [switch]$HasStats,
        [parameter(ParameterSetName = 'ByStatusID')] [string]$StatusID,
        [parameter(ParameterSetName = 'All')] [switch]$All,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'projects'
    If($PSCmdlet.ParameterSetName -eq 'ByAccount'){
        $resource = "${resource}?account=${AccountID}"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByTech') {
        $resource = "${resource}?tech=${TechID}"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'HasStatistics') {
        $resource = "${resource}?is_with_statistics=true"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByStatusID') {
        $resource = "${resource}?active_status=${StatusID}"
    } 

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}