# syntax=docker/dockerfile:1.7
FROM base_image

ARG PIP_MIRROR
ARG DEBIAN_MIRROR
ARG TARGETARCH

ARG SEMGREP_VERSION=1.67.0
ARG GITLEAKS_VERSION=8.21.2
ARG TRIVY_VERSION=0.58.2
ARG SYFT_VERSION=1.18.1
ARG COSIGN_VERSION=2.4.1

USER root

# ── System deps ──
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked \
    apt-get update \
 && apt-get install -y --no-install-recommends wget ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# ── Semgrep (pip, amd64 only) ──
COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/root/.cache/pip \
    if [ "$TARGETARCH" = "amd64" ]; then \
      pip install --no-cache-dir \
        --index-url "${PIP_MIRROR}" \
        -r /tmp/requirements.txt; \
    else \
      echo "WARN: Semgrep skipped on $TARGETARCH" >&2; \
    fi \
 && rm -f /tmp/requirements.txt

# ── Gitleaks ──
RUN ARCH=$(case "$TARGETARCH" in amd64) echo x64;; arm64) echo arm64;; esac) \
 && wget -qO /tmp/gitleaks.tar.gz \
      "https://github.com/gitleaks/gitleaks/releases/download/v${GITLEAKS_VERSION}/gitleaks_${GITLEAKS_VERSION}_linux_${ARCH}.tar.gz" \
 && tar -xzf /tmp/gitleaks.tar.gz -C /usr/local/bin gitleaks \
 && chmod +x /usr/local/bin/gitleaks \
 && rm -f /tmp/gitleaks.tar.gz

# ── Trivy ──
RUN ARCH=$(case "$TARGETARCH" in amd64) echo 64bit;; arm64) echo ARM64;; esac) \
 && wget -qO /tmp/trivy.tar.gz \
      "https://github.com/aquasecurity/trivy/releases/download/v${TRIVY_VERSION}/trivy_${TRIVY_VERSION}_Linux-${ARCH}.tar.gz" \
 && tar -xzf /tmp/trivy.tar.gz -C /usr/local/bin trivy \
 && chmod +x /usr/local/bin/trivy \
 && rm -f /tmp/trivy.tar.gz

# ── Syft ──
RUN ARCH="$TARGETARCH" \
 && wget -qO /tmp/syft.tar.gz \
      "https://github.com/anchore/syft/releases/download/v${SYFT_VERSION}/syft_${SYFT_VERSION}_linux_${ARCH}.tar.gz" \
 && tar -xzf /tmp/syft.tar.gz -C /usr/local/bin syft \
 && chmod +x /usr/local/bin/syft \
 && rm -f /tmp/syft.tar.gz

# ── Cosign ──
RUN wget -qO /usr/local/bin/cosign \
      "https://github.com/sigstore/cosign/releases/download/v${COSIGN_VERSION}/cosign-linux-${TARGETARCH}" \
 && chmod +x /usr/local/bin/cosign

USER ansible
