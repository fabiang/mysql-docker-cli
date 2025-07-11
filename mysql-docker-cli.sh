#!/usr/bin/env bash

get_container_for_volume() {
  local volume_name="$1"

  for container_id in $(docker ps -q); do
    if docker inspect "$container_id" \
      | grep -q "\"Name\": \"$volume_name\""; then
        docker inspect --format '{{.Name}}' "$container_id" | sed 's|/||'
        return 0
    fi
  done

  echo "Unbekannter Container"
}

get_volume_name_from_path() {
  local path="$1"
  # Beispiel: /var/lib/docker/volumes/mysql-data/_data/mysqld.sock
  basename "$(dirname "$(dirname "$path")")"
}

find_real_mysql() {
  local self_path="$(realpath "$0")"

  IFS=':' read -ra PATH_DIRS <<< "$PATH"

  for dir in "${PATH_DIRS[@]}"; do
    for bin in mysql mariadb; do
      local candidate="$dir/$bin"
      if [[ -x "$candidate" && "$(realpath "$candidate")" != "$self_path" ]]; then
        echo "$candidate"
        return 0
      fi
    done
  done

  return 1
}

DATA_ROOT=$(docker info --format '{{.DockerRootDir}}' 2>/dev/null)

if [ -z "$DATA_ROOT" ]; then
  echo "❌ Not able to dtermine the Docker data root path. Is Docker running?"
  exit 1
fi

SEARCH_DIR="$DATA_ROOT/volumes"

echo "📦 Searching for MySQL socket in any volume under: $SEARCH_DIR ..."
SOCKETS=($(find "$SEARCH_DIR" -path '*/_data/*'  \( -name "mysqld.sock" -o -name "mariadbd.sock" \) -type s 2>/dev/null))

if [ ${#SOCKETS[@]} -eq 0 ]; then
  echo "❌ Not socket files could be found."
  exit 1
fi

echo
echo "Found the following MySQL socket files:"
OPTIONS=()
i=1
for SOCKET in "${SOCKETS[@]}"; do
  VOL_NAME=$(get_volume_name_from_path "$SOCKET")
  CONTAINER_NAME=$(get_container_for_volume "$VOL_NAME")

  echo "$i) $CONTAINER_NAME ($SOCKET)"
  OPTIONS+=("$SOCKET")
  ((i++))
done

echo
read -p "To which instance you like to connect? (1-${#OPTIONS[@]}): " CHOICE

if [[ "$CHOICE" -lt 1 || "$CHOICE" -gt ${#OPTIONS[@]} ]]; then
  echo "❌ Invalid choice"
  exit 1
fi

SOCKET_PATH="${OPTIONS[$((CHOICE-1))]}"

REAL_MYSQL=$(find_real_mysql)
if [[ -z "$REAL_MYSQL" ]]; then
  echo "❌ Could not find mysql/mariadb binary in \$PATH"
  exit 1
fi

echo "🔌 Connecting to $SOCKET_PATH ..."
exec "$REAL_MYSQL" --socket="$SOCKET_PATH" "$@"
