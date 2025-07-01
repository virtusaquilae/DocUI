# Docker Desktop with Snap Support

This Docker container provides a Ubuntu 22.04 desktop environment with snap support enabled.

## Features

- Ubuntu 22.04 with XFCE desktop environment
- VNC server accessible via web browser (noVNC)
- Snap package manager fully functional
- Firefox browser pre-installed
- Systemd support for proper snap functionality

## Quick Start

1. Build and start the container:
   ```bash
   docker-compose up --build
   ```

2. Access the desktop via web browser:
   Open http://localhost:6080 in your browser

3. Login credentials:
   - Username: docker
   - Password: password (for VNC, if prompted)

## Testing Snap Functionality

Once the container is running, you can test snap functionality:

1. Open a terminal in the desktop environment
2. Run the test script:
   ```bash
   chmod +x test_snap.sh
   ./test_snap.sh
   ```

Or test manually:
```bash
# Check snap version
snap version

# Search for packages
snap find firefox

# Install a snap package
sudo snap install hello-world

# Run the installed snap
hello-world

# List installed snaps
snap list
```

## Common Snap Commands

- `snap find <package>` - Search for packages
- `sudo snap install <package>` - Install a package
- `snap list` - List installed packages
- `sudo snap remove <package>` - Remove a package
- `snap info <package>` - Get package information
- `snap refresh` - Update all installed snaps

## Important Notes

- The container runs with systemd as init process to support snap
- Snapd service starts automatically and may take a few seconds to be ready
- The container requires privileged mode and specific capabilities for snap to work
- All snap packages will be installed inside the container and won't persist unless you use volumes

## Troubleshooting

If snap commands don't work immediately:

1. Check if snapd is running:
   ```bash
   sudo systemctl status snapd.service
   ```

2. Wait for snapd to be fully ready:
   ```bash
   sudo systemctl start snapd.service
   sleep 10
   ```

3. If you get permission errors, make sure you're using `sudo` for install/remove operations

## Technical Details

The container uses:
- Ubuntu 22.04 base image
- Systemd as init process
- Privileged mode with SYS_ADMIN capability
- Proper cgroup and tmpfs mounts for systemd
- Snapd service enabled and configured
