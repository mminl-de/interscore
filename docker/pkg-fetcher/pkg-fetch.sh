#!/bin/sh
# This script is only working with artix linux atm,
# for arch linux support we just need to change the appropriate pacman config repos
# later there will be a mode to toggle between arch and artix
set -e

# === CONFIG ===
CACHE_DIR="build-cache"
TARGET_PKG=${1:-obs-studio-tytan652}
TEMP_DIR=$(mktemp -d)
PACMAN_CONF="$TEMP_DIR/pacman.conf"
DB_DIR="$TEMP_DIR/db"

MIRRORLIST_CHAOTIC_PATH="etc/pacman.d/chaotic-mirrorlist"
MIRRORLIST_CHAOTIC="$TEMP_DIR/$MIRRORLIST_CHAOTIC_PATH"
MIRRORLIST_ARCH="$TEMP_DIR/etc/pacman.d/mirrorlist-arch"
MIRRORLIST_ARTIX="$TEMP_DIR/etc/pacman.d/mirrorlist"


CHAOTIC_PKG_MIRRORLIST_NAME="chaotic-mirrorlist.pkg.tar.zst"
CHAOTIC_PKG_MIRRORLIST_URL="https://cdn-mirror.chaotic.cx/chaotic-aur/$CHAOTIC_PKG_MIRRORLIST_NAME"
CHAOTIC_KEYRING_PKG_NAME="chaotic-keyring.pkg.tar.zst"
CHAOTIC_KEYRING_URL="https://cdn-mirror.chaotic.cx/chaotic-aur/$CHAOTIC_KEYRING_PKG_NAME"

echo "==> Creating Cache and Temp directories..."
mkdir -p "$CACHE_DIR.new"
mkdir -p "$CACHE_DIR"
mkdir -p "$DB_DIR"

echo "==> adding primary keys of Chaotic AUR to pacman"
pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
pacman-key --lsign-key 3056513887B78AEB

echo "==> Downloading Chaotic AUR mirrorlist package archives..."
curl -sSL -o "$CACHE_DIR.new/$CHAOTIC_PKG_MIRRORLIST_NAME" $CHAOTIC_PKG_MIRRORLIST_URL

echo "==> Extracting chaotix AUR mirrorlist..."
bsdtar -xf "$CACHE_DIR.new/$CHAOTIC_PKG_MIRRORLIST_NAME" -C "$TEMP_DIR" $MIRRORLIST_CHAOTIC_PATH

echo "==> Downloading Chaotic AUR keyring package archive..."
curl -sSL -o "$CACHE_DIR.new/$CHAOTIC_KEYRING_PKG_NAME" $CHAOTIC_KEYRING_URL

echo "==> Extracting chaotic AUR keyring..."
# Install the keyring
pacman -U --noconfirm "$CACHE_DIR.new/$CHAOTIC_KEYRING_PKG_NAME"

echo "==> Downloading Arch mirrorlist..."
curl -sSL -o "$MIRRORLIST_ARCH" https://archlinux.org/mirrorlist/all/
echo "==> Uncommenting all Arch mirror entries..."
sed -i 's/^#Server/Server/' "$MIRRORLIST_ARCH"

echo "==> Downloading Artix mirrorlist..."
curl -sSL -o "$MIRRORLIST_ARTIX" "https://gitea.artixlinux.org/packages/artix-mirrorlist/raw/branch/master/mirrorlist"

# === Create custom pacman.conf ===
echo "==> Creating custom pacman.conf..."
cat <<EOF > "$PACMAN_CONF"
[options]
CacheDir = $CACHE_DIR.new
Architecture = x86_64
SigLevel = Required DatabaseOptional
ParallelDownloads = 30

[chaotic-aur]
Include = $MIRRORLIST_CHAOTIC

[system]
Include = $MIRRORLIST_ARTIX

[world]
Include = $MIRRORLIST_ARTIX

[galaxy]
Include = $MIRRORLIST_ARTIX

[lib32]
Include = $MIRRORLIST_ARTIX

[extra]
Include = $MIRRORLIST_ARCH

[multilib]
Include = $MIRRORLIST_ARCH
EOF

echo "==> Initializing local DB and syncing package databases..."
pacman -Sy --config "$PACMAN_CONF" --dbpath "$DB_DIR"

echo "==> Downloading package: $TARGET_PKG and all dependencies..."
pacman -Sw --noconfirm --config "$PACMAN_CONF" --dbpath "$DB_DIR" "$TARGET_PKG"

echo "==> replacing old package cache with the new one..."
rm -f $CACHE_DIR/*
mv $CACHE_DIR.new/* $CACHE_DIR

# Optional cleanup
echo "==> Cleanup: removing CACHE_DIR.new and TEMP_DIR..."
rm -rf "$TEMP_DIR" "$CACHE_DIR.new"

echo "====> DONE --- FEEL FREE TO START THE DOCKER CONTAINER NOW!"
