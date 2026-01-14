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
RUN git clone https://aur.archlinux.org/mediamtx-bin.git \
 && cd mediamtx-bin \
 && makepkg -s \
 && mkdir /home/builder/pkg \
 && cp *.pkg.tar.zst /home/builder/pkg/

# Stage 2: Runtime image
FROM archlinux:latest

WORKDIR /app

# Create runtime user
RUN useradd -m obsuser

# copy built packages
COPY --from=aur-build /home/builder/pkg /tmp/pkg

# install Runtime dependencies
RUN pacman -U --noconfirm /tmp/pkg/*.pkg.tar.zst \
 && rm -rf /tmp/pkg \
 &&	pacman -Syu --noconfirm \
    supervisor \
    ffmpeg \
    mesa \
    python \
    xorg-server-xvfb \
    x11vnc \
	autossh \
 	chromium fontconfig freetype2 ttf-dejavu ttf-liberation noto-fonts \
 && pacman -Scc --noconfirm \
 && pacman -Rns --noconfirm $(pacman -Qdtq) || true \
 && rm -rf \
    /usr/share/man/* \
    /usr/share/doc/* \
    /usr/share/info/* \
    /usr/share/help/* \
    /var/cache/pacman/pkg/* \
 && find /usr/share/locale -mindepth 1 -maxdepth 1 ! -name 'en_US*' -exec rm -rf {} +

RUN LATEST_URL=$(curl -s https://api.github.com/repos/ivan-hc/OBS-Studio-appimage/releases/latest | \
    grep "browser_download_url.*full-x86_64.AppImage\"" | \
    cut -d '"' -f 4) && \
    curl -L -o obs "$LATEST_URL" && \
    chmod +x ./obs && \
	./obs --appimage-extract && \
	ln -s squashfs-root/AppRun /usr/bin/obs

# Copy backend, frontend, obs-config, mediamtx.sh, supervisord.conf
COPY ./backend/interscore-backend /app/backend
COPY frontend/ /home/obsuser/frontend/frontend/
COPY assets/ /home/obsuser/frontend/assets/
COPY docker/obs-config/ /home/obsuser/.config/obs-studio/
COPY ./docker/mediamtx.sh /usr/bin/mediamtx.sh
COPY docker/supervisord.conf /etc/supervisor.d/supervisord.conf
RUN mkdir -p /home/obsuser/.config/obs-studio/ \
 && chmod +x /app/backend \
 && chmod +x /usr/bin/mediamtx.sh \
 && chown -R obsuser:obsuser /home/obsuser/frontend \
 && chown -R obsuser:obsuser /home/obsuser/.config/obs-studio \
 && chmod -R 750 /home/obsuser/frontend \
 && chmod -R 700 /home/obsuser/.config/obs-studio

# Final runtime
USER root
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.d/supervisord.conf", "-n"]

