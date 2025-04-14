Function Get-SDAsset{
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [Parameter(ParameterSetName = 'ByParameter')] [string]$Search, # string (max 255 chars), search assets by any field
        [Parameter(ParameterSetName = 'ByParameter')] [string]$Filter, # string (max 255 chars), use 'my' to show only my owned assets
        [Parameter(ParameterSetName = 'ByParameter')] [int]$UserId, # integer, show assets checked out by user with id=11 
        [Parameter(ParameterSetName = 'ByParameter')] [int]$OwnerId, # integer, show assets owned by user with id=12
        [Parameter(ParameterSetName = 'ByParameter')] [int]$AccountId, # integer, show assets in account with id=1
        [Parameter(ParameterSetName = 'ByParameter')] [int]$LocationId, # integer, show assets in location with id=2 and all child locations
        [Parameter(ParameterSetName = 'ByParameter')] [switch]$IsActive, # boolean, show only active (true) or inactive (false) or all (undefined) assets
        [Parameter(ParameterSetName = 'ByParameter')] [int]$Status, # integer, show only assets with status id=6,
        [Parameter(ParameterSetName = 'ByParameter')] [int]$CategoryId, # integer, show assets with categoryId=111 
        [Parameter(ParameterSetName = 'ByParameter')] [int]$TypeId, # integer
        [Parameter(ParameterSetName = 'ByParameter')] [int]$MakeId, # integer
        [Parameter(ParameterSetName = 'ByParameter')] [int]$ModelId, # integer,
        [Parameter(ParameterSetName = 'ByParameter')] [switch]$ShowCustomFields, # boolean, show custom_fields (true) or no (false) or all assets 
        [Parameter(ParameterSetName = 'ByBody')] [hashtable]$Body, # pre-defined body to send to the API.
        [Parameter(ParameterSetName = 'ByPage')] [int]$Page, # page number to retrieve. Default is 0
        [parameter(ParameterSetName = 'All')] [switch]$All, # Get all assets. Value is ignored. This is the default if no other params are sent.

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $AssetParams = @{
        Search	    = 'search'
        Filter	    = 'filter'
        UserId	    = 'user_id'
        OwnerId	    = 'owner_id'
        AccountId	= 'account_id'
        LocationId	= 'location_id'
        IsActive	= 'is_active'
        Status	    = 'status'
        CategoryId	= 'category_id'
        TypeId	    = 'type_id'
        MakeId	    = 'make_id'
        ModelId	    = 'model_id'
        ShowCustomFields = 'is_with_custom_fields'
    }

    # Parse the parameters if provided.  The API docs lie, and the API does not support all of the parameters listed in the docs.
    $resource = 'assets'

    
    If ($PSCmdlet.ParameterSetName -eq 'ByParameter') {
        $resource += "?"
        ForEach ($param in $AssetParams.GetEnumerator()) { 
            If ($PSBoundParameters.ContainsKey($param.key)) {
                If ($($PSBoundParameters["$($param.key)"]).IsPresent) {
                    $resource += "$($param.value)=$($PSBoundParameters["$($param.key)"].IsPresent)&"
                } Else {
                    $resource += "$($param.value)=$($PSBoundParameters["$($param.key)"])&"
                }
            }
        }
        $resource = $resource.TrimEnd('&') # Remove the last ampersand in the string
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByBody') {
        $Body = $Body
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'All') {
        $Body = @{} # Empty body for all assets
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByPage') {
        $Body = @{}
        $resource = "${resource}?page=${Page}"
    }

    $jsonbody = $Body | ConvertTo-Json -Depth 10 # Convert the body to JSON format

     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey -Body $jsonbody
}