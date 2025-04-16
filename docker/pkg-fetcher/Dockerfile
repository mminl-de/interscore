FROM artixlinux/artixlinux:base

RUN pacman -Syu --noconfirm curl libarchive && pacman -Scc --noconfirm && pacman-key --init

WORKDIR /workspace

COPY pkg-fetch.sh /usr/local/bin/fetch.sh
RUN chmod +x /usr/local/bin/fetch.sh

ENTRYPOINT ["/usr/local/bin/fetch.sh"]
