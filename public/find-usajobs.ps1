#Generate dynamic values from saved queries
class SavedQueryValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $Global:SavedQueries.Keys
    }
}

function Find-Usajobs{
    [cmdletbinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,
        [ValidateSet([SavedQueryValidateSet])]
        $SavedQuery,

        [switch]
        $RawQuery
    )
    $body = $SavedQueries[$SavedQuery] | ConvertTo-Json | ConvertFrom-Json -AsHashTable

    if($RawQuery){
        Invoke-UsajobsPaginatedRequest -ApiKey $ApiKey -Body $body 

    }else{
        $response = Invoke-UsajobsPaginatedRequest -ApiKey $ApiKey -Body $body 

        $response | `
            Select-Object PositionTitle, `
            DepartmentName, `
            @{n="City";e={$_.PositionLocationDisplay -split ", " | Select-Object -First 1}}, `
            @{n="Region";e={$_.PositionLocationDisplay -split ", " | Select-Object -First 1 -Skip 1}}, `
            @{n="Published";e={(Get-Date $_.PublicationStartDate).ToString("MM/dd/yyyy")}}, `
            @{n="Close";e={(Get-Date $_.ApplicationCloseDate).ToString("MM/dd/yyyy")}}, `
            @{n="LowGrade";e={$_.JobGrade.Code + $_.UserArea.Details.LowGrade}}, `
            @{n="HighGrade";e={$_.JobGrade.Code + $_.UserArea.Details.HighGrade}}, `
            @{n="LowPay";e={'{0:C0}' -f ([int]$_.PositionRemuneration.MinimumRange)}}, `
            @{n="HighPay";e={'{0:C0}' -f ([int]$_.PositionRemuneration.MaximumRange)}}, `
            @{n="Rate";e={$_.PositionRemuneration.RateIntervalCode}}, `
            PositionURI
    }

}