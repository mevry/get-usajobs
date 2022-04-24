$config = 'config/config.json'

try{
    if(-not (Test-Path $config)){
        New-Item -Path $config -Force
    }
}
catch{
    $Error[0]
}