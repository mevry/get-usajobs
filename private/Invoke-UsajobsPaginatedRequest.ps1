function Invoke-UsajobsPaginatedRequest{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,
        [string]$Uri = 'https://data.usajobs.gov',
        [string]$Endpoint = 'api/search',
        [Parameter(Mandatory)]
        [hashtable]$Body,
        [string]$Method = 'Get',
        [int]$ResultsPerPage = 250,
        [int]$MaxResults = 250
    )

    #Add 0 for page count request
    $Body.add('ResultsPerPage', 0)

    $requestSplat = @{
        Method = $Method
        Headers = @{
            'Authorization-Key' = $ApiKey
        }
        Uri = "$Uri/$Endpoint"
        Body = $Body
    }

    #get page count
    $response = Invoke-RestMethod @requestSplat
    $resultCount = $response.SearchResult.SearchResultCountAll
    Write-Verbose -Message "Number of search results: $($resultCount)"

    $max = ($resultCount -lt $MaxResults) ? $resultCount : $MaxResults
    $pageCount = [Math]::Ceiling($max/$ResultsPerPage)

    $requestSplat.Body['ResultsPerPage'] = $ResultsPerPage
    for($i = 0; $i -lt $pageCount; $i++){
        $requestSplat.Body['Page'] = $i
        Write-Verbose -Message "Page: $i"
        $response = Invoke-RestMethod @requestSplat
        $response.SearchResult.SearchResultItems.MatchedObjectDescriptor
    }
    
}