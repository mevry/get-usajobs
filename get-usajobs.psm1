#using module ".\classes\.psm1"

$public = Get-ChildItem -Recurse -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue
$private = Get-ChildItem -Recurse -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue

foreach($file in ($public + $private)){
    try{
        #dot source script
        . $file.FullName
    }
    catch{
        Write-Error -Message "Failed to import $($file.FullName): $($error[0].Exception.Message)"
    }
}

#Export-ModuleMember -Function $public.BaseName