# Get the current date and time (for enumeration, and the output filename).
$timestamp = Get-Date

# Set the output file location and filename using the formatted timestamp, and
# create the file.
$filename = "baseline-" + $timestamp.tostring("yyyyMMdd-HHmmss") + ".txt"
$outfile = "$PSScriptRoot\Output\$filename"
New-Item -Path $outfile -ItemType File -Force

# Set registry path for HKEY_USERS, if it doesn't exist.
If (!(test-path HKU:)) { 
    New-PSDrive HKU Registry HKEY_USERS
    }

################################################################################
# Get parameters for enumeration.
### System date and time
function Show-SystemDatendTime {
    # Format using -F for FullDateTimePattern (long date and long time).
    Get-Date -Format F
    }

### Hostname
function Show-Hostname {
    # Use the environmental variable for the hostname.
    $env:COMPUTERNAME
    }

### Users and groups
function Show-LocalUsersAndGroups {
    # Get local users and display as a table with width set to 2048 to avoid
    # truncating the Description column.
    echo "Local User Accounts:"
    Get-LocalUser | Format-Table | Out-String -Width 2048
    # Get local groups and display as a table with width set to 2048 to avoid
    # truncating the Description column.
    echo "Local groups:"
    Get-LocalGroup | Format-Table | Out-String -Width 2048
    }

### Logged on users
function Show-LoggedOnUsers {
    # Find logon sessions and associate session type, authentication method, and
    # session start time.
    $LoggedOnUsers = Get-CimInstance Win32_LoggedOnUser | ForEach-Object {
        # Set variables for session ID and username
        $SessionID = $($_.Dependent).LogonId
        $username = $($_.Antecedent).Name

        # Find the session type, auth method, and start time for each session ID
        $type = $(Get-CimInstance Win32_LogonSession | 
            where {$_.LogonId -eq "$SessionID"}).LogonType
        $auth = $(Get-CimInstance Win32_LogonSession | 
            where {$_.LogonId -eq "$SessionID"}).AuthenticationPackage
        $starttime = $(Get-CimInstance Win32_LogonSession | 
            where {$_.LogonId -eq "$SessionID"}).StartTime

        # Create a new object to store our custom properties
        New-Object psobject -Property @{
            Session = $session
            Username = $username
            Type = $type
            Auth = $auth
            StartTime = $starttime
            } 
        }
    
    # Print the results as a table.
    $LoggedOnUsers | Format-Table -Property Session,Username,Type,Auth,StartTime
    }

### Running processes
function Show-RunningProcesses {
    Get-Process | Format-Table Id, Name, SessionId, Description -AutoSize |
        Out-String -Width 2048           # Set width to avoid truncating columns
    }

### Services and their states
function Show-Services {
    Get-Service | Sort-Object -Property Name | Format-Table -AutoSize | 
    Out-String -Width 2048               # Set width to avoid truncating columns
    }

### Network information
function Show-NetworkInformation {
    Get-CimInstance Win32_NetworkAdapterConfiguration | where {$_.IPAddress -ne `
        $null} | ForEach-Object {
        # Define regex patterns to match valid IPv4 and IPv6 addresses
        [regex]$IPv4 = "((\d){1,3}\.){3}((\d){1,3})"
        [regex]$IPv6 = "([A-F\d]:)|(:[A-F\d])"
        [regex]$IPv6_linklocal = "FE80"
    
        # Set variables
        $AdapterDNSSuffix = $_.DNSDomainSuffixSearchOrder
        $AdapterDescription = $_.Description
        $AdapterMAC = $_.MACAddress
        $AdapterIPv6 = $_.IPAddress | Select-String -Pattern $IPv6 | 
            Select-String -Pattern $IPv6_linklocal -NotMatch
        $AdapterIPv4 = $_.IPAddress | Select-String -Pattern $IPv4
        $AdapterIPSubnet = $_.IPSubnet | Select-String -Pattern $IPv4
        $AdapterGateway = $_.DefaultIPGateway | Select-String -Pattern $IPv4
        $AdapterDHCP = $_.DHCPServer -join ", "
        $AdapterDNS = $_.DNSServerSearchOrder -join ", "
    
        # Print network information to screen 
        echo "Description:`t$AdapterDescription"
        echo "MAC Address:`t$AdapterMAC"
        echo "IPv4 Address:`t$AdapterIPv4"
        echo "IPv4 Subnet:`t$AdapterIPSubnet"
        echo "IPv4 Gateway:`t$AdapterGateway"
        if ($AdapterIPv6.count -eq 0) {
            echo "IPv6 Address:`tNone Configured"
            } else {
            $AdapterIPv6 | ForEach-Object {
                echo "IPv6 Address:`t$_"
                }
            }
        echo "DHCP Servers:`t$AdapterDHCP"
        echo "DNS Servers:`t$AdapterDNS"
        echo ""
        }
    }

### Listening network sockets
function Show-ListeningSockets {
    $ListeningSockets = Get-NetTCPConnection -State Listen | ForEach-Object {
        # Set variables
        $LocalAddress = $_.LocalAddress
        # Reformat local address to match netstat output - surround IPv6
        # addresses with square brackets
        if ($_.LocalAddress -like "*:*") {
            $LocalAddress = "[" + $_.LocalAddress + "]"
            }
        $LocalPort = $_.LocalPort
        $LocalSocket = $LocalAddress + ":" + $LocalPort
        $ProcessName = (Get-Process -Id $($_.OwningProcess)).ProcessName

        # Store variables in a custom object
        New-Object psobject -Property @{
            ProcessName = $ProcessName
            PID = $_.OwningProcess
            Address = $LocalAddress
            Port = $LocalPort
            Socket = $LocalSocket
            }
        }

    # Print the output as a table sorted by address, then by port.
    $ListeningSockets | sort -Property Address, Port | 
        Format-Table -Property PID, ProcessName, Socket
    }

### System configuration information
function Show-SystemConfiguration {
    # Set Variables
    ### Operating system
    $Win32_OperatingSystem = Get-CimInstance Win32_OperatingSystem
    $OSName = $Win32_OperatingSystem.Caption
    $OSVersion = $Win32_OperatingSystem.Version
    ### Computer system (manufacturer and model)
    $Win32_ComputerSystem = Get-CimInstance Win32_ComputerSystem
    $SystemName = $Win32_ComputerSystem.Name
    $SystemManufacturer = $Win32_ComputerSystem.Manufacturer
    $SystemModel = $Win32_ComputerSystem.Model
    $SystemType = $Win32_ComputerSystem.SystemType
    ### BIOS
    $Win32_BIOS = Get-CimInstance Win32_BIOS
    $BIOSVersion = $Win32_BIOS.Manufacturer + " " + $Win32_BIOS.SoftwareElementID
    $BIOSDate = $Win32_BIOS.ReleaseDate
    ### CPU
    $Win32_Processor = Get-CimInstance Win32_Processor
    $ProcessorName = $Win32_Processor.Name
    $ProcessorCores = $Win32_Processor.NumberOfCores
    ### RAM (add capacity of all sticks and convert to GB)
    $TotalPhysicalMemory = ($($(Get-CimInstance Win32_PhysicalMemory).Capacity | 
        Measure-Object -Sum).Sum / (1024*1024*1024)).ToString() + " GB"

    # Store system configuration items in an ordered hash table.
    $SystemConfiguration = [ordered]@{
        "OS Name" = $OSName
        "Version" = $OSVersion
        "System Name" = $SystemName
        "Manufacturer" = $SystemManufacturer
        "Model" = $SystemModel
        "Type" = $SystemType
        "BIOS Version" = $BIOSVersion
        "BIOS Date" = $BIOSDate
        "Processor" = $ProcessorName
        "Number of Cores" = $ProcessorCores
        "Installed RAM" = $TotalPhysicalMemory
        }

    # Display system configuration as a table.
    $SystemConfiguration | Format-Table -HideTableHeaders
}

### Mapped drives
function Show-MappedDrives {
    # Iterate through all users in HKU: to find registry keys for mapped drives.
    Get-ItemProperty HKU:\*\Network\* | ForEach-Object {
        $User = $_.UserName
        $Path = $_.RemotePath
        $DriveLetter = ($_.PSChildName).ToUpper()
        echo ("User $User mapped $Path as $DriveLetter`:")
        }
    }

### Plug and play devices
function Show-PnPDevices {
    # Select active devices and sort by class.  Display as a table; set width 
    # to avoid truncating DeviceID column.
    Get-PnpDevice | where {$_.Status -eq "OK"} | Sort-Object Class | 
        Format-Table -Property Class,FriendlyName,DeviceID -AutoSize | 
        Out-String -Width 2048
    }

### Shared resources
function Show-SharedResources {
    # Create a new object to store properties for each SMB share.
    $SharedResources = Get-SmbShare | ForEach-Object {
        New-Object psobject -Property @{
            Name = $_.Name
            Path = $_.Path
            ScopeName = $_.ScopeName
            Description = $_.Description
            # Import access rights from Get-SmbShareAccess
            Access = $($_ | Get-SmbShareAccess).AccountName -join ", "
            }
        }
    # Display as a table; set width to avoid truncating Access column.
    $SharedResources | Format-Table Name, Path, ScopeName, Description, Access | 
        Out-String -Width 2048
    }

### Scheduled tasks
function Show-ScheduledTasks {
    # Create a new object with the following properties: TaskPath, TaskName, 
    # State, and NextRunTime (from Get-ScheduledTaskInfo).
    $ScheduledTasks = Get-ScheduledTask | ForEach-Object {
        New-Object psobject -Property @{
            TaskPath = $_.TaskPath
            TaskName = $_.TaskName
            State = $_.State
            NextRunTime = $($_ | Get-ScheduledTaskInfo).NextRunTime
            }
        }

    # Display as a table formatted like the schtasks command output: grouped  
    # by TaskPath with three columns for TaskName, NextRunTime, and State.  
    # NOTE: 'e' = Expression; 'w' = Width (in characters).
    $ScheduledTasks | sort -Property TaskPath | Format-Table -Property `
        @{e="TaskName"; w=40},@{e="NextRunTime"; w=22},@{e="State"; w=15} `
        -GroupBy TaskPath | Out-String
    }

################################################################################
# Add a section break and whitespace after each section.  This enables the
# comparison script to identify sections to compare individually.
function Print-SectionHeader {
    echo "---END-OF-SECTION---"
    echo ""; echo ""
    }

################################################################################
# Print enumerated parameters to the output file
$(
    echo ("System date and time:"); Show-SystemDatendTime; Print-SectionHeader
    echo ("Hostname:"); Show-Hostname; Print-SectionHeader
    echo ("Users and groups:"); Show-LocalUsersAndGroups; Print-SectionHeader
    echo ("Logged on users: "); Show-LoggedOnUsers; Print-SectionHeader
    echo ("Running processes:"); Show-RunningProcesses; Print-SectionHeader
    echo ("Services and their states:"); Show-Services; Print-SectionHeader
    echo ("Network information:"); Show-NetworkInformation; Print-SectionHeader
    echo ("Listening network sockets:"); Show-ListeningSockets
        Print-SectionHeader
    echo ("System configuration information:"); Show-SystemConfiguration;
        Print-SectionHeader
    echo ("Mapped drives:"); Show-MappedDrives; Print-SectionHeader
    echo ("Plug and play devices:"); Show-PnPDevices; Print-SectionHeader
    echo ("Shared resources:"); Show-SharedResources; Print-SectionHeader
    echo ("Scheduled tasks:"); Show-ScheduledTasks; Print-SectionHeader
    ) | Out-File -FilePath $outfile

# Optional: Automatically open the output file.
notepad $outfile
