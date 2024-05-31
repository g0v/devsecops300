#!/bin/sh
build_img(){
  DOCKERFILE=$(cat <<"EOOF"
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
EOOF
)
  IMAGE_NAME=$(uuidgen)
  # Image tags provide the time limit. The default is 24 hours, and the max is 24 hours (valid time tags :5m, :1600s, :4h, :1d)
  IMAGE_URL=ttl.sh/${IMAGE_NAME}:4h
  echo "$DOCKERFILE" | docker build -t ${IMAGE_URL} -f - . > /dev/null
  if [ "$1" = "push" ]; then
    docker push ${IMAGE_URL} > /dev/null
  fi
  echo $IMAGE_URL
}

gen_compose(){
  cat <<EOF
services:
  ghost:
    image: $1
    volumes:
      - "/var/run/docker.sock:/var/run/docker.sock:ro"
    ports:
      - 3000:3000
EOF
}