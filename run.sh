#!/bin/bash

set -e

# Save and change the owner of /build
orig_owner=$(stat -c '%u:%g' /build)
sudo chown -R $(id -u):$(id -g) /build

# Make a copy so we never alter the original
rsync -a --delete /pkg/ /build
cd /build

# Sync database
paru -S --refresh

# Do the actual building. Paru will fetch all dependencies for us (including
# AUR dependencies) and then build the package.
paru -U --noconfirm

# Export .SRCINFO for built package
makepkg --printsrcinfo > .SRCINFO

# Restore the owner of /build
chown -R $orig_owner /build
