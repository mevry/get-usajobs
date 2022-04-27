function Get-UsajobsCyberWorkRoles{
    [cmdletbinding()]
    param(
        [switch]
        $IncludeDisabled
    )

    $response = Invoke-RestMethod -Uri 'https://data.usajobs.gov/api/codelist/cyberworkroles'

    if($IncludeDisabled){
        $response.Codelist.ValidValue 
    }else{
        $response.CodeList.ValidValue | Where-Object {$_.IsDisabled -eq "No"}
    }
}