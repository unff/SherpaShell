<#
    $body = @{
    "search": "", // string (max 255 chars), search assets by any field
    "filter": "my", // string (max 255 chars), use "my" to show only my owned assets
    "user_id": 11, // integer, show assets checked out by user with id=11 
    "owner_id": 12, // integer, show assets owned by user with id=12
    "account_id": 1, // integer, show assets in account with id=1
    "location_id": 2, // integer, show assets in location with id=2 and all child locations
    "is_active": true // boolean, show only active (true) or inactive (false) or all (undefined) assets
    "status": 6 // integer, show only assets with status id=6,
    "category_id": 111, // integer, show assets with category_id=111 
    "type_id": 112, // integer
    "make_id": 113, // integer
    "model_id": 114, // integer,
    "is_with_custom_fields": false// boolean, show custom_fields (true) or no (false) or all assets 
}
#>

Function Get-SDAsset{
    [cmdletbinding()]
    Param(
        [parameter(ParameterSetName = 'ByKey')] [string]$Key,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )

    # Validate the key parameter if provided
    $resource = 'assets'
    If($PSCmdlet.ParameterSetName -eq 'ByKey'){
        $resource = "$resource/$key"
    }
     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}