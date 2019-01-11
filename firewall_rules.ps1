function create-fwrules {
    Set-NetFirewallRule -DisplayName "CTF Block Wireless" -InterfaceType Wireless -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "CTF Block TFTP src" -Protocol UDP -LocalPort 69 -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "CTF Block TFTP dest" -Protocol UDP -RemotePort 69 -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "CTF Block DNS-UDP" -Protocol UDP -RemotePort 53 -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "CTF Block DNS-TCP" -Protocol TCP -RemotePort 53 -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "CTF Block Skype" -Program "c:\program files\skype\phone\skype.exe" -Direction Outbound -Action Block
    }

function delete-fwrules {
    Remove-NetFirewallRule -DisplayName "CTF Block Wireless"
    Remove-NetFirewallRule -DisplayName "CTF Block TFTP src"
    Remove-NetFirewallRule -DisplayName "CTF Block TFTP dest"
    Remove-NetFirewallRule -DisplayName "CTF Block DNS-UDP"
    Remove-NetFirewallRule -DisplayName "CTF Block DNS-TCP"
    Remove-NetFirewallRule -DisplayName "CTF Block Skype"
    }

function main {
    while ($true) {
        #echo "creating rules"
        create-fwrules
        start-sleep -Seconds 60
        #echo "deleting rules"
        delete-fwrules
        start-sleep -Seconds 60
        }
    }