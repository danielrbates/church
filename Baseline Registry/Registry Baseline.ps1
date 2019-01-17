#Basic system information
$computername = $env:COMPUTERNAME
$userprofile = $env:USERPROFILE

#Set output file
$outfile = "$userprofile\registry baseline TESTONLY.txt"

#Set registry path for HKEY_USERS, if it doesn't exist
If (!(test-path HKU:)) {
    New-PSDrive HKU Registry HKEY_USERS
    Set-Location HKU:
    }

#Get forensically relevant registry keys
##Persistence  -get item properties for the given registry path
#              -deselect the built-in PowerShell properties
#              -format as a list 
#              -convert to an array of strings
#              -remove blank lines
$HKLMrun = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | select * -ExcludeProperty PS* | Format-List | Out-String -Stream | Where-Object {$_.trim() -ne "" }
$HKLMrunonce = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" | select * -ExcludeProperty PS* | Format-List | Out-String -Stream | Where-Object {$_.trim() -ne "" }
$HKUrun = Get-ItemProperty -Path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" | select * -ExcludeProperty PS* | Format-List | Out-String -Stream | Where-Object {$_.trim() -ne "" }
$HKUrunonce = Get-ItemProperty -Path "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce" | select * -ExcludeProperty PS* | Format-List | Out-String -Stream | Where-Object {$_.trim() -ne "" }
##Recent network connections
$NetworkProfile = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\*\"
##User accounts
$UserAccounts = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*\" 
##Connected USB devices
$USB = Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\*\*\Device Parameters"

#Export information to a text file
echo "Baseline Registry Configuration for $computername`n" | Out-File $outfile
$(echo "","","Persistence Keys","--------------------------------------------------") | Out-File $outfile -Append
echo ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",$HKLMrun,"") | Out-File $outfile -Append
echo ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",$HKLMrunonce,"") | Out-File $outfile -Append
echo ("HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",$HKUrun,"") | Out-File $outfile -Append
echo ("HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",$HKUrunonce,"") | Out-File $outfile -Append
$(echo "","","Recent Network Connections","--------------------------------------------------") | Out-File $outfile -Append
echo ($NetworkProfile.ProfileName,"") | Out-File $outfile -Append
$(echo "","","User Accounts","--------------------------------------------------") | Out-File $outfile -Append
echo ($UserAccounts.ProfileImagePath,"") | Out-File $outfile -Append
$(echo "","","USB devices","--------------------------------------------------") | Out-File $outfile -Append
echo ($USB,"") | Out-File $outfile -Append

# Automatically open the output file
# (Comment out if not needed)
notepad $outfile