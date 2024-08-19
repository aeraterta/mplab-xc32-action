FROM ubuntu:20.04

ARG MPLABX_VERSION=6.20
ARG X32_VERSION=4.45
ARG DFP_PACKS=""

# Set non-interactive mode for tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary dependencies and sudo
RUN apt-get update -qq && apt-get install -y -qq \
    wget \
    tar \
    libusb-1.0-0 \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Create a non-root user and add to the sudoers file
RUN useradd -ms /bin/bash devuser && echo "devuser:devpassword" | chpasswd && \
    echo "devuser ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/devuser

# Switch to the non-root user
USER devuser
WORKDIR /home/devuser

# Download and install MPLAB X IDE
RUN wget -q --referer="https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide" \
    -O /tmp/MPLABX-v${MPLABX_VERSION}-linux-installer.tar \
    https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/MPLABX-v${MPLABX_VERSION}-linux-inst
