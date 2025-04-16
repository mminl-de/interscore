FROM ubuntu:22.04

# Install dependencies for AppImage + X11
RUN apt update && apt install -y \
    wget \
    xz-utils \
    libglu1-mesa \
    libxcb-xinerama0 \
    libx11-xcb1 \
    libnss3 \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxrandr2 \
    libxtst6 \
    libgtk-3-0 \
    pulseaudio \
    xvfb \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Download latest OBS AppImage
WORKDIR /opt/obs
RUN wget -q https://github.com/ivan-hc/OBS-Studio-appimage/releases/download/continuous/OBS-Studio_31.0.3-1-archimage4.3-x86_64.AppImage \
    -O obs.AppImage && \
    chmod +x obs.AppImage && \
    ./obs.AppImage --appimage-extract && \
    ln -s /opt/obs/squashfs-root/AppRun /usr/local/bin/obs

# Copy your OBS config
COPY obs-config/ /root/.config/obs-studio/

# Environment for headless X
ENV DISPLAY=:99

# Start everything
CMD bash -c "\
    Xvfb :99 -screen 0 1920x1080x24 & \
    sleep 3 && \
    obs --disable-shutdown-check \
        --collection radball.json \
        --profile radball \
        --scene live \
        --websocket_port 4444"
