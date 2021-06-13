FROM alpine:3.13.5 AS base
FROM base AS build-base

RUN apk update && \
    apk add \
    curl \
    jq

ENTRYPOINT ["sh", "-o", "pipefail", "-c"]


# Downloader
FROM build-base AS downloader

WORKDIR /downloads

RUN curl -fL https://dl.k8s.io/release/v1.21.0/bin/linux/amd64/kubectl -o kubectl && \
    chmod +x kubectl

RUN curl -fL https://github.com/kubernetes-sigs/kustomize/releases/download/v3.1.0/kustomize_3.1.0_linux_amd64 -o kustomize && \
    chmod +x kustomize

RUN curl -fL https://github.com/digitalocean/doctl/releases/download/v1.61.0/doctl-1.61.0-linux-amd64.tar.gz | tar -xzv && \
    chmod +x doctl
 
# Runtime
FROM base AS runtime

LABEL maintainer="David Arena <david.andrew.arena@gmail.com>"

COPY --from=downloader /downloads/kubectl /usr/local/bin/kubectl
COPY --from=downloader /downloads/kustomize /usr/local/bin/kustomize
COPY --from=downloader /downloads/doctl /usr/local/bin/doctl

RUN curl -sL https://github.com/digitalocean/doctl/releases/download/v1.61.0/doctl-1.61.0-linux-amd64.tar.gz | tar -xzv && \
    chmod +x doctl && \
    mv ./doctl /usr/local/bin/doctl

ENTRYPOINT ["sh"]
