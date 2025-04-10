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