FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV USER=docker
ENV HOME=/home/docker

# Install basic tools + XFCE + VNC + noVNC + browser
RUN apt-get update && apt-get install -y \
    xfce4 xfce4-goodies tightvncserver \
    novnc websockify tigervnc-standalone-server\
    firefox wget curl supervisor sudo xterm dbus-x11 \
    pulseaudio pulseaudio-utils \
    xfce4-session xfce4-settings \
    policykit-1-gnome \
    at-spi2-core && \
    apt-get clean

# Create non-root user with passwordless sudo
RUN useradd -m -s /bin/bash docker && echo "docker:docker" | chpasswd && adduser docker sudo && \
    echo "docker ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set up environment
USER docker
WORKDIR /home/docker
COPY --chown=docker:docker start.sh /home/docker/start.sh
RUN chmod +x /home/docker/start.sh

EXPOSE 6080 5901

CMD ["/home/docker/start.sh"]
