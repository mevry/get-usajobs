function Export-UsajobsReport{
    [cmdletbinding()]
    param(
        [object]$ReportObject,
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$Path =  "$((Get-Date).ToString("yyyy-MM-dd"))_USAJOBSSearch.xlsx",
        [switch]$SortByPay,
        [switch]$GroupByLocation
    )

    if($ReportObject){

        if($SortByPay) { $ReportObject = $ReportObject | Sort-Object -Property "LowPay" }

        if($GroupByLocation){
            $locationGroups = $ReportObject | Group-Object -Property Region
            foreach($locationGroup in $locationGroups){
                Export-UsajobsReport -ReportObject $locationGroup.Group -Name $locationGroup.Name -Path $Path
            } 
        }
        else{
            $excel = $ReportObject | Export-Excel -Path $Path -WorksheetName $Name -TableName $Name.Replace(" ", "").Replace('(',"").Replace(')',"") -AutoSize -PassThru

            $sheet = $excel.Workbook.Worksheets[$Name]
            $table = $sheet.Tables[0]
            
            #Retrieve select columns
            $positionTitleColumn = $sheet.Column($table.Columns['PositionTitle'].Id)
            $departmentColumn = $sheet.Column($table.Columns['DepartmentName'].Id)
            $agencyColumn = $sheet.Column($table.Columns['Agency'].Id)
            $cityColumn = $sheet.Column($table.Columns['City'].Id)
            
            #Conditionally format column widths
            $positionTitleColumn.Width = $positionTitleColumn.Width -gt 45 ? 45 : $positionTitleColumn.Width
            $departmentColumn.Width = $departmentColumn.Width -gt 30 ? 30 : $departmentColumn.Width
            $agencyColumn.Width = $agencyColumn.Width -gt 40 ? 40 : $agencyColumn.Width
            $cityColumn.Width = $cityColumn.Width -gt 30 ? 30 : $cityColumn.Width

            #Format pay columns as currency
            $sheet.Column($table.Columns['LowGrade'].Id) | Set-ExcelRange -NumberFormat "Currency" -AutoSize
            $sheet.Column($table.Columns['HighGrade'].Id) | Set-ExcelRange -NumberFormat "Currency" -AutoSize

            #Get Column number for position title and hyperlink
            
            $controlNumberColumn = $table.Columns['ControlNumber'].Id
            $positionUriColumn = $table.Columns['PositionUri'].Id

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
    }
    else{
        $ReportObject = "No Jobs Found"
        $excel = $ReportObject | Export-Excel -Path $Path -WorksheetName $Name -TableName $Name.Replace(" ", "").Replace('(',"").Replace(')',"") -AutoSize -PassThru
    }

    if($excel) { Close-ExcelPackage $excel}
}