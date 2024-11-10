function Get-EXIFDate($string) {
    $splits = $string -split ' '
    $date = $splits[0].Replace(':', '/')
    $time = $splits[1]
    return "$($date)T$($time)"
    # return "$date $time"
}
$target = $args[0]
if ($null -eq $target) {
    $target = '.'
}
Get-ChildItem $target | Where-Object { -not $_.PsIsContainer } | ForEach-Object {
    Write-Host " *" $_.FullName
    $sources = @('$DateTimeOriginal', '$CreateDate', '$FileModifyDate')
    $s = 0
    $datetime = $null
    while (($datetime -eq $null) -or ($datetime -eq '')) {
        if ($s -gt $sources.Length) {
            Write-Host "!! No info in EXIF to name."
            return
        }
        $source = $sources[$s]
        $datetime = exiftool -m -p $source $_.FullName
        $s += 1
    }
    Write-Host " @" $source ":" $datetime
    $datetime = Get-EXIFDate($datetime)
    if (-not ($datetime -contains '+')) {
        # Auto Timezone
        $comparison = Get-Date (Get-EXIFDate(exiftool -m -p '$FileModifyDate' $_.FullName))
        $utc = Get-Date "$datetime+00:00"
        $diff_utc = [System.Math]::Abs(($comparison - $utc).TotalHours)
        $local = Get-Date "$datetime$((Get-Date).ToString((' K')))"
        $diff_local = [System.Math]::Abs(($comparison - $local).TotalHours)
        if (($diff_utc -gt 48) -and ($diff_local -gt 48)) {
            Write-Host "!! Cannot decide timezone."
            return
        }
        if ($diff_utc -le $diff_local) {
            $date = $utc
        }
        else {
            $date = $local
        }
    }
    else {
        $date = Get-Date $datetime
    }
    $date = Get-Date "$date $time"
    $date = $date.ToString("yyyy.MM.ddTHH.mm.ss")
    $origin = $_.BaseName
    $ext = $_.Extension
    $name = "[$date][$origin]$ext"
    # Rename-Item $_.FullName -NewName $name
    Write-Host "=>" $name
    Write-Host
}