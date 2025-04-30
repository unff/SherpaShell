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