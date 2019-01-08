@echo OFF
(
echo Enumerating the local system using Windows CMD executables.
set date = date \T
set time = time \T
echo Report date: %date%
echo Report time: %time%
echo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
echo:
REM Basic information about the system (username, domain):
echo Username: %username%
echo Group: %userdomain%
echo:
echo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM Information on running processes
echo Running Processes:
tasklist
echo:
echo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM Service information
echo Services:
tasklist/svc
echo:
echo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM Network configuration information
echo Network configuration:
ipconfig/all
echo:
echo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM Information about hosts on the same network
echo Hosts on same subnet:
arp -a
echo:
echo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM System configuration information
echo System configuration:
systeminfo
echo:
echo \\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
REM Directory and file information for key locations
echo Directories in C:\Users:
dir /b C:\Users
echo:
echo Contents of Hosts file:
type C:\Windows\System32\Drivers\etc\hosts
) > "enumeration-cmd output.txt"