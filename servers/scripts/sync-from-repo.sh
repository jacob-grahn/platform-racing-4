set -e # Exit script if a command errors

# Fetch any changes from remote repo
git pull

# Run services
./up.sh
