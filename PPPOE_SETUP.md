# PPPoE Setup Instructions

This Docker container now includes support for PPPoE (Point-to-Point Protocol over Ethernet) connections, commonly used for DSL internet connections.

## Prerequisites

1. Your host system must have a physical ethernet interface connected to your DSL modem
2. The container runs with `privileged` mode and `network_mode: host` for network access
3. You need your ISP's PPPoE credentials (username and password)

## Building and Running

1. Build the container:
   ```bash
   docker-compose build
   ```

2. Start the container:
   ```bash
   docker-compose up -d
   ```

3. Access the desktop via web browser:
   ```
   http://localhost:6080
   ```

## Setting Up PPPoE Connection

### Method 1: Desktop Shortcut (Recommended)
1. Once logged into the desktop, you'll find a "PPPoE Setup" icon on the desktop
2. Double-click it to launch the setup wizard
3. Choose option 1 for GUI configuration
4. Follow the Network Manager GUI to configure your connection

### Method 2: Command Line
1. Open a terminal in the desktop environment
2. Run: `./setup_pppoe.sh`
3. Choose option 2 for command-line setup
4. Enter your ISP credentials and ethernet interface

### Method 3: Manual Configuration
1. Open Network Manager: Click on the network icon in the system tray
2. Go to "Edit Connections" or "Network Settings"
3. Click "Add" to create a new connection
4. Select "DSL/PPPoE" as connection type
5. Configure:
   - Connection name: (e.g., "My DSL Connection")
   - Username: Your ISP username
   - Password: Your ISP password
   - Service: (usually leave blank)
   - Parent interface: Select your ethernet interface (e.g., eth0, enp0s3)
6. Save and activate the connection

## Troubleshooting

### Check Available Network Interfaces
```bash
ip link show
nmcli device status
```

### Check Connection Status
```bash
nmcli connection show
ip addr show ppp0
ping google.com
```

### Start/Stop PPPoE Connection
```bash
# Start connection
sudo nmcli connection up "PPPoE Connection"

# Stop connection
sudo nmcli connection down "PPPoE Connection"
```

### View Connection Logs
```bash
sudo journalctl -u NetworkManager -f
tail -f /var/log/syslog | grep ppp
```

### Common Issues

1. **No network interfaces visible**: Make sure the container is running with `privileged: true` and `network_mode: host`

2. **Authentication failed**: Double-check your ISP username and password

3. **Cannot connect**: Ensure your ethernet cable is connected to the DSL modem and the modem is configured for PPPoE mode

4. **DNS issues**: PPPoE should automatically configure DNS, but you can manually set DNS servers in the connection settings if needed

## Additional Tools

The container includes these networking tools:
- `pppoeconf`: Interactive PPPoE configuration
- `nmcli`: Command-line Network Manager
- `nm-connection-editor`: GUI Network Manager
- `pon/poff`: Start/stop PPP connections
- Standard network tools: `ping`, `traceroute`, `nslookup`, etc.

## Security Notes

- The container runs in privileged mode to access network interfaces
- PPPoE credentials are stored in Network Manager connection files
- Consider using encrypted storage for sensitive connection information

## Getting Help

If you encounter issues:
1. Check the container logs: `docker-compose logs`
2. Verify your DSL modem configuration
3. Contact your ISP for correct PPPoE settings
4. Check network interface names with `ip link show`
