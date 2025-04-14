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