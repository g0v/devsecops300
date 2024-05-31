FROM gitpod/openvscode-server:1.89.1 as base
USER root
RUN apt-get update && apt-get install -y curl age
RUN <<EOF
curl -LO https://github.com/getsops/sops/releases/download/v3.8.1/sops-v3.8.1.linux.amd64
mv sops-v3.8.1.linux.amd64 /usr/local/bin/sops
chmod +x /usr/local/bin/sops
EOF

FROM base AS docker
# Install docker cli
RUN <<\EOF
apt-get install ca-certificates curl
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
    
# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install docker-ce-cli docker-buildx-plugin docker-compose-plugin
EOF
# Install vscode docker extension
USER openvscode-server
RUN <<EOF
/home/.openvscode-server/bin/openvscode-server --install-extension=ms-azuretools.vscode-docker
EOF
USER root

FROM docker AS lazy
# install lazygit
RUN <<EOF
LAZYGIT_VERSION=0.42.0
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
install lazygit /usr/local/bin
rm lazygit lazygit.tar.gz
EOF

# install lazydocker
RUN <<EOF
DIR=/usr/local/bin
LAZYDOCKER_VERSION=0.23.3
GITHUB_URL="https://github.com/jesseduffield/lazydocker/releases/download/v${LAZYDOCKER_VERSION}/lazydocker_${LAZYDOCKER_VERSION}_Linux_x86_64.tar.gz"
# install/update the local binary
curl -L -o lazydocker.tar.gz $GITHUB_URL
tar xzvf lazydocker.tar.gz lazydocker
install -Dm 755 lazydocker -t /usr/local/bin
rm lazydocker lazydocker.tar.gz
EOF