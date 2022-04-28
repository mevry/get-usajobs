function Convert-IntelCareersSalary{
    param(
        $Text,
        [switch]$High
    )

    $salaryMatches = $text | `
        #Find anything labeled Salary Range
        Select-String -AllMatches -Pattern "Salary Range:  (.*?) \(" | `
        ForEach-Object {$_.Matches.Value} | `
        #Capture the salaries
        Select-String -AllMatches -Pattern '[$](.*?) ' | `
        ForEach-Object {$_.Matches.Value} | `
        #Convert them to integers
        ForEach-Object{ [int]($_ -replace '[^0-9.]')} | `
        Sort-Object

    $High ? $salaryMatches[-1] : $salaryMatches[0]
}