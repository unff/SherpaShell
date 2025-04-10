<#
    $body = @{
    "status" : "closed",
    "note_text" : "some note"
    "level_id" : 3,
    "project_id": 66,
    "class_id" : 3
    "priority_id" : 3
    "account_id" : 3,
    "account_location_id" : 0,
    "is_transfer_user_to_account": "false",
    "is_waiting_on_response" : "true",
    "creation_category_id" : 0,
    "creation_category_name" : "",
    "customfields_xml" : "<root><field id="4724"><caption>www.sherpadesk.com</caption><value>Yes</value></field></root>",
    "default_contract_id" : 0,
    "default_contract_name: "( Not Set )",
    "location_id" : 0,
    "submission_category" : "( Not Set )",
    "tech_id" : 496558,
    "user_id" : 496558,
    "board_list_id" : "77b764099b854452bf2e470825442677" // leave empty to not update, or "0" to reset
}
#>

Function Set-SDTicket {
    [cmdletbinding(DefaultParameterSetName = 'ByParameter')]
    Param(
        [Parameter(ParameterSetName = 'ByParameter')]
        [string]$Status,
        [Parameter(ParameterSetName = 'ByBody')]
        [hashtable]$Body,
        [string]$key,
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = "tickets/$key"
    
    If($PSCmdlet.ParameterSetName -eq 'ByParameter'){
        $body = @{}
        $body['status'] = $Status
    }

    $jsonbody = $body | ConvertTo-Json

    Write-Verbose $jsonbody

    Invoke-SherpaDeskAPICall -Method Put -Resource $resource -Organization $Organization -Instance $Instance -ApiKey $ApiKey -Body $jsonbody
}