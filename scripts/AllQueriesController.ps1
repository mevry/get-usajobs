#Use this script to generate a report with a tab for each of your saved searches or combine multiple queries into one worksheet
#Ex: AllQueriesController.ps1 -ApiKey $Apikey

[cmdletbinding()]
param(
    [string]$Path = "$((Get-Date).ToString("yyyy-MM-dd"))_USAJOBSAllSearches.xlsx",
    [string]$ApiKey = $Global:ApiKey,
    [string[]]$ControlNumberFilter,
    [int]$PostedDaysAgo,
    [switch]$CombineResults
)

$reqSplat = @{
    ApiKey = $ApiKey
}
if($ControlNumberFilter){ $reqSplat['ControlNumberFilter'] = $ControlNumberFilter }
if($PostedDaysAgo){ $reqSplat['PostedDaysAgo'] = $PostedDaysAgo }

$combinedResults = @()

$combinedResults
foreach($key in $SavedQueries.Keys){
    $jobs = Find-Usajobs @reqSplat -SavedQuery $key -RemoveMultipleLocations | Sort-Object -Property 'LowPay'

    if($CombineResults){
        $combinedResults += $jobs
    }
    else{
        Export-UsajobsReport -ReportObject $jobs -Name $key -Path $Path
    }
}

if($CombineResults){
    $combinedResults = $combinedResults | Sort-Object -Property 'ControlNumber' -Unique

    Export-UsajobsReport -ReportObject $combinedResults -Name 'Combined Queries' -Path $Path
}