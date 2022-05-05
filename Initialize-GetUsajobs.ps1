$queries = 'config/queries.json'
$defaults = 'config/default.json'

try{
    #Create example saved query file
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

    #Create global defaults file, which apply to all saved
    #queries unless explicitly overwritten
    if(-not (Test-Path $defaults)){
        New-Item -Path $defaults -Force | Out-Null
        Set-Content -ErrorAction Stop -Path $queries -Value @"
    {
        "PayGradeLow": "01",
        "PayGradeHigh": "15"
    }
"@
    }

    #Load saved queries
    if(Test-Path $queries){
        $Global:SavedQueries = [ordered]@{}
        $defaultObject = Get-Content $defaults | ConvertFrom-Json -Depth 10
        $defaultProperties = Get-Member -InputObject $defaultObject -MemberType NoteProperty
        $queryObjects = Get-Content $queries | ConvertFrom-Json -Depth 10

        foreach($query in $queryObjects) {
            foreach($property in $defaultProperties){
                $query.Query | Add-Member -MemberType NoteProperty -Name $property.Name -Value $defaultObject.$($property.Name) -Force
            }
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