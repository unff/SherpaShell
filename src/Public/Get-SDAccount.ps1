Function Get-SDAccount{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [parameter(Mandatory = $true, ParameterSetName = 'ByParameter')] [int]$AccountID,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$Statistics,
        [parameter(ParameterSetName = 'ByParameter')] [string]$Note,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$AssetInfo,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$LocationInfo,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$FileInfo,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$ProjectInfo,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$UserInfo,
        [parameter(ParameterSetName = 'ByBody')] [hashtable]$Body,
        [parameter(ParameterSetName = 'All')] [switch]$All,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $accountParams = @{
        AccountID = "account_id"
        Statistics = "is_with_statistics"
        Note = "note"
        AssetInfo = "is_assets_info"
        LocationInfo = "is_locations_info"
        FileInfo = "is_files_info"
        ProjectInfo = "is_projects_info"
        UserInfo = "is_users_info"
    }
    
    $resource = 'accounts'
    If ($PSCmdlet.ParameterSetName -eq 'ByParameter') {
        $resource = "$resource/$AccountID"
        $Body = @{}
        ForEach ($param in $accountParams.GetEnumerator()) {
            If ($PSBoundParameters.ContainsKey($param.key)) {
                If ($($PSBoundParameters["$($param.key)"]).IsPresent) {
                    $Body["$($param.value)"] = $PSBoundParameters["$($param.key)"].IsPresent
                } Else {
                    $Body["$($param.value)"] = $PSBoundParameters["$($param.key)"]
                }
            }
        }
        } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByBody') {
            $Body = $Body
        } ElseIf ($PSCmdlet.ParameterSetName -eq 'All') {
            $Body = @{} # Empty body for all accounts
        } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByPage') {
            $Body = @{}
            $resource = "${resource}?page=${Page}"
    }

    $jsonbody = $Body | ConvertTo-Json

     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey -Body $jsonbody
}