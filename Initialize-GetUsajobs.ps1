$queries = 'data/queries.json'

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

}
catch{
    $Error[0]
}