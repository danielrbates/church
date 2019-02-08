function create-fwrules {
    Set-NetFirewallRule -DisplayName "Block Wireless" -InterfaceType Wireless -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "Block TFTP src" -Protocol UDP -LocalPort 69 -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "Block TFTP dest" -Protocol UDP -RemotePort 69 -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "Block DNS-UDP" -Protocol UDP -RemotePort 53 -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "Block DNS-TCP" -Protocol TCP -RemotePort 53 -Direction Outbound -Action Block
    Set-NetFirewallRule -DisplayName "Block Application" -Program "path\path\executable.exe" -Direction Outbound -Action Block
    }

function delete-fwrules {
    Remove-NetFirewallRule -DisplayName "Block Wireless"
    Remove-NetFirewallRule -DisplayName "Block TFTP src"
    Remove-NetFirewallRule -DisplayName "Block TFTP dest"
    Remove-NetFirewallRule -DisplayName "Block DNS-UDP"
    Remove-NetFirewallRule -DisplayName "Block DNS-TCP"
    Remove-NetFirewallRule -DisplayName "Block Application"
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
