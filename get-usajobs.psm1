#using module ".\classes\SavedQueryValidateSet.psm1"
#using module ".\classes\PayGradeValidateSet.psm1"

$dotSource = Get-ChildItem -Include "*.ps1" -Recurse -Path @("$PSScriptRoot\private","$PSScriptRoot\public")

foreach($file in $dotSource){
    try{
        #dot source script
        . $file.FullName
    }
    catch{
        Write-Error -Message "Failed to import $($file.FullName): $($error[0].Exception.Message)"
    }
}

#Export-ModuleMember -Function $public.BaseName