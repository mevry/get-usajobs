class IntelCareersJobFamilyValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $Global:IntelCareersJobFamilies
    }
}

function Find-IntelCareers{
    [cmdletbinding()]
    param(
        [ValidateSet([IntelCareersJobFamilyValidateSet])]
        [string]$JobFamily,
        [switch]$RawQuery

    )

    $response = Invoke-RestMethod https://apply.intelligencecareers.gov/job-listings/search


    $response = $response | `
    #Filter based on $JobFamily
    ForEach-Object {
        if($JobFamily){ $_ | Where-Object { $_.jobFamily -eq $JobFamily } }
        else{ $_ }
    }

    if($RawQuery){
        $response
    }
    else{
        $response | `
            #Coerce data into Find-Usajobs format
            Select-Object `
            @{n="ControlNumber";e={$_.jobNumber}}, `
            @{n="PositionTitle";e={Convert-IntelCareersPositionTitle -PositionTitle $_.jobTitle}}, `
            @{n="DepartmentName";e={$_.agency}}, `
            @{n="Agency";e={$_.Agency}}, `
            @{n="City";e={$_.location -split ", " | Select-Object -First 1}}, `
            @{n="Region";e={$_.location -split ", " | Select-Object -First 1 -Skip 1}}, `
            @{n="Published";e={Get-Date $_.postedDate}}, `
            @{n="Close";e={Get-Date $_.jobCloseDate}}, `
            @{n="LowGrade";e={Convert-IntelCareersPayRange -jobPayPlan $_.jobPayPlan -grade $_.grade}}, `
            @{n="HighGrade";e={Convert-IntelCareersPayRange -jobPayPlan $_.jobPayPlan -grade $_.grade -High}}, `
            @{n="LowPay";e={if($_.jobQualificationsExt){Convert-IntelCareersSalary -Text $_.jobQualificationsExt}}}, `
            @{n="HighPay";e={if($_.jobQualificationsExt){Convert-IntelCareersSalary -Text $_.jobQualificationsExt -High}}}, `
            @{n="Rate";e={'Per Year'}}, `
            @{n="PositionURI";e={"https://apply.intelligencecareers.gov/job-description/$($_.jobNumber)"}}
    }

}