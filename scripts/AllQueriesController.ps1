#Use this script to generate a report with a tab for each of your saved searches
#Ex: AllQueriesController.ps1 -ApiKey $Apikey

[cmdletbinding()]
param(
    [string]$Path = "$((Get-Date).ToString("yyyy-MM-dd"))_USAJOBSAllSearches.xlsx",
    [string]$ApiKey = $Global:ApiKey,
    [string[]]$ControlNumberFilter
)

foreach($key in $SavedQueries.Keys){
    $jobs = Find-Usajobs -ApiKey $ApiKey -SavedQuery $key -ControlNumberFilter $ControlNumberFilter | Sort-Object -Property 'LowPay' -Verbose

    Export-UsajobsReport -ReportObject $jobs -Name $key -Path $Path
}