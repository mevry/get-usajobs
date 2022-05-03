function Convert-IntelCareersPayRange{
    param(
        $jobPayPlan,
        $grade,
        [switch]$High
    )
    if($grade -match "to"){
        $range = $grade -split " to " | ForEach-Object {$_ -split "/" | Select-Object -First 1}

        if($High){
            $grade = "$($range[1])"
        }else{
            $grade = "$($range[0])"
        }
    }
    return "$($jobPayPlan)$($grade)"

}