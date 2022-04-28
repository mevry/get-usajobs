$queries = 'config/queries.json'

try{

    if(-not (Test-Path $queries)){
        New-Item -Path $queries -Force | Out-Null
        Set-Content -ErrorAction Stop -Path $queries -Value @"
{
    "QueryTitle":"PowerShell Keyword",
    "Description": "PowerShell jobs. Grades 5-13",
    "Query":{
        "JobCategoryCode":2210,
        "Keyword":"PowerShell",
        "PayGradeLow": "05",
        "PayGradeHigh": "13"
    }
}
"@
    }

    #Load saved queries
    if(Test-Path $queries){
        $Global:SavedQueries = [ordered]@{}
        $queryObjects = Get-Content $queries | ConvertFrom-Json -Depth 10

        foreach($query in $queryObjects) {
            $SavedQueries.add($query.QueryTitle, $query.Query)
        }
    }

    #Load Intelligence Careers Current Job
    $response = Invoke-RestMethod https://apply.intelligencecareers.gov/job-listings/search
    $Global:IntelligenceCareersJobFamilies = $response | Group-Object -Property jobFamily | Select-Object -ExpandProperty Name
    if(-not $Global:IntelligenceCareersJobFamilies) {
        Write-Host -Message "No Intel Career job families found; Find-IntelligenceCareers may not work correctly."
    }

}
catch{
    $Error[0]
}