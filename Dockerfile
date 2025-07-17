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

# Install Firefox from Mozilla's official repository (since snap doesn't work in containers)
# First remove the snap transitional package
RUN apt-get remove -y firefox && \
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | gpg --dearmor -o /usr/share/keyrings/packages.mozilla.org.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/packages.mozilla.org.gpg] https://packages.mozilla.org/apt mozilla main" | tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null && \
    echo 'Package: *' > /etc/apt/preferences.d/mozilla && \
    echo 'Pin: origin packages.mozilla.org' >> /etc/apt/preferences.d/mozilla && \
    echo 'Pin-Priority: 1000' >> /etc/apt/preferences.d/mozilla && \
    apt-get update && \
    apt-get install -y firefox && \
    apt-get clean

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
