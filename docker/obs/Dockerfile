# Stage 1: Base GUI + noVNC + Xvfb
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV DEBIAN_PRIORITY=critical

# Install dependencies: OBS, GUI, Xvfb, audio, noVNC, basic utils
RUN apt-get update && apt-get install -y \
    software-properties-common \
    wget \
    curl \
    x11vnc \
    xvfb \
    novnc \
    websockify \
    ffmpeg \
    pulseaudio \
    dbus-x11 \
    ca-certificates \
    libgl1 \
    libglu1-mesa \
    libxcb-icccm4 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-xinerama0 \
    && add-apt-repository ppa:obsproject/obs-studio -y \
    && apt-get update && apt-get install -y obs-studio \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Optional: expose ports
EXPOSE 5900
EXPOSE 4444

WORKDIR /app

# Copy optional OBS config/scripts
RUN mkdir -p /root/.config/ \
 && mkdir -p /root/replays/
COPY docker-new/obs/obs-config/ /root/.config/obs-studio/

# Create virtual display and start OBS headless
CMD bash -c "\
    Xvfb :99 -screen 0 1920x1080x24 & \
	x11vnc -display :99 -nopw -listen 0.0.0.0 -forever -noxdamage -noshm -cursor arrow & \
    obs --startvirtualcam --collection radball --profile radball --scene live --websocket_port 4444 --startreplaybuffer --minimize-to-tray --disable-missing-files-check"

