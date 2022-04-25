function Export-UsajobsReport{
    [cmdletbinding()]
    param(
        [object]$ReportObject,
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Path =  "$((Get-Date).ToString("yyyy-MM-dd"))_USAJOBSSearch.xlsx"
    )

    if($ReportObject){
        $excel = $ReportObject | Export-Excel -Path $Path -WorksheetName $Name -TableName $Name.Replace(" ", "").Replace('(',"").Replace(')',"") -AutoSize -PassThru

        $sheet = $excel.Workbook.Worksheets[$Name]

        $sheet.Column(1).Width = 50
        $sheet.Column(2).Width = 30
        $sheet.Column(3).Width = 30
        $sheet.Column(9) | Set-ExcelRange -NumberFormat "Currency" -AutoSize
        $sheet.Column(10) | Set-ExcelRange -NumberFormat "Currency" -AutoSize
    }else{
        $ReportObject = "No Jobs Found"
        $excel = $ReportObject | Export-Excel -Path $Path -WorksheetName $Name -TableName $Name.Replace(" ", "").Replace('(',"").Replace(')',"") -AutoSize -PassThru
    }

    Close-ExcelPackage $excel
}