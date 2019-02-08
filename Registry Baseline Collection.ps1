# Set machine status (clean or infected):
# (This will become part of the output filename)
$machine_status = "clean"

#Set output file location and filename, and create the file
$outfile = "$userprofile\registry baseline - $machine_status.txt"
New-Item -Path $outfile -ItemType File -Force

# Define interesting keys
$keylist = @(
    # Auto-run locations for the machine and individual users
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce",
    "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\Run",
    "HKU:\*\SOFTWARE\Microsoft\Windows\CurrentVersion\RunOnce"
    # Recent network connections
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\NetworkList\Profiles\*\"
    # User accounts
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList\*\" 
    # Connected USB devices
    "HKLM:\SYSTEM\CurrentControlSet\Enum\USB\*\*\Device Parameters"
    )

#Set registry path for HKEY_USERS, if it doesn't exist
If (!(test-path HKU:)) {
    New-PSDrive HKU Registry HKEY_USERS
    Set-Location HKU:
    }

# Function Definitions
# Parse a registry key, given a path [string].  Prints the path, key
# name, data, and type to the output file.
function parse-registrykey {
    param([string]$path)
    $key = get-item -path $path
    foreach ($subkey in $key.Property) {
        echo ("$($key.PSPath.Split('::')[2]),$subkey,$($key.GetValue("$subkey")),$($key.GetValueKind("$subkey"))") | out-file $outfile -Append
        }
    }
# Parse a registry key that contains subkeys.  Takes a path [string]
# as input and passes each subkey path on to the parsing function.
function parse-wildcardedregistrykey {
    param([string]$path)
    $key = get-item -path $path
    foreach ($item in $key.PSPath) {
        parse-registrykey -path $item
        }
    }

#Main Function
#####################################################################
# Parse interesting keys, defined earlier:
# (Wildcarded key paths must be processed through a separate function)
foreach ($item in $keylist) {
    if (($item -match '\*') -eq $true) {
        # If true, this path contains a wildcard.  Go to the function
        # that can handle a wildcarded path:
        parse-wildcardedregistrykey -path $item
    }else{
        # Otherwise, it does not contain a wildcard.  Go directly to
        # the parser function:
        parse-registrykey -path $item
        }
    }

# Automatically open the output file (comment out if not needed)
notepad $outfile
