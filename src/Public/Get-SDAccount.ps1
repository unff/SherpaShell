Function Get-SDAccount{
    Param(
        [parameter(ParameterSetName = 'ByParameter')] [int]$AccountID,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$HasStats,
        [parameter(ParameterSetName = 'ByParameter')] [string]$Note,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$AssetInfo,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$LocationInfo,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$FileInfo,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$ProjectInfo,
        [parameter(ParameterSetName = 'ByParameter')] [switch]$UserInfo,
        [parameter(ParameterSetName = 'All')] [switch]$All,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $accountParams = @{
        AccountID = "account_id"
        HasStats = "is_with_statistics"
        Note = "note"
        AssetInfo = "is_assets_info"
        LocationInfo = "is_locations_info"
        FileInfo = "is_files_info"
        ProjectInfo = "is_projects_info"
        UserInfo = "is_users_info"
    }
    
    $resource = 'accounts'
    If($PSCmdlet.ParameterSetName -eq 'MyAccoun'){
        $resource = "$resource/$Key"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}