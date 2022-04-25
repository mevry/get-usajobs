function Get-PaginationCount{
    param(
        [int]$RecordCount,
        [int]$MaxPerRequest
    )

    $mod = $RecordCount % $MaxPerRequest
    $requestCount = ($RecordCount - $mod) / $MaxPerRequest
    $mod ? $requestCount + 1 : $requestCount
}