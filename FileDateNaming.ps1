Get-ChildItem | Where-Object { -not $_.PsIsContainer } | ForEach-Object {
    $date = $null
    $date = (exiftool -p '$DateTimeOriginal' $_.FullName)
    if ($date -eq $null) {
        $date = (exiftool -p '$CreateDate' $_.FullName)
    }
    if ($date -eq $null) {
        $date = (exiftool -p '$FileModifyDate' $_.FullName)
    }
    if ($date -eq $null) {
        Write-Host $_.FullName " => " "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    }
    else {
        $date = ("[$date]").Replace(':', '.').Replace(' ', 'T')
        Write-Host $_.FullName " => " $date
    }
}