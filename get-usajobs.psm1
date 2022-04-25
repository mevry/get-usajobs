#using module ".\classes\.psm1"

$dotSource = Get-ChildItem -Include "*.ps1" -Recurse -Path @("$PSScriptRoot\private","$PSScriptRoot\public")

foreach($file in ($public + $dotSource)){
    try{
        #dot source script
        . $file.FullName
    }
    catch{
        Write-Error -Message "Failed to import $($file.FullName): $($error[0].Exception.Message)"
    }
}

#Export-ModuleMember -Function $public.BaseName