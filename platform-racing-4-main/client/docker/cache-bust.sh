# Adapted from https://www.reddit.com/r/godot/comments/15iyl0m/cache_busting_in_html5_export/

set -o errexit
set -o nounset
set -o pipefail

# Hello
echo "Cache busting"

# Save a date stamp string of numbers
TIMESTAMP=$(date +%s)

# Go to the folder where the project is exported to
target_dir=$1
cd $target_dir

# Rename all files to add the date stamp
for file in index.*
do
mv "$file" "${file/index/index-$TIMESTAMP}"
done

# Name the index.html file BACK to just index.html
mv index-${TIMESTAMP}.html index.html

# Replace all instances of index with index-TIMESTAMP in the index.html
sed -i -- "s/index/index-${TIMESTAMP}/g" index.html