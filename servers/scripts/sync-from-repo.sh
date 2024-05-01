set -e # Exit script if a command errors

# Fetch any changes from remote repo
git pull

# Fetch latest tags from ghcr
./inject-tags.sh

# Run services
./up.sh
