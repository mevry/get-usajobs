function Get-UsajobsAgency{
    [cmdletbinding()]
    param(
        [switch]
        $IncludeDisabled
    )

    $response = Invoke-RestMethod -Uri 'https://data.usajobs.gov/api/codelist/agencysubelements'

    if($IncludeDisabled){
        $response.Codelist.ValidValue 
    }else{
        $response.CodeList.ValidValue | Where-Object {$_.IsDisabled -eq "No"}
    }
}