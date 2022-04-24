$config = 'config/config.json'

try{
    if(-not (Test-Path $config)){
        New-Item -Path $config -Force | Out-Null
        Set-Content -ErrorAction Stop -Path $config -Value @"
{
    "server":"data.usajobs.gov"
}
"@
    }
}
catch{
    $Error[0]
}