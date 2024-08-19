FROM ubuntu:20.04

ARG MPLABX_VERSION=6.20
ARG X32_VERSION=4.45
ARG DFP_PACKS=""

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    libx11-dev \
    libxtst-dev \
    libxext-dev \
    libxi-dev \
    libgtk-3-dev \
    && rm -rf /var/lib/apt/lists/*

# Download and install MPLAB X IDE
RUN wget --referer="https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide" \
    -O /tmp/MPLABX-v6.20-linux-installer.tar \
    https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/MPLABX-v6.20-linux-installer.tar && \
    cd /tmp && \
    tar -xvf MPLABX-v6.20-linux-installer.tar && \
    cd mplabx-installer && \
    ./install.sh --mode silent && \
    rm -rf /tmp/MPLABX-v6.20-linux-installer.tar /tmp/mplabx-installer

# Download and install XC32 compiler
RUN wget -O /tmp/xc32-v4.45-full-install-linux-x64-installer.run \
    <YOUR_HOSTED_LINK_FOR_XC32> && \
    chmod +x /tmp/xc32-v4.45-full-install-linux-x64-installer.run && \
    /tmp/xc32-v4.45-full-install-linux-x64-installer.run --mode silent

# Install DFPs
RUN if [ -n "$DFP_PACKS" ]; then \
    echo "Installing DFPs: $DFP_PACKS"; \
    chmod +x /opt/mplabx/mplab_platform/bin/packmanagercli.sh; \
    for pack in $(echo $DFP_PACKS | tr "," "\n"); do \
        IFS="=" read -r pack_name pack_version <<< "$pack"; \
        /opt/mplabx/mplab_platform/bin/packmanagercli.sh --install-pack "$pack_name" --version "$pack_version"; \
    done; \
fi

# Copy build script
COPY build.sh /build.sh

# Make the build script executable
RUN chmod +x /build.sh

# Set the entry point to the build script
ENTRYPOINT ["/build.sh"]
