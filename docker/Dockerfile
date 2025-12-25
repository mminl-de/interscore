# Stage 1: Build AUR packages
FROM archlinux:latest AS aur-build

# Base build deps
RUN pacman -Syu --noconfirm git base-devel

# Builder user
RUN useradd -m builder \
 	&& echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

# Install yay
RUN git clone https://aur.archlinux.org/yay-bin.git \
 && cd yay-bin \
 && makepkg -si --noconfirm

# Install AUR packages
RUN yay -Sy --noconfirm obs-studio-stable mediamtx-bin

# Stage 2: Runtime image
FROM archlinux:latest

# Runtime dependencies
RUN pacman -Syu --noconfirm \
    supervisor \
    ffmpeg \
    mesa \
    python \
    xorg-server-xvfb \
    x11vnc \
 && pacman -Scc --noconfirm

# Create runtime user
RUN useradd -m obsuser

# Set working directory
WORKDIR /app

# Copy only runtime files from build stage
COPY --from=aur-build /usr/bin/obs* /usr/bin/
COPY --from=aur-build /usr/lib/ /usr/lib/
# COPY --from=aur-build /usr/share/obs-studio/ /usr/share/obs/
# COPY --from=aur-build /usr/share/applications/ /usr/share/applications/

# Copy backend
COPY ./backend /app/backend
RUN chmod -R +x /app/backend

# Copy frontend / assets if needed
COPY frontend/ /home/obsuser/frontend/frontend/
COPY assets/ /home/obsuser/frontend/assets/
RUN chown -R obsuser:obsuser /home/obsuser/frontend \
 && chmod -R 750 /home/obsuser/frontend

# OBS config
RUN mkdir -p /home/obsuser/.config/obs-studio/
COPY docker/obs-config/ /home/obsuser/.config/obs-studio/
RUN chown -R obsuser:obsuser /home/obsuser/.config/obs-studio \
 && chmod -R 700 /home/obsuser/.config/obs-studio

# mediamtx helper script
COPY ./docker/mediamtx.sh /usr/bin/
RUN chmod +x /usr/bin/mediamtx.sh

# Supervisor config
COPY docker/supervisord.conf /etc/supervisor.d/supervisord.conf

# Final runtime
USER obsuser
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.d/supervisord.conf", "-n"]

