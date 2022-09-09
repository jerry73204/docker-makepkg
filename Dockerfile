FROM archlinux:base-devel

# makepkg cannot (and should not) be run as root:
RUN useradd -m build && \
    pacman -Syu --noconfirm && \
    pacman -Sy --noconfirm git rsync && \
    # Allow build to run stuff as root (to install dependencies):
    echo "build ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/build

RUN sed -i 's/^COMPRESSZST=.*/COMPRESSZST=(zstd -T0 -c -z -q -)/' /etc/makepkg.conf && \
    sed -i 's/^#MAKEFLAGS=.*/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf


# Continue execution (and CMD) as build:
USER build
WORKDIR /home/build

# Auto-fetch GPG keys (for checking signatures):
RUN mkdir .gnupg && \
    touch .gnupg/gpg.conf && \
    echo "keyserver-options auto-key-retrieve" > .gnupg/gpg.conf && \
    git clone https://aur.archlinux.org/paru-bin.git && \
    cd paru-bin && \
    makepkg --noconfirm --syncdeps --rmdeps --install --clean

COPY run.sh /run.sh

# Build the package
WORKDIR /pkg
CMD ["/bin/bash", "/run.sh"]
