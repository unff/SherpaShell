<#
    $body = @{
    "is_bulk: false, // boolean
    "is_active: true, // boolean
    "is_force_dublicate: true, // boolean
    "checkout_id: 1, // integer
    "owner_id: 12, // integer
    "account_id: 13, // integer
    "serial_number: "11", // string (max 50 chars),
    "category_id: 111, // integer 
    "type_id: 112, // integer
    "make_id: 113, // integer
    "model_id: 114, // integer
    "unique1_value: "u111", // string (max 100 chars),
    "unique2_value: "u112", // string (max 100 chars),
    "unique3_value: "u113", // string (max 100 chars),
    "unique4_value: "u114", // string (max 100 chars),
    "unique5_value: "u115", // string (max 100 chars),
    "unique6_value: "u116", // string (max 100 chars),
    "unique7_value: "u117", // string (max 100 chars),
    "unique_motherboard: "m11", // string (max 100 chars),
    "unique_bios: "b11", // string (max 100 chars),
    "name: "name11", // string (max 50 chars),
    "description: "d11", // string (max 250 chars),
    "note: "my note", // string (max 500 chars),
    "location_id: 0 // integer,
    "status_id": 6 // integer, show only assets with status id=6
    "entered_date": "2017-06-20T13:12:01.3600000" //string, Represent date in iso format 
    "acquired_date": "2017-06-20T13:12:01.3600000" //string, Represent date in iso format 
    "po_number: "2345 n/a", // string,
    "paid_value: "4.80", // string,
    "funding_source: "test", // string 
}
#>

Function Set-SDAsset {
    [cmdletbinding(DefaultParameterSetName = 'ByParameter')]
    Param(
        [Parameter(ParameterSetName = 'ByParameter')] [string]$Status,
        [Parameter(ParameterSetName = 'ByBody')] [hashtable]$Body,

        [string]$key,
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = "assets/$key"
    
    If($PSCmdlet.ParameterSetName -eq 'ByParameter'){
        $body = @{}
        $body['status'] = $Status
    }

    $jsonbody = $body | ConvertTo-Json

    Write-Verbose $jsonbody
    # not ready yet
    #Invoke-SherpaDeskAPICall -Method Put -Resource $resource -Organization $Organization -Instance $Instance -ApiKey $ApiKey -Body $jsonbody
}