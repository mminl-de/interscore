FROM ubuntu:24.04

# OBS + Tools installieren
RUN apt-get update && apt-get install -y \
	x11vnc \
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
	python3 \
	ddclient \
	tar \
	ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Arbeitsverzeichnis
WORKDIR /app

#OBS User erstellen
RUN useradd -m obsuser && \
	mkdir /home/obsuser/.config/

# mediamtx binary herunterladen
RUN wget "https://github.com/bluenviron/mediamtx/releases/download/v1.15.3/mediamtx_v1.15.3_linux_amd64.tar.gz" && \
	tar -xzvf mediamtx_v1.15.3_linux_amd64.tar.gz && \
	mv mediamtx /usr/bin/
# mediamtx.sh reinkopieren
COPY ./docker/mediamtx.sh /usr/bin/
RUN chmod +x /usr/bin/mediamtx.sh

# ddclient.sh reinkopieren
RUN mkdir -p /etc/ddclient/
COPY ./docker/ddclient.conf /etc/ddclient/ddclient.conf

# OBS reinkopieren
WORKDIR /home/obsuser
COPY docker/obs /home/obsuser/
RUN chmod +x /home/obsuser/obs && \
	chown obsuser:obsuser /home/obsuser/obs
USER obsuser
RUN	/home/obsuser/obs --appimage-extract
RUN mkdir -p /home/obsuser/replays
USER root
RUN	ln -s /home/obsuser/squashfs-root/AppRun /usr/bin/obs

# OBS config reinkopieren
COPY docker/obs-config/ /home/obsuser/.config/obs-studio/
RUN	chown -R obsuser:obsuser /home/obsuser/.config/ && \
	chmod -R 700 /home/obsuser/.config/

# frontend reinkopieren
RUN mkdir -p /home/obsuser/frontend/
COPY frontend/ /home/obsuser/frontend/frontend/
COPY assets/ /home/obsuser/frontend/assets/
COPY MessageType.js /home/obsuser/frontend/MessageType.js
RUN	chown -R obsuser:obsuser /home/obsuser/frontend/ && \
	chmod -R 700 /home/obsuser/frontend/

# Backend reinkopieren
COPY ./backend /app/
RUN chmod +x /app/backend

# Supervisor-Config reinkopieren
COPY docker/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Standard-Command
CMD ["/usr/bin/supervisord", "-n"]
