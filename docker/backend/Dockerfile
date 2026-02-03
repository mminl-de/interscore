# We build backend here, because of GLIBC version mismatches etc
FROM debian:12-slim AS build

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    build-essential \
	libssl-dev \
	libjson-c-dev \
	m4 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY backend/ backend/
COPY MessageType.m4 .

RUN m4 -DTS MessageType.m4 > MessageType.ts \
 && cd backend/ \
 && make install

# Now the real image
FROM debian:12-slim

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    libjson-c5 \
	libssl3 \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY --from=build /build/backend/interscore-backend /app/backend

EXPOSE 8081
USER nobody
ENTRYPOINT ["/app/backend", "--url-obs", "http://172.28.0.10:4444"]
