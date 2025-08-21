FROM ubuntu:24.04

# OBS + Tools installieren
RUN apt-get update && apt-get install -y \
    xvfb \
    supervisor \
	libjson-c-dev \
	build-essential \
    && rm -rf /var/lib/apt/lists/*

# Arbeitsverzeichnis
WORKDIR /app

# Deinen WebSocket-Server reinkopieren
COPY backend .
RUN chmod +x /app/backend

# Deinen WebSocket-Server reinkopieren
COPY obs .
RUN /app/obs --appimage-extract && \
    mv squashfs-root /app/obs-root
RUN chmod +x /app/obs

# Supervisor-Config reinkopieren
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Standard-Command
CMD ["/usr/bin/supervisord", "-n"]
