FROM archlinux:latest

RUN useradd -m builder

#OBS User erstellen
RUN useradd -m obsuser && \
	mkdir /home/obsuser/.config/

# OBS + Tools installieren
RUN pacman -Sy --noconfirm \
	x11vnc \
    xorg-server-xvfb \
    supervisor \
	json-c \
	base-devel \
	openssh autossh \
    xz \
    mesa \
	python \
	ddclient \
	tar \
	ffmpeg \
	git \
	wget \
	pcre geoip mailcap mercurial perl-gd perl-io-socket-ssl perl-fcgi perl-cache-memcached memcached inetutils \
    && pacman -Scc --noconfirm

# deps for nginx-rmtp

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/nginx-rtmp.git \
	&& cd nginx-rtmp \
	&& makepkg --noconfirm --skippgpcheck --nocheck

USER root
RUN pacman -U --noconfirm /home/builder/nginx-rtmp/nginx-rtmp-[0-9]*.pkg.tar.zst
# Arbeitsverzeichnis
WORKDIR /app
RUN rm -rf /home/builder

# mediamtx binary herunterladen
RUN wget "https://github.com/bluenviron/mediamtx/releases/download/v1.15.3/mediamtx_v1.15.3_linux_amd64.tar.gz" && \
	tar -xzvf mediamtx_v1.15.3_linux_amd64.tar.gz && \
	mv mediamtx /usr/bin/
# mediamtx.sh reinkopieren
COPY ./docker/mediamtx.sh /usr/bin/
RUN chmod +x /usr/bin/mediamtx.sh

# ddclient.sh reinkopieren
# RUN mkdir -p /etc/ddclient/
# COPY ./docker/ddclient.conf /etc/ddclient/ddclient.conf

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
RUN	chown -R obsuser:obsuser /home/obsuser/frontend/ && \
	chmod -R 700 /home/obsuser/frontend/

# Backend reinkopieren
COPY ./backend /app/
RUN chmod +x /app/backend

# Supervisor-Config reinkopieren
COPY docker/supervisord.conf /etc/supervisor.d/supervisord.conf

# Standard-Command
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor.d/supervisord.conf", "-n"]
