STORE=.latest

LATEST=$(curl -fs "https://terraria.org/api/get/dedicated-servers-names" | jq -r '.[0]')
PREVIOUS=$(test -f "$STORE" && cat "$STORE")

if [[ "$LATEST" == "$PREVIOUS" ]]; then
	echo "Server up to date."
	exit 1
fi

echo "Building latest version of the server ($LATEST)..."

DOCKER_USERNAME=$(docker info 2>/dev/null | grep -i "username" | awk '{print $2}')
VERSION=$(echo "$LATEST" | cut -d '.' -f 1 | cut -d '-' -f 3)
TAG_VER=$(echo "$VERSION" | fold -w1 | tr '\n' '.' | sed 's/.$//')

docker build \
	--build-arg SERVER_VERSION="$VERSION" \
	-t "$DOCKER_USERNAME/terraria:vanilla-$TAG_VER" \
	./vanilla 1>/dev/null

docker tag "$DOCKER_USERNAME/terraria:vanilla-$TAG_VER" "$DOCKER_USERNAME/terraria:vanilla-latest" 
docker push -a "$DOCKER_USERNAME/terraria" 1>/dev/null

echo "$LATEST" > "$STORE"
echo "Server version updated to v$TAG_VER"
