set -e # Exit script if a command errors

# Example usage:
# find_newest_tag "ghcr.io/jacob-grahn/platform-racing-4-client-web" ".*-main-.*"
function find_newest_tag {
    # Accept image path and pattern as inputs
    local image_path="$1"
    local pattern="$2"

    # Extract the registry and repository from the image path
    local registry="${image_path%%/*}"
    local repo="${image_path#*/}"

    # Fetch a token
    local token=$(curl --fail -s https://ghcr.io/token\?scope\="repository:$registry/$repo:pull" | jq '.token' -r)

    # Fetch list of tags
    local tags_response=$(curl --fail -s -H "Authorization: Bearer $token" "https://${registry}/v2/${repo}/tags/list")
    
    # Filter tags by pattern and sort
    local tags=$(echo "$tags_response" | jq -r ".tags[] | select(test(\"$pattern\"))" | sort -r)
    
    # Alphabetically, the top tag is the newest (this only works because we are tagging with the date)
    local newest_tag=$(echo $tags | cut -d " " -f 1)

    # Return the result
    echo $newest_tag
}

# Example usage:
# inject_tag "dev.yaml" "#CLIENT_WEB_TAG" "tag"
function inject_tag {
    local file="$1"
    local match="$2"
    local tag="$3"
    local dir="../environments"
    cat "$dir/$file" | sed "s/$match/$tag/g" > "$dir/$file.rendered"
}


inject_tag "dev.yaml" "#CLIENT_WEB_TAG" "$(find_newest_tag "ghcr.io/jacob-grahn/platform-racing-4-client-web" ".*-main-.*")"
inject_tag "prod.yaml" "#CLIENT_WEB_TAG" "$(find_newest_tag "ghcr.io/jacob-grahn/platform-racing-4-client-web" ".*-release-.*")"