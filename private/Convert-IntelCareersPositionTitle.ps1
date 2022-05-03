function Convert-IntelCareersPositionTitle{
    param(
        $PositionTitle
    )

    $PositionTitle -split " - " | `
        Select-Object -First 1 | `
        ForEach-Object { 
            $_ -split ' \(' | `
            Select-Object -First 1
        }
}