class IntelCareersJobFamilyValidateSet : System.Management.Automation.IValidateSetValuesGenerator {
    [string[]] GetValidValues() {
        return $Global:IntelligenceCareersJobFamilies
    }
}

function Find-IntelligenceCareers{
    [cmdletbinding()]
    param(
        [ValidateSet([IntelCareersJobFamilyValidateSet])]
        [string]$JobFamily,
        
    )



}