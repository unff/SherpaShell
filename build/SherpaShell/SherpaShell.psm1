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
Function Get-SDAccountStatistics {
    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $true, ParameterSetName = 'ByAccount')] [string]$Account,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'accounts/statistics'
    If($PSCmdlet.ParameterSetName -eq 'ByAccount'){
        $resource = "$resource/$Account"
    } 

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDActivity {
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [parameter(ParameterSetName = 'ByUserID')] [string]$UserID,
        [parameter(ParameterSetName = 'All')] [switch]$All, # Get all activity. Value is ignored. This is the default if no other params are sent.


        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'activity'
    If($PSCmdlet.ParameterSetName -eq 'ByUserID'){
        $resource = "${resource}?user=${UserID}"
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
        $Credential = Get-Credential -UserName $Email -Message 'Retrieving API key from Sherpa Desk'
    }

    $up = "$($Credential.GetNetworkCredential().UserName)`:$($Credential.GetNetworkCredential().Password)"
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
Function Get-SDArticle {
    [cmdletbinding()]
    Param(
        [parameter(ParameterSetName = 'BySearch')] [string]$Search,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'article'
    If($PSCmdlet.ParameterSetName -eq 'BySearch'){
        $resource = "${resource}?search=${key}"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
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
        [Parameter(ParameterSetName = 'ByPage')] [int]$Page, # pre-defined body to send to the API.
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

    # Parse the parameters if provided.  The API docs lied, and none of the body parameters actually work.  You just get it all.
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

     Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDAssetCategory {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'asset_categories'

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDAssetCustomField {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'customfields'

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDAssetMakes {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'asset_makes'

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDAssetModels {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'asset_models'

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
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
Function Get-SDAssetStatuses {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'asset_statuses'

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
Function Get-SDAssetTypes {
    [cmdletbinding()]
    Param(
        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'asset_types'

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
Function Get-SDClass {
    [cmdletbinding(DefaultParameterSetName = 'All')]
    Param(
        [parameter(ParameterSetName = 'ByClassID')] [string]$ClassID,
        [parameter(ParameterSetName = 'All')] [switch]$All, # Get all activity. Value is ignored. This is the default if no other params are sent.


        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'classes'
    If($PSCmdlet.ParameterSetName -eq 'ByClassID'){
        $resource = "${resource}/${UserID}"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
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

    $response = Invoke-RestMethod -Uri 'https://api.sherpadesk.com/organizations/' -Method Get -Headers $header
    
    if ($response.Count -gt 1) {
        Write-Host "Multiple organizations found. Please select one:"
        for ($i = 0; $i -lt $response.Count; $i++) {
            Write-Host "$i - $($response[$i].name)"
        }
        $selection = Read-Host "Enter the number corresponding to your choice"
        if ($selection -match '^\d+$' -and [int]$selection -lt $response.Count) {
            $selectedOrg = $response[$selection]
        } else {
            throw "Invalid selection. Please try again."
        }
    } else {
        $selectedOrg = $response[0]
    }

    $Script:AuthConfig.WorkingOrganization = $selectedOrg.key
    $Script:AuthConfig.WorkingInstance = $selectedOrg.instances[0].key

    if ($PassThru.IsPresent) {
        $response
    }
}
Function Get-SDProfile {
    [cmdletbinding()]
    Param(
        [parameter(ParameterSetName = 'ByID')] [string]$ID,

        [string]$Organization = $authConfig.WorkingOrganization,
        [string]$Instance = $authConfig.WorkingInstance,
        [string]$ApiKey = $authConfig.ApiKey
    )
    $resource = 'profile'
    If($PSCmdlet.ParameterSetName -eq 'ByID'){
        $resource = "$resource/$key"
    }

    Invoke-SherpaDeskAPICall -Resource $resource -Method Get -Organization $Organization -Instance $Instance -ApiKey $ApiKey
}
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
        [Parameter(ParameterSetName = 'ByParameter')] [string]$Status,
        [Parameter(ParameterSetName = 'ByParameter')] [string]$Subject,
        [Parameter(ParameterSetName = 'ByParameter')] [string]$FirstPost,
        [Parameter(ParameterSetName = 'ByParameter')] [int]$Class,
        [Parameter(ParameterSetName = 'ByParameter')] [int]$Account,
        [Parameter(ParameterSetName = 'ByParameter')] [int]$Location,
        [Parameter(ParameterSetName = 'ByParameter')] [int]$User,
        [Parameter(ParameterSetName = 'ByParameter')] [int]$Tech,
        [Parameter(ParameterSetName = 'ByBody')] [hashtable]$Body,
        
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
        # Start a Timer to keep track of calls per second
        $Timer = [Diagnostics.Stopwatch]::StartNew()
        # Get Page zero
        $response = Invoke-RestMethod -Method $Method -Uri "$baseUri/$Resource" -Headers $header -ContentType 'application/json' -Body $Body
        # Check if a single page was requested, or the response has fewer than 25 items, indicating no more pages
        If ($Resource.Contains('?page=') -Or $response.Count -lt 25){
            $hasMoreResults = $false # If the response is less than 25 items, there are no more pages
        } else {
            $hasMoreResults = $true # If the response is 25 items, there are more pages to fetch
        }
        $page = 1   # Set page counter to 1 for the next page
        
        while ($hasMoreResults) {
            Write-Information "total seconds elapsed: $($Timer.elapsed.totalseconds) retrieving page ${page}" -InformationAction Continue
            # Invoke the API call for the next page of results
            # The page number is passed as a query parameter to the API call
            $currentPageResults = Invoke-RestMethod -Method $Method -Uri "$baseUri/$resource/?page=$page" -Headers $header -Body $Body
            # Flatten the results by adding each object from the current page to $response
            $currentPageResults | ForEach-Object { $response += $_ }
        
            # Check if the current page has fewer than 25 objects, indicating no more pages
            if ($currentPageResults.Count -lt 25) {
                $hasMoreResults = $false
            } else {
                $page++ # Increment the page counter to fetch the next page
            }
        }
        Write-Information "finished retrieval. total seconds elapsed: $($Timer.elapsed.totalseconds)" -InformationAction Continue
        $Timer.Stop() # Stop the Timer
        # $response now contains a single array of objects from all pages
        return $response

    }
    ElseIf(@('Post','Put','Delete') -contains $Method) {
        Invoke-RestMethod -Method $Method -Uri "$baseUri/$Resource" -Headers $header -ContentType 'application/json' -Body $Body
    }
}
