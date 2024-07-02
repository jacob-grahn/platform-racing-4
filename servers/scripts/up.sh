set -e # Exit script if a command errors

cd ../environments

docker compose \
  -f ingress.yaml \
  -f dev.yaml.rendered \
  -f dev.secrets.yaml \
  -f prod.yaml.rendered \
  -f prod.secrets.yaml \
  -f prod-bubble-racing.yaml \
  -f prod-bubble-racing.secrets.yaml \
  --project-name platform-racing-4 \
  up \
  -d \
  --remove-orphans