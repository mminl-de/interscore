FROM ubuntu:24.04

# OBS + Tools installieren
RUN apt-get update && apt-get install -y \
    xvfb \
    supervisor \
	libjson-c-dev \
	build-essential \
	nginx libnginx-mod-rtmp \
	ssh autossh \
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
    && rm -rf /var/lib/apt/lists/*

# Arbeitsverzeichnis
WORKDIR /app

# Backend reinkopieren
COPY backend .
RUN chmod +x /app/backend

#OBS User erstellen
RUN useradd -m obsuser && \
	mkdir /home/obsuser/.config/

# OBS reinkopieren
WORKDIR /home/obsuser
COPY obs /home/obsuser/
RUN chmod +x /home/obsuser/obs && \
	chown obsuser:obsuser /home/obsuser/obs
USER obsuser
RUN	/home/obsuser/obs --appimage-extract
USER root
RUN	ln -s /home/obsuser/squashfs-root/AppRun /usr/bin/obs


# OBS config reinkopieren
COPY obs-config/ /home/obsuser/.config/obs-studio/
RUN	chown -R obsuser:obsuser /home/obsuser/.config/ && \
	chmod -R 700 /home/obsuser/.config/

# Supervisor-Config reinkopieren
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Standard-Command
CMD ["/usr/bin/supervisord", "-n"]
