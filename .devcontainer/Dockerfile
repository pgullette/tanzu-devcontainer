FROM harbor-repo.vmware.com/dockerhub-proxy-cache/library/alpine
ARG VSPHERE_SERVER
ARG TANZU_CLI_VERSION
WORKDIR /workspace
RUN wget -q --no-check-certificate -O vsphere-plugin.zip $VSPHERE_SERVER/wcp/plugin/linux-amd64/vsphere-plugin.zip
RUN wget -q --no-check-certificate -O sha256sum.txt $VSPHERE_SERVER/wcp/plugin/linux-amd64/sha256sum.txt
RUN unzip vsphere-plugin.zip
RUN sha256sum -c sha256sum.txt
RUN wget -q --no-check-certificate -O tanzu-cli.tar.gz https://github.com/vmware-tanzu/tanzu-cli/releases/download/$TANZU_CLI_VERSION/tanzu-cli-linux-amd64.tar.gz
RUN tar xvzf tanzu-cli.tar.gz

FROM harbor-repo.vmware.com/dockerhub-proxy-cache/library/ubuntu
ARG TANZU_CLI_VERSION
RUN apt-get update && apt-get install --no-install-recommends -y gnupg2 ca-certificates curl && apt-get clean
COPY --from=0 /workspace/bin/kubectl /usr/local/bin
COPY --from=0 /workspace/bin/kubectl-vsphere /usr/local/bin
COPY --from=0 /workspace/$TANZU_CLI_VERSION/tanzu-cli-linux_amd64 /usr/local/bin/tanzu
RUN chmod +x /usr/local/bin/kubectl
RUN chmod +x /usr/local/bin/kubectl-vsphere