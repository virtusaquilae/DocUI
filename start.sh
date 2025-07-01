#!/bin/bash

echo "Starting desktop environment..."

# Start system D-Bus daemon
sudo mkdir -p /var/run/dbus
sudo dbus-daemon --system --fork --print-pid --print-address

# Start session D-Bus for current user
eval $(dbus-launch --sh-syntax)

# Start NetworkManager for PPPoE support
sudo systemctl start NetworkManager 2>/dev/null || echo "NetworkManager failed to start or already running"

# PulseAudio setup with better error handling
pulseaudio --start --exit-idle-time=-1 --daemon 2>/dev/null || echo "PulseAudio already running or failed to start"

# Fix X11 socket permissions for VNC
sudo mkdir -p /tmp/.X11-unix
sudo chmod 1777 /tmp/.X11-unix

# Clean up any existing VNC sessions
vncserver -kill :1 2>/dev/null || true
vncserver -kill :2 2>/dev/null || true
sleep 2

# Remove any stale X11 locks
sudo rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true

# Setup VNC
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup << 'EOF'
#!/bin/bash
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XKL_XMODMAP_DISABLE=1
export XDG_CURRENT_DESKTOP="XFCE"
export XDG_SESSION_DESKTOP="XFCE"

# Start D-Bus
eval `dbus-launch --sh-syntax`

# Start XFCE4
exec startxfce4
EOF
chmod +x ~/.vnc/xstartup
echo "===== ~/.vnc/xstartup contents ====="
cat ~/.vnc/xstartup
echo "===== END ~/.vnc/xstartup contents ====="

# Print user and home for debugging
echo "Current user: $(whoami)"
echo "Home directory: $HOME"

# Set up VNC password (using the user's specified password)
echo -e "virtusaquilae\nvirtusaquilae\nn" | vncpasswd

vncserver -list

# Start VNC with specific resolution
vncserver :1 -geometry 1920x1080 -depth 24 -localhost no

# Wait a moment for VNC to fully start
sleep 3

# Check if VNC started successfully
if ! vncserver -list | grep -q ":1"; then
    echo "VNC server failed to start, trying again..."
    vncserver -kill :1 2>/dev/null || true
    sudo rm -f /tmp/.X1-lock /tmp/.X11-unix/X1 2>/dev/null || true
    sleep 2
    vncserver :1 -geometry 1920x1080 -depth 24 -localhost no
    sleep 3
fi

# List .vnc directory contents for debugging
echo "===== ~/.vnc directory contents ====="
ls -l ~/.vnc
echo "===== END ~/.vnc directory contents ====="

# Show VNC logs for debugging
echo "\n===== VNC LOGS ====="
cat ~/.vnc/*.log || echo "No VNC log found."
echo "===== END VNC LOGS =====\n"

# Start noVNC
websockify --web=/usr/share/novnc/ --wrap-mode=ignore 6080 localhost:5901

