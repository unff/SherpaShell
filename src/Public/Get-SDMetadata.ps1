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