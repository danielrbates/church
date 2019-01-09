function Get-pslist-processes
{
$pslist = & C:\Sysinternals\pslist.exe -accepteula
$pslist = $pslist[8..($pslist.length-1)]
$pslist | foreach {
    $columns = $_ -split "\s{2,}", 8
    New-Object -TypeName PSObject -Property @{
        ProcessName = $columns[0]
        ID = [int]$columns[1]
        Priority = $columns[2]
        Threads = $columns[3]
        Handles = $columns[4]
        Private = $columns[5]
        CPUTime = $columns[6]
        ElapsedTime = $columns[7]
        }
    }
}

$internal = (Get-Process | select ID, ProcessName | Sort-Object -Property ID)
$external = (Get-pslist-processes | select ID, ProcessName | Sort-Object -Property ID)

$difference = (Compare-Object -ReferenceObject $internal -DifferenceObject $external -PassThru)

echo ""
echo "PSList counts $($external.count) processes, and Get-Process counts $($internal.count) processes."

foreach ($i in $difference) {
    #echo "Difference SideIndicator is $($difference.SideIndicator)"
    if ($difference.SideIndicator -eq "<=") {
        echo "Process ID $($difference.ID), $($difference.ProcessName), was only found by Get-Process."
        } else {
        echo "Process ID $($difference.ID), $($difference.ProcessName), was only found by PSList."
        }
    }