Function Get-SDAssetSearch{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [Parameter(ParameterSetName = 'ByParameter')] [string]$Text, # string (max 255 chars), search assets by any Unique field
        [Parameter(ParameterSetName = 'ByParameter')] [int]$AccountID, # string (max 255 chars), search assets by any field
        [Parameter(ParameterSetName = 'ByParameter')] [string]$ExcludeFields, # string (max 255 chars), use 'my' to show only my owned assets
        [Parameter(ParameterSetName = 'ByParameter')] [string]$Query, # integer, show assets checked out by user with id=11 
        [Parameter(ParameterSetName = 'ByParameter')] [int]$OriginalLimit, # integer, show assets owned by user with id=12
        [Parameter(ParameterSetName = 'ByParameter')] [int]$Limit, # integer, show assets in account with id=1
        [Parameter(ParameterSetName = 'ByParameter')] [string]$SortOrder, # boolean, show only active (true) or inactive (false) or all (undefined) assets
        [Parameter(ParameterSetName = 'ByParameter')] [string]$SortBy, # integer, show only assets with status id=6,
        [Parameter(ParameterSetName = 'ByParameter')] [int]$StartDate, # integer, show assets with categoryId=111 
        [Parameter(ParameterSetName = 'ByParameter')] [int]$EndDate, # integer
        [Parameter(ParameterSetName = 'ByBody')] [hashtable]$Body, # pre-defined body to send to the API.
        [Parameter(ParameterSetName = 'ByPage')] [int]$Page, # pre-defined body to send to the API.
        [parameter(ParameterSetName = 'All')] [switch]$All, # Get all assets. Value is ignored. This is the default if no other params are sent.

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $AssetParams = @{
        Text                = 'text'
        AccountId	        = 'account_id'
        ExcludeFields       = 'exclude_fields'
        Query	            = 'query'
        OriginalLimit       = 'original_limit'
        Limit	            = 'limit'
        Page	            = 'page'
        SortOrder	        = 'sort_order'
        SortBy	            = 'sort_by'
        StartDate	        = 'start_date'
        EndDate	            = 'end_date'
    }

    # Parse the parameters if provided.  The API docs lied, and none of the body parameters actually work.  You just get it all.
    $resource = 'assets/search'
    If ($PSCmdlet.ParameterSetName -eq 'ByParameter') {
        $Body = @{}
        ForEach ($param in $AssetParams.GetEnumerator()) {
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
            $Body = @{} # Empty body for all assets
        } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByPage') {
            $Body = @{}
            $resource = "${resource}?page=${Page}"
    }

    $jsonbody = $Body | ConvertTo-Json

     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey -Body $jsonbody
}