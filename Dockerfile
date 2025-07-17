FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=eagle
ENV HOME=/home/eagle
ENV container=docker

# Install systemd and enable it
RUN apt-get update && apt-get install -y systemd systemd-sysv

# Install basic tools + XFCE + VNC + noVNC
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies tightvncserver \
    novnc websockify tigervnc-standalone-server\
    wget curl supervisor sudo xterm dbus-x11 \
    pulseaudio pulseaudio-utils \
    xfce4-session xfce4-settings \
    policykit-1-gnome \
    at-spi2-core \
    net-tools iputils-ping dnsutils \
    ca-certificates software-properties-common \
    gnupg lsb-release && \
    apt-get clean

# Configure systemd for container use
RUN systemctl set-default multi-user.target && \
    systemctl mask \
        dev-hugepages.mount \
        sys-fs-fuse-connections.mount \
        sys-kernel-config.mount \
        display-manager.service \
        getty@.service \
        systemd-logind.service \
        systemd-remount-fs.service \
        getty.target \
        graphical.target \
        systemd-udev-trigger.service \
        systemd-udevd.service \
        systemd-random-seed.service \
        systemd-machine-id-commit.service && \
    systemctl disable systemd-resolved

# Install Firefox and Google Chrome
RUN apt-get update && apt-get install -y firefox && \
    apt-get clean

# Install Google Chrome using curl with better error handling
RUN curl -fsSL -o /tmp/google-chrome-stable_current_amd64.deb https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get update && \
    apt-get install -y /tmp/google-chrome-stable_current_amd64.deb || apt-get install -f -y && \
    rm -f /tmp/google-chrome-stable_current_amd64.deb && \
    apt-get clean

# Install additional dependencies for Chrome
RUN apt-get update && apt-get install -y \
    fonts-liberation \
    libappindicator3-1 \
    libasound2 \
    libatk-bridge2.0-0 \
    libdrm2 \
    libgtk-3-0 \
    libnspr4 \
    libnss3 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    xdg-utils && \
    apt-get clean

# Create Chrome wrapper script for container environment
RUN echo '#!/bin/bash' > /usr/local/bin/chrome && \
    echo 'exec /usr/bin/google-chrome-stable --no-sandbox --disable-dev-shm-usage --disable-gpu --remote-debugging-port=9222 "$@"' >> /usr/local/bin/chrome && \
    chmod +x /usr/local/bin/chrome

# Create desktop entry for Chrome
RUN mkdir -p /usr/share/applications && \
    echo '[Desktop Entry]' > /usr/share/applications/google-chrome.desktop && \
    echo 'Version=1.0' >> /usr/share/applications/google-chrome.desktop && \
    echo 'Name=Google Chrome' >> /usr/share/applications/google-chrome.desktop && \
    echo 'Comment=Access the Internet' >> /usr/share/applications/google-chrome.desktop && \
    echo 'GenericName=Web Browser' >> /usr/share/applications/google-chrome.desktop && \
    echo 'Keywords=Internet;WWW;Browser;Web;Explorer' >> /usr/share/applications/google-chrome.desktop && \
    echo 'Exec=/usr/local/bin/chrome %U' >> /usr/share/applications/google-chrome.desktop && \
    echo 'Terminal=false' >> /usr/share/applications/google-chrome.desktop && \
    echo 'Icon=google-chrome' >> /usr/share/applications/google-chrome.desktop && \
    echo 'Type=Application' >> /usr/share/applications/google-chrome.desktop && \
    echo 'Categories=Network;WebBrowser;' >> /usr/share/applications/google-chrome.desktop && \
    echo 'MimeType=text/html;text/xml;application/xhtml+xml;' >> /usr/share/applications/google-chrome.desktop && \
    chmod +x /usr/share/applications/google-chrome.desktop

# Create non-root user with passwordless sudo
RUN useradd -m -s /bin/bash eagle && echo "eagle:virtusaquilae" | chpasswd && adduser eagle sudo && \
    echo "eagle ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Note: snapd doesn't work reliably in containers, using apt packages instead

# Set up environment
USER eagle
WORKDIR /home/eagle
COPY --chown=eagle:eagle start.sh /home/eagle/start.sh
RUN chmod +x /home/eagle/start.sh

# Create a systemd service for our desktop environment
USER root
RUN echo '[Unit]' > /etc/systemd/system/desktop-environment.service && \
    echo 'Description=Desktop Environment Service' >> /etc/systemd/system/desktop-environment.service && \
    echo 'After=multi-user.target' >> /etc/systemd/system/desktop-environment.service && \
    echo 'Conflicts=getty@tty1.service' >> /etc/systemd/system/desktop-environment.service && \
    echo '' >> /etc/systemd/system/desktop-environment.service && \
    echo '[Service]' >> /etc/systemd/system/desktop-environment.service && \
    echo 'Type=simple' >> /etc/systemd/system/desktop-environment.service && \
    echo 'User=eagle' >> /etc/systemd/system/desktop-environment.service && \
    echo 'Group=eagle' >> /etc/systemd/system/desktop-environment.service && \
    echo 'WorkingDirectory=/home/eagle' >> /etc/systemd/system/desktop-environment.service && \
    echo 'ExecStart=/home/eagle/start.sh' >> /etc/systemd/system/desktop-environment.service && \
    echo 'Restart=always' >> /etc/systemd/system/desktop-environment.service && \
    echo 'RestartSec=10' >> /etc/systemd/system/desktop-environment.service && \
    echo 'StandardOutput=journal' >> /etc/systemd/system/desktop-environment.service && \
    echo 'StandardError=journal' >> /etc/systemd/system/desktop-environment.service && \
    echo '' >> /etc/systemd/system/desktop-environment.service && \
    echo '[Install]' >> /etc/systemd/system/desktop-environment.service && \
    echo 'WantedBy=multi-user.target' >> /etc/systemd/system/desktop-environment.service

RUN systemctl enable desktop-environment.service

USER eagle

EXPOSE 6080 5901

# Use our custom start script that manually starts snapd
CMD ["/home/eagle/start.sh"]
