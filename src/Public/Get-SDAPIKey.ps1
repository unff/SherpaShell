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