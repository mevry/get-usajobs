$queries = 'config/queries.json'

try{

    if(-not (Test-Path $queries)){
        New-Item -Path $queries -Force | Out-Null
        Set-Content -ErrorAction Stop -Path $queries -Value @"
[
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
]
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
    Write-Verbose -Message "Retrieving IntelligenceCareers.gov job families."
    $response = Invoke-RestMethod https://apply.intelligencecareers.gov/job-listings/search
    $jobFamilies = $response | Group-Object -Property jobFamily | Select-Object -ExpandProperty Name

    $scriptBlock = {
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    
        $jobFamilies | ForEach-Object {
              "'$_'"
        }
    }
   
    Register-ArgumentCompleter -CommandName Find-IntelCareers -ParameterName JobFamily -ScriptBlock $scriptBlock

}
catch{
    $Error[0]
}