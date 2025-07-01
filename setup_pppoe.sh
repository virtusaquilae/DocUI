#!/bin/bash

echo "PPPoE Connection Setup Script"
echo "============================="

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   echo "This script should be run as the regular user (eagle), not root."
   echo "Run with: ./setup_pppoe.sh"
   exit 1
fi

echo "Setting up PPPoE connection..."

echo ""
echo "Available network interfaces:"
ip link show | grep -E '^[0-9]+:' | cut -d: -f2 | sed 's/^ *//'

echo ""
echo "Choose your setup method:"
echo "1. GUI Configuration (recommended)"
echo "2. Command-line configuration"
echo "3. Manual pppoeconf"

read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        echo "Starting Network Manager GUI..."
        echo "To configure PPPoE:"
        echo "1. Click on the network icon in the system tray"
        echo "2. Go to 'Edit Connections' or 'Network Settings'"
        echo "3. Click 'Add' to create a new connection"
        echo "4. Select 'DSL/PPPoE' as connection type"
        echo "5. Enter your ISP username and password"
        echo "6. Select the appropriate ethernet interface"
        echo "7. Save and activate the connection"
        nm-connection-editor &
        ;;
    2)
        echo "Command-line PPPoE setup:"
        read -p "Enter your ISP username: " username
        read -s -p "Enter your ISP password: " password
        echo ""
        read -p "Enter ethernet interface (e.g., eth0, enp0s3): " interface
        
        echo "Creating PPPoE connection..."
        sudo nmcli connection add type pppoe con-name "PPPoE Connection" \
            ifname ppp0 \
            pppoe.parent $interface \
            username "$username" \
            password "$password"
        
        echo "Activating PPPoE connection..."
        sudo nmcli connection up "PPPoE Connection"
        ;;
    3)
        echo "Running pppoeconf for manual configuration..."
        echo "This will guide you through the setup process."
        sudo pppoeconf
        ;;
    *)
        echo "Invalid choice. Exiting."
        exit 1
        ;;
esac

echo ""
echo "Setup complete!"
echo "You can check connection status with:"
echo "  nmcli connection show"
echo "  ip addr show"
echo "  ping google.com"
echo ""
echo "To start/stop the connection manually:"
echo "  sudo nmcli connection up 'PPPoE Connection'"
echo "  sudo nmcli connection down 'PPPoE Connection'"
