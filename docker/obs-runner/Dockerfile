FROM artixlinux/artixlinux:base

# Set env
ENV DISPLAY=:99

# Install cached packages
RUN pacman -U --noconfirm /build-cache/*.pkg.tar.zst

# Create a user to run as non-root
RUN useradd -m obsuser

# Copy in OBS config (mountable as volume in the future)
COPY obs-config/ /home/obsuser/.config/obs-studio/

# Switch to user
USER obsuser
WORKDIR /home/obsuser

# Start OBS headless
CMD Xvfb :99 -screen 0 1920x1080x24 & \
    sleep 3 && \
    obs --collection radball.json \
        --profile radball \
        --scene live \
        --websocket_port 4444
