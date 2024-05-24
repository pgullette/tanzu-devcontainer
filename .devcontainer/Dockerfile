### Scratch container
# FROM harbor-repo.vmware.com/dockerhub-proxy-cache/library/alpine
FROM alpine
ARG KUBECTL_MINOR_VERSION
ARG TANZU_CLI_VERSION
WORKDIR /workspace

# Fetch kubectl
RUN mkdir bin && wget -q --no-check-certificate -O bin/kubectl https://storage.googleapis.com/kubernetes-release/release/$(wget -q -O- https://storage.googleapis.com/kubernetes-release/release/stable-${KUBECTL_MINOR_VERSION}.txt)/bin/linux/amd64/kubectl

# Fetch tanzu cli
RUN wget -q --no-check-certificate -O tanzu-cli.tar.gz https://github.com/vmware-tanzu/tanzu-cli/releases/download/$TANZU_CLI_VERSION/tanzu-cli-linux-amd64.tar.gz
RUN tar xvzf tanzu-cli.tar.gz

### Final container
# FROM harbor-repo.vmware.com/dockerhub-proxy-cache/library/ubuntu
FROM ubuntu
ARG TANZU_CLI_VERSION
ARG TANZU_CLI_CEIP_OPT_IN_PROMPT_ANSWER
ARG TZ
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y gnupg2 ca-certificates curl xdg-utils && apt-get clean

# Install oh my zsh with plugins
RUN sh -c "$(curl -sSL https://github.com/deluan/zsh-in-docker/releases/download/v1.2.0/zsh-in-docker.sh)" -- \
    -p git -p kubectl

# Install Helm
RUN curl -s https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash -

# Install carvel tools
RUN curl -Ls https://carvel.dev/install.sh | bash -

# Copy and install binaries from scratch
COPY --from=0 /workspace/bin/kubectl /usr/local/bin
COPY --from=0 /workspace/$TANZU_CLI_VERSION/tanzu-cli-linux_amd64 /usr/local/bin/tanzu
RUN chmod +x /usr/local/bin/kubectl /usr/local/bin/tanzu

# Accept tanzu eula
RUN tanzu config eula accept

# Install tmc context plugin
RUN tanzu plugin install --group vmware-tmc/default

ENTRYPOINT [ "/usr/bin/zsh" ]