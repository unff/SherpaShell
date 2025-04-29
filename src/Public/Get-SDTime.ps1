Function Get-SDTime {
    [cmdletbinding()]
    Param(
        [switch]$Recent,
        [switch]$UnlinkedFreshBooks,
        [switch]$LinkedFreshBooks,
        [switch]$Invoiced,
        [switch]$Uninvoiced,
        [switch]$UnlinkedQuickBooks,
        [switch]$LinkedQuickBooks,
        [switch]$Hidden,
        [switch]$DoNotInvoice,
        [string]$Account,
        [string]$Tech,
        [string]$Project,
        [string]$TicketTimeID,
        [string]$ProjectTimeID,
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