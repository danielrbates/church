@echo OFF
REM Enumerating the local system using WMI.
REM Results will be created in text files within this directory.
md %CD%\enumeration\ 2>nul
cd %CD%\enumeration\
set filename=enumeration-wmi

REM User and group information
wmic useraccount get Caption,Name,AccountType,Description,FullName,LocalAccount,Disabled,SID > "%filename% useraccount.txt"
wmic group get name > "%filename% group.txt"

REM Information on running processes
wmic process list brief > "%filename% processes.txt"

REM Service information
wmic service list brief > "%filename% services.txt"

REM Network configuration information
wmic nicconfig list full > "%filename% network.txt"

REM Information about hosts on the same network
wmic netuse list full > "%filename% network-hosts.txt" 2>>nul

REM System configuration information
echo. > "%filename% system.txt"
echo Operating system: >> "%filename% system.txt"
wmic /append:"%filename% system.txt" OS get caption,csdversion,osarchitecture,version > nul
echo BIOS: >> "%filename% system.txt"
wmic /append:"%filename% system.txt" BIOS get Manufacturer,Name,Version > nul
echo CPU: >> "%filename% system.txt"
wmic /append:"%filename% system.txt" CPU get name,numberofcores,numberoflogicalprocessors > nul
echo Memory: >> "%filename% system.txt"
wmic /append:"%filename% system.txt" MEMORYCHIP get banklabel,capacity,devicelocator,partnumber,manufacturer,speed,tag > nul
echo NIC: >> "%filename% system.txt"
wmic /append:"%filename% system.txt" NIC get description,macaddress,netenabled,speed > nul
echo Disk drive: >> "%filename% system.txt"
wmic /append:"%filename% system.txt" DISKDRIVE get interfacetype,name,size,status > nul

REM File and directory integrity information
echo. > "%filename% file-directory integrity.txt"
REM notepad.exe
echo notepad.exe: >> "%filename% file-directory integrity.txt"
wmic /append:"%filename% file-directory integrity.txt" datafile where name='c:\\windows\\system32\\notepad.exe' get version,creation date,install date, last modified > nul
echo Hosts file: >> "%filename% file-directory integrity.txt"
wmic /append:"%filename% file-directory integrity.txt" datafile where name='c:\\windows\\system32\\drivers\\etc\\hosts' get version,creation date,install date, last modified > nul
echo Files in appdata: >> "%filename% file-directory integrity.txt"
wmic /append:"%filename% file-directory integrity.txt" datafile where "drive='c:' and path='\\Users\\NCCPC26\\Appdata\\Local\\'" get name