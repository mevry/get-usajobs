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

class ServerSortFieldValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        
        return @("opendate","closedate","organizationname","positiontitle","salary","agency")
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
        [string]$PayGradeHigh,
        [int]$PostedDaysAgo,
        [ValidateSet([ServerSortFieldValidateSet])]
        [string]$ServerSortField
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
    #if($DatePosted){ $body['DatePosted'] = $DatePosted }
    if($ServerSortField){ $body['SortField'] = $ServerSortField }

    #if you filter by number of days ago the job was published, you must sort
    #by opendate on the server side, otherwise you will risk missing results
    if($PostedDaysAgo){ $body['SortField'] = 'opendate' }

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
                @{n="Agency";e={$_.OrganizationName}}, `
                @{n="City";e={$_.PositionLocationDisplay -split ", " | Select-Object -First 1}}, `
                @{n="Region";e={$_.PositionLocationDisplay -split ", " | Select-Object -First 1 -Skip 1}}, `
                @{n="Published";e={Get-Date $_.PublicationStartDate}}, `
                @{n="Close";e={Get-Date $_.ApplicationCloseDate}}, `
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
                if($RemoveMultipleLocations){
                    $_ | Where-Object { $_.City -notmatch "Multiple Locations" -and $_.City -notmatch "Location Negotiable" -and $_.Region -notmatch "United States" } 
                }
                else{ $_ }
            } | `
            #Filter out based on # of days ago. API parameter for this is broken on USAJOBS
            ForEach-Object {
                if($PostedDaysAgo){
                    $_ | Where-Object {$_.Published -ge (Get-Date).AddDays(-1 * $PostedDaysAgo)}
                }
                else{ $_ }
            }
    }
}