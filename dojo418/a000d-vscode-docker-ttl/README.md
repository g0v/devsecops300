# docker cli in vscode

http://localhost:3000/?folder=/home/workspace

# Usage

Docker compose uses the generated configuration to start the containers in detached mode (default behavior).

```sh
. genttl.sh && gen_compose $(build_img) | docker compose -f - up
```

The generated YAML configuration to a file /tmp/docker-compose.yaml, which allows for easier debugging and reuse of the configuration. 

```sh
. genttl.sh && gen_compose $(build_img) | tee docker-compose.yaml | docker compose -f - up -d
docker compose exec ghost bash
docker compose down
```

In summary, This script provides more flexibility and control over the Docker Compose configuration, while first script is a simpler, more straightforward approach to starting containers with a generated configuration.

Share the ttl.sh registry image with others

```sh
. genttl.sh && gen_compose $(build_img push)  | tee docker-compose.yaml
docker compose up
```