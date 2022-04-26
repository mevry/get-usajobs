#Necessary for validation
#Todo: Put these in their own file
class PayGradeValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return @("01","02","03","04","05","06","07","08","09","10","11","12","13","14","15")
    }
}
class SavedQueryValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $Global:SavedQueries.Keys
    }
}
function Find-Usajobs{
    [cmdletbinding()]
    param(
        [string]$ApiKey = $Global:ApiKey,
        [ValidateSet([SavedQueryValidateSet])]
        $SavedQuery,
        [switch]$RemoveMultipleLocations,
        [string[]]$ControlNumberFilter,
        [switch]$RawQuery,
        [int]$JobCategoryCode,
        [string]$Keyword,
        [string]$PositionTitle,
        [string]$LocationName,
        [ValidateSet([PayGradeValidateSet])]
        [string]$PayGradeLow,
        [ValidateSet([PayGradeValidateSet])]
        [string]$PayGradeHigh
    )

    #Initialize body
    if($SavedQuery){
        $body = $SavedQueries[$SavedQuery] | ConvertTo-Json | ConvertFrom-Json -AsHashTable
    }else{
        $body = @{}
    }

    #Set query parameters, if specified
    if($JobCategoryCode){ $body['JobCategoryCode'] = $JobCategoryCode }
    if($Keyword){ $body['Keyword'] = $Keyword }
    if($PositionTitle){ $body['PositionTitle'] = $PositionTitle }
    if($LocationName){ $body['LocationName'] = $LocationName }
    if($PayGradeLow){ $body['PayGradeLow'] = $PayGradeLow }
    if($PayGradeHigh){ $body['PayGradeHigh'] = $PayGradeHigh }

    $requestSplat = @{
        ApiKey = $ApiKey
        Body = $body
    }
    
    if($RawQuery){
        Invoke-UsajobsPaginatedRequest @requestSplat
    }else{
        $response = Invoke-UsajobsPaginatedRequest @requestSplat

        #Format and filter response
        $response | `
            Select-Object `
                @{n="ControlNumber";e={$_.PositionUri -split "/" | Select-Object -Last 1}}, `
                PositionTitle, `
                DepartmentName, `
                @{n="City";e={$_.PositionLocationDisplay -split ", " | Select-Object -First 1}}, `
                @{n="Region";e={$_.PositionLocationDisplay -split ", " | Select-Object -First 1 -Skip 1}}, `
                @{n="Published";e={(Get-Date $_.PublicationStartDate).ToString("MM/dd/yyyy")}}, `
                @{n="Close";e={(Get-Date $_.ApplicationCloseDate).ToString("MM/dd/yyyy")}}, `
                @{n="LowGrade";e={$_.JobGrade.Code + $_.UserArea.Details.LowGrade}}, `
                @{n="HighGrade";e={$_.JobGrade.Code + $_.UserArea.Details.HighGrade}}, `
                @{n="LowPay";e={[int]$_.PositionRemuneration.MinimumRange}}, `
                @{n="HighPay";e={[int]$_.PositionRemuneration.MaximumRange}}, `
                @{n="Rate";e={$_.PositionRemuneration.RateIntervalCode}}, `
                PositionURI | `
            #Exclude results based on a provided list of control numbers
            ForEach-Object {
                ($_.ControlNumber -notin $ControlNumberFilter) ? $_ : (Write-Verbose -Message "Excluding [$($_.ControlNumber)] $($_.PositionTitle[0..15] -join '')") 
            } | `
            #Remove Multiple Locations (they tend not to respond and some aren't hiring)
            ForEach-Object {
                if($RemoveMultipleLocations){ $_ | Where-Object { $_.City -notmatch "Multiple Locations" -and $_.City -notmatch "Location Negotiable" -and $_.Region -notmatch "United States" } }
                else{ $_ }
            }
    }
}