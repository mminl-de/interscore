#!/bin/sh

MSYS2_ROOT_64="$HOME/prg/interscore/win-pacman/msys2-root/mingw64"
MSYS2_ROOT_32="$HOME/prg/interscore/win-pacman/msys2-root/mingw32"
MINGW_SYSROOT_64="/usr/x86_64-w64-mingw32"
MINGW_SYSROOT_32="/usr/i686-w64-mingw32"

sudo cp -r "$MSYS2_ROOT_64/include/"* "$MINGW_SYSROOT_64/include/"
sudo cp -r "$MSYS2_ROOT_64/lib/"*.a "$MINGW_SYSROOT_64/lib/"
sudo cp -r "$MSYS2_ROOT_64/qt6-static/"*.a "$MINGW_SYSROOT_64/qt6-static/"

sudo cp -r "$MSYS2_ROOT_32/include/"* "$MINGW_SYSROOT_32/include/"
sudo cp -r "$MSYS2_ROOT_32/lib/"*.a "$MINGW_SYSROOT_32/lib/"
