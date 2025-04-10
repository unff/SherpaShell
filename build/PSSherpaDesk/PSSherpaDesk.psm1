Function Get-SDAccount{
    Param(
        [parameter(ParameterSetName = 'ByKey')] [string]$Key,
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )

    $resource = 'accounts'
    If($PSCmdlet.ParameterSetName -eq 'ByKey'){
        $resource = "$resource/$key"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDAPIKey {
    [cmdletbinding(DefaultParameterSetName = 'EmailOnly')]
    Param(
        [Parameter(ParameterSetName = 'EmailOnly')] [string]$Email,
        [Parameter(ParameterSetName = 'Credential')] [pscredential]$Credential,
        [switch]$PassThru
    )

    If($PSCmdlet.ParameterSetName -eq 'EmailOnly'){
        $credential = Get-Credential -UserName $Email -Message 'Retrieving API key from Sherpa Desk'
    }

    $up = "$($credential.GetNetworkCredential().UserName)`:$($credential.GetNetworkCredential().Password)"
    $encodedUP = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$up"))

    $header = @{
        Authorization = "Basic $encodedUP"
        Accept = 'application/json'
    }
    $resp = Invoke-RestMethod -Method Get -Uri 'https://api.sherpadesk.com/login' -Headers $header
    $Script:AuthConfig = @{
        ApiKey = $resp.api_token
        WorkingOrganization = ''
        WorkingInstance = ''
    }
    If($PassThru.IsPresent){
        $resp.api_token
    }
}
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
Function Get-SDAuthConfig {
    Param(
        [switch]$Silent
    )
    If($AuthConfig){
        If(-not ($Silent.IsPresent)){
            $AuthConfig
        }
    }Else{
        $dir = Get-SDSavePath
        If(Test-Path $dir\credentials.json){
            $encryptedAuth = Get-Content $dir\credentials.json | ConvertFrom-Json
        }
        $script:AuthConfig = @{}
        ForEach($property in $encryptedAuth.psobject.Properties){
            $AuthConfig."$($property.name)" = [pscredential]::New('user',(ConvertTo-SecureString $property.value)).GetNetworkCredential().password
        }
        If(-not ($Silent.IsPresent)){
            $AuthConfig
        }
    }
}
Function Get-SDConfig{
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )

    # Validate the key parameter if provided
    $resource = 'config'
 
     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey

}
Function Get-SDInvoice{
    [cmdletbinding(DefaultParameterSetName = 'ByKey')]
    Param(
        [parameter(ParameterSetName = 'ByKey')] [string]$Key,
        [parameter(ParameterSetName = 'ByAccount')] [string]$Account,
        [parameter(ParameterSetName = 'ByContract')] [string]$Contract,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )

    # Validate the key parameter if provided
    $resource = 'invoices'
    If ($PSCmdlet.ParameterSetName -eq 'ByKey') {
        $resource = "$resource/$key"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByAccount') {
        $resource = "${$resource}?account=${$AccountKey}"
    } ElseIf ($PSCmdlet.ParameterSetName -eq 'ByContract') {
        $resource = "${$resource}?contract_id=${$ContractKey}"
    }

     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey

}
Function Get-SDMetadata {
    Param(
        [string]$ApiKey = $AuthConfig.ApiKey,
        [switch]$PassThru
    )
    
    $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("x:$ApiKey"))

    $header = @{
        Authorization = "Basic $encodedAuth"
        Accept = 'application/json'
    }

    $resp = Invoke-RestMethod -Uri 'https://api.sherpadesk.com/organizations/' -Method Get -Headers $header
    
    if ($resp.Count -gt 1) {
        Write-Host "Multiple organizations found. Please select one:"
        for ($i = 0; $i -lt $resp.Count; $i++) {
            Write-Host "$i - $($resp[$i].name)"
        }
        $selection = Read-Host "Enter the number corresponding to your choice"
        if ($selection -match '^\d+$' -and [int]$selection -lt $resp.Count) {
            $selectedOrg = $resp[$selection]
        } else {
            throw "Invalid selection. Please try again."
        }
    } else {
        $selectedOrg = $resp[0]
    }

    $Script:AuthConfig.WorkingOrganization = $selectedOrg.key
    $Script:AuthConfig.WorkingInstance = $selectedOrg.instances[0].key

    if ($PassThru.IsPresent) {
        $resp
    }
}
Function Get-SDProject {
    [cmdletbinding()]
    Param(
        [parameter(
            ParameterSetName = 'ByKey'
        )]
        [string]$Key,
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'projects'
    If($PSCmdlet.ParameterSetName -eq 'ByKey'){
        $resource = "$resource/$key"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDTaskTypes {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'task_types'

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDTechs {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'technicians'

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
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
Function Get-SDTime {
    [cmdletbinding()]
    Param(
        [string]$Account,
        [string]$Tech,
        [string]$Project,
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $arrParameters = @()
    If($AccountName){
        $arrParameters += "account=$AccountName"
    }
    If($Tech){
        $arrParameters += "tech=$Tech"
    }
    If($Project){
        $arrParameters += "project=$Project"
    }
    $strParameters = $arrParameters -join '&'
    
    Write-Verbose $strParameters

    If($strParameters){
        Invoke-SherpaDeskAPICall -Resource "time?$strParameters" -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
    }Else{
        Invoke-SherpaDeskAPICall -Resource time -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
    }
}
Function Get-SDUser {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'users'

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function New-SDTicket {
    [cmdletbinding(
        DefaultParameterSetName = 'ByParameter'
    )]
    Param(
        [Parameter(ParameterSetName = 'ByParameter')]
        [string]$Status,
        [Parameter(ParameterSetName = 'ByParameter')]
        [string]$Subject,
        [Parameter(ParameterSetName = 'ByParameter')]
        [string]$FirstPost,
        [Parameter(ParameterSetName = 'ByParameter')]
        [int]$Class,
        [Parameter(ParameterSetName = 'ByParameter')]
        [int]$Account,
        [Parameter(ParameterSetName = 'ByParameter')]
        [int]$Location,
        [Parameter(ParameterSetName = 'ByParameter')]
        [int]$User,
        [Parameter(ParameterSetName = 'ByParameter')]
        [int]$Tech,
        [Parameter(ParameterSetName = 'ByBody')]
        [hashtable]$Body,
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $NewTicketParams = @{
        Status    = 'status'
        Subject   = 'subject'
        FirstPost = 'initial_post'
        Class     = 'class_id'
        Account   = 'account_id'
        Location  = 'location_id'
        User      = 'user_id'
        Tech      = 'tech_id'
    }

    $resource = "tickets"
    
    If ($PSCmdlet.ParameterSetName -eq 'ByParameter') {
        $body = @{}
        ForEach ($param in $NewTicketParams.GetEnumerator()) {
            If ($PSBoundParameters.ContainsKey($param.key)) {
                $body["$($param.value)"] = $PSBoundParameters["$($param.key)"]
            }
        }
    }

    $jsonbody = $body | ConvertTo-Json

    Write-Verbose $jsonbody

    Invoke-SherpaDeskAPICall -Method Post -Resource $resource -Organization $Organization -Instance $Instance -ApiKey $ApiKey -Body $jsonbody
}
Function New-SDUser {
    Param(
        [Parameter(
            ParameterSetName = 'ByParameter',
            Mandatory = $true
        )]
        [string]$FirstName,
        [Parameter(
            ParameterSetName = 'ByParameter',
            Mandatory = $true
        )]
        [string]$LastName,
        [Parameter(
            ParameterSetName = 'ByParameter',
            Mandatory = $true
        )]
        [string]$Email,
        [Parameter(
            ParameterSetName = 'ByParameter',
            Mandatory = $true
        )]
        [int]$Account,
        [Parameter(
            ParameterSetName = 'ByParameter'
        )]
        [int]$Location,
        [Parameter(
            ParameterSetName = 'ByBody'
        )]
        [hashtable]$Body,
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $NewUserParams = @{
        FirstName = 'firstname'
        LastName = 'lastname'
        Email = 'email'
        Account = 'account'
        Location = 'location'
    }

    $resource = 'users'

    If($PSCmdlet.ParameterSetName -eq 'ByParameter'){
        $body = @{}
        ForEach($param in $NewUserParams.GetEnumerator()){
            If($PSBoundParameters.ContainsKey($param.key)){
                $body["$($param.value)"] = $PSBoundParameters["$($param.key)"]
            }
        }
    }

    $jsonbody = $body | ConvertTo-Json

    Write-Verbose $jsonbody

    Invoke-SherpaDeskAPICall -Method Post -Resource $resource -Organization $Organization -Instance $Instance -ApiKey $ApiKey -Body $jsonbody
}
Function Save-SDAuthConfig {
    [cmdletbinding(
        DefaultParameterSetName = 'FromAuthConfig'
    )]
    Param(
        [parameter(
            ParameterSetName = 'Passed'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Organization,
        [parameter(
            ParameterSetName = 'Passed'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Instance,
        [parameter(
            ParameterSetName = 'Passed'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ApiKey
    )
    $dir = Get-SDSavePath
    If(-not(Test-Path $dir -PathType Container)){
        New-Item $dir -ItemType Directory
    }
    If(-not(Test-Path $dir\credentials.json -PathType Leaf)){
        New-Item $dir\credentials.json -ItemType File
    }
    If($PSCmdlet.ParameterSetName -eq 'Passed'){
        $Script:AuthConfig = @{
            ApiKey = $ApiKey
            WorkingOrganization = $Organization
            WorkingInstance = $Instance
        }
    }
    $encryptedAuth = @{}
    ForEach($property in $AuthConfig.GetEnumerator()){
        $encryptedAuth."$($property.Name)" = (ConvertFrom-SecureString (ConvertTo-SecureString $property.Value -AsPlainText -Force))
    }
    $encryptedAuth | ConvertTo-Json | Set-Content $dir\credentials.json
}
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
Function Get-SDSavePath {
    Param (

    )
    If($PSVersionTable.PSVersion.Major -ge 6){
        # PS Core
        If($IsLinux){
            $saveDir = $env:HOME
        }ElseIf($IsWindows){
            $saveDir = $env:USERPROFILE
        }
    }Else{
        # Windows PS
        $saveDir = $env:USERPROFILE
    }
    "$saveDir\.pssherpadesk"
}
Function Invoke-SherpaDeskAPICall {
    Param(
        [string]$Resource,
        [ValidateSet('Get','Put','Post')]
        [string]$Method,
        [string]$Body,
        [string]$Organization,
        [string]$Instance,
        [string]$ApiKey
    )
    $baseUri = 'https://api.sherpadesk.com'

    $encodedAuth = [Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes("$Organization-$Instance`:$ApiKey"))

    $header = @{
        Authorization = "Basic $encodedAuth"
        Accept = 'application/json'
    }
    
    If($Method -eq 'Get') {
        # Start a timer to keep track of calls per second
        $timer = [Diagnostics.Stopwatch]::StartNew()
        # Get Page zero
        # $resp = Invoke-RestMethod -Method $Method -Uri "$baseUri/$Resource" -Headers $header
        $resp = Invoke-RestMethod -Method $Method -Uri "$baseUri/$Resource" -Headers $header -ContentType 'application/json' -Body $Body
        # Check if the response has fewer than 25 items, indicating no more pages
        If ($resp.Count -lt 25){
            $hasMoreResults = $false # If the response is less than 25 items, there are no more pages
        } else {
            $hasMoreResults = $true # If the response is 25 items, there are more pages to fetch
        }
        $page = 1   # Set page counter to 1 for the next page
        
        while ($hasMoreResults) {
            Write-Information "total seconds elapsed: $($timer.elapsed.totalseconds) retrieving page ${page}" -InformationAction Continue
            # Invoke the API call for the next page of results
            # The page number is passed as a query parameter to the API call
            $currentPageResults = Invoke-RestMethod -Method $Method -Uri "$baseUri/$resource/?page=$page" -Headers $header
            # Flatten the results by adding each object from the current page to $resp
            $currentPageResults | ForEach-Object { $resp += $_ }
        
            # Check if the current page has fewer than 25 objects, indicating no more pages
            if ($currentPageResults.Count -lt 25) {
                $hasMoreResults = $false
            } else {
                $page++ # Increment the page counter to fetch the next page
            }
        }
        Write-Information "finished retrieval. total seconds elapsed: $($timer.elapsed.totalseconds)" -InformationAction Continue
        $timer.Stop() # Stop the timer
        # $resp now contains a single array of objects from all pages
        return $resp

    }
    ElseIf(@('Post','Put','Delete') -contains $Method) {
        Invoke-RestMethod -Method $Method -Uri "$baseUri/$Resource" -Headers $header -ContentType 'application/json' -Body $Body
    }
}
