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

        $sheet.Column(2).Width = 50
        #$sheet.Column(3).Width = 30
        #$sheet.Column(4).Width = 30
        $sheet.Column(10) | Set-ExcelRange -NumberFormat "Currency" -AutoSize
        $sheet.Column(11) | Set-ExcelRange -NumberFormat "Currency" -AutoSize

        #Get Column number for position title and hyperlink
        $table = $sheet.Tables[0]
        $controlNumberColumn = $table.Columns['ControlNumber'].Id
        Write-Verbose -Message "ControlNumber Column#: $controlNumberColumn"
        $positionUriColumn = $table.Columns['PositionUri'].Id
        Write-Verbose -Message "PositionUri Column#: $positionUriColumn"

        #Map ascii to Excel column numbers
        $charDict = @{}
        $ascii = 65
        for($i = 1; $i -le 26; $i++){
            $charDict.Add($i, [char]$ascii)
            $ascii++
        }
        #Get position title
        $controlNumbers = $sheet.Cells | `
                            Where-Object {$_.Address -match $charDict[$controlNumberColumn]} | `
                            Select-Object -Skip 1
        
        #Get URIs
        $uriDict = @{}
        Write-Verbose -Message "URI DICTIONARY"
        $sheet.Cells | `
            Where-Object {$_.Address -match $charDict[$positionUriColumn]} | `
            Select-Object -Skip 1 | `
            ForEach-Object{
                $uriDict.Add($_.Address, $_.Hyperlink)
                Write-Verbose -Message "$($_.Address): $($_.Hyperlink)"
            }
        
        Write-Verbose -Message "URI ADDRESS"
        foreach($cell in $controlNumbers){
            $rowNum = $cell.Address.substring(1)
            $uriCellAddr = "$($charDict[$positionUriColumn])$($rowNum)"

            $cell.Hyperlink = $uriDict[$uriCellAddr]
            
            Write-Verbose -Message "$($uriCellAddr): $($cell.Hyperlink)"

        }

        Set-Column -Worksheet $sheet -Column $positionUriColumn -Hide

    }
    else{
        $ReportObject = "No Jobs Found"
        $excel = $ReportObject | Export-Excel -Path $Path -WorksheetName $Name -TableName $Name.Replace(" ", "").Replace('(',"").Replace(')',"") -AutoSize -PassThru
    }

    Close-ExcelPackage $excel
}