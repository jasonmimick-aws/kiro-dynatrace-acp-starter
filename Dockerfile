FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl unzip ca-certificates git jq && \
    rm -rf /var/lib/apt/lists/*

# Node.js 20 (for local MCP server fallback testing)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# AWS CLI v2
RUN curl -sSf "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o awscli.zip && \
    unzip -q awscli.zip && ./aws/install && rm -rf awscli.zip aws

# kiro-cli
RUN curl --proto '=https' --tlsv1.2 -sSf \
      "https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip" \
      -o kirocli.zip && \
    unzip -q kirocli.zip && ./kirocli/install.sh --force --no-confirm && rm -rf kirocli.zip kirocli

# dtctl — asset names include version, so we resolve via the API
RUN DTCTL_URL=$(curl -sL https://api.github.com/repos/dynatrace-oss/dtctl/releases/latest \
      | jq -r '.assets[] | select(.name | test("linux_amd64.tar.gz$")) | .browser_download_url') && \
    curl -sSfL "$DTCTL_URL" | tar xz -C /usr/local/bin dtctl

WORKDIR /workspace
COPY . /workspace/

ENV PATH="/root/.local/bin:${PATH}"

ENTRYPOINT ["/bin/bash"]
