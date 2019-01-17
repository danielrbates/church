#Set path to baseline files
$path = "C:\Users\NCCPC26\Downloads\Windows\Exercise - Malicious Registry"

#Set filename of output file
$outfile = "$path\registry diff.txt"

#Import baselines
$clean = Get-Content -Path "$path\registry baseline - clean.txt" | Where-Object {$_.trim() -ne "" }
$infected = Get-Content -Path "$path\registry baseline - infected.txt" | Where-Object {$_.trim() -ne "" }


#Compare baselines
$diff = Compare-Object  $clean $infected  | where SideIndicator -eq "=>"

#Write results to output file
echo "The following indicators were found in the registry of the infected system:" | Out-File $outfile
$diff.InputObject | Out-File $outfile -Append