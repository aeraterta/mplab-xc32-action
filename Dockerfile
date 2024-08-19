FROM ubuntu:20.04

ARG MPLABX_VERSION=6.20
ARG X32_VERSION=4.45
ARG DFP_PACKS=""

# Set non-interactive mode for tzdata
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    wget \
    tar \
    libx11-dev \
    libxtst-dev \
    libxext-dev \
    libxi-dev \
    libgtk-3-dev \
    tzdata \
    && rm -rf /var/lib/apt/lists/*

# Download and install MPLAB X IDE
RUN wget --referer="https://www.microchip.com/en-us/tools-resources/develop/mplab-x-ide" \
    -O /tmp/MPLABX-v${MPLABX_VERSION}-linux-installer.tar \
    https://ww1.microchip.com/downloads/aemDocuments/documents/DEV/ProductDocuments/SoftwareTools/MPLABX-v${MPLABX_VERSION}-linux-installer.tar && \
    cd /tmp && \
    tar -xf MPLABX-v${MPLABX_VERSION}-linux-installer.tar && \
    mv "MPLABX-v${MPLABX_VERSION}-linux-installer.sh" mplabx && \
    chmod +x mplabx && \
    sudo ./mplabx -- --unattendedmodeui none --mode unattended --ipe 0 --collectInfo 0 --installdir /opt/mplabx --16bitmcu 0 --32bitmcu 1 --othermcu 0 && \
    rm mplabx

# Download and install XC32 compiler
RUN wget -O /tmp/xc32-v${X32_VERSION}-full-install-linux-x64-installer.run \
    <YOUR_HOSTED_LINK_FOR_XC32> && \
    chmod +x /tmp/xc32-v${X32_VERSION}-full-install-linux-x64-installer.run && \
    /tmp/xc32-v${X32_VERSION}-full-install-linux-x64-installer.run --mode silent

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
