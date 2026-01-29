# We compile Typescript first
FROM ubuntu:24.04 AS builder
WORKDIR /build

RUN apt-get update && apt-get install -y \
    m4 curl bash ca-certificates libstdc++6 unzip \
 && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://bun.sh/install | bash

ENV PATH="/root/.bun/bin:$PATH"

COPY frontend/ frontend/
COPY assets/ assets/
COPY MessageType.m4 .

RUN m4 -DTS MessageType.m4 > frontend/MessageType.ts \
 && bun install --cwd frontend \
 && bun build frontend/script.ts --target browser --outdir ./frontend --minify

# Now the real image
FROM nginx:alpine

COPY --from=builder /build/ /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
