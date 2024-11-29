FROM debian:11-slim

RUN apt-get update && apt-get install -y \
  curl \
  gnupg \
  lsb-release \
  wget \
  tar \
  && rm -rf /var/lib/apt/lists/*

# Install TinyPortMapper
RUN wget https://github.com/wangyu-/tinyPortMapper/releases/download/20200818.0/tinymapper_binaries.tar.gz && \
  tar -xzf tinymapper_binaries.tar.gz && \
  chmod +x tinymapper_amd64 && \
  mv tinymapper_amd64 /usr/local/bin/tinymapper && \
  rm tinymapper_binaries.tar.gz

# Add Cloudflare repository with correct URL and key
RUN mkdir -p --mode=0755 /usr/share/keyrings \
  && curl -fsSL https://pkg.cloudflareclient.com/pubkey.gpg | gpg --yes --dearmor --output /usr/share/keyrings/cloudflare-warp-archive-keyring.gpg \
  && echo "deb [signed-by=/usr/share/keyrings/cloudflare-warp-archive-keyring.gpg] https://pkg.cloudflareclient.com/ $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/cloudflare-client.list

# Install WARP client with correct package name
RUN apt-get update && apt-get install -y cloudflare-warp \
  && rm -rf /var/lib/apt/lists/*

# Entrypoint script for WARP initialization
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
