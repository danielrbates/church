$path=$env:USERPROFILE

function Get-pslist-processes
{
$pslist = & C:\Sysinternals\pslist.exe -accepteula
$pslist = $pslist[8..($pslist.length-1)]
$pslist | foreach {
    $columns = $_ -split '(\s+\b(?=\d))'
    New-Object -TypeName PSObject -Property @{
        ProcessName = $columns[0]
        ID = [int]$columns[2]
        }
    }
}

$internal = (Get-Process | select ID,ProcessName | Sort-Object -Property ID)
notepad
$external = (Get-pslist-processes | select ID,ProcessName | Sort-Object -Property ID)
$internal | Out-File -FilePath "$path\internal.txt"
$external | Out-File -FilePath "$path\external.txt"

$difference = (Compare-Object -ReferenceObject $(get-content $path\internal.txt) -DifferenceObject $(get-content $path\external.txt) )

echo ""
echo "PSList counts $($external.count) processes, and Get-Process counts $($internal.count) processes."

for ($i=0; $i -lt $difference.Length; $i++) {
    #echo "Difference SideIndicator is $($difference[$i].SideIndicator)"
    if ($difference[$i].SideIndicator -eq "<=") {
        echo "Process ID $(($difference[$i].InputObject -split "\s+\b")[0]), $((($difference[$i].InputObject -split "\s+\b")[1]) -split "\s+"), was only found by Get-Process."
        } else {
        echo "Process ID $(($difference[$i].InputObject -split "\s+\b")[0]), $((($difference[$i].InputObject -split "\s+\b")[1]) -split "\s+"), was only found by PSList."
        }
    }