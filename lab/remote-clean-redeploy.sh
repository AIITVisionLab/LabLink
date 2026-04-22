#!/usr/bin/env bash
set -euo pipefail

BASE=/opt/lab-recruitment
APP=$BASE/app
RUNTIME=$BASE/runtime
WEB=/var/www/lab-recruitment
DATA=/data/lab-recruitment
SERVICE=lab-recruitment
SOURCE=/home/ubuntu/source-bundle-current.tgz
FRONTEND=/home/ubuntu/frontend-dist-clean.tgz
ENV_FILE=$RUNTIME/backend-host.env
DB_NAME=lab_recruitment

for f in "$SOURCE" "$FRONTEND" "$ENV_FILE"; do
  if [[ ! -f "$f" ]]; then
    echo "missing required file: $f" >&2
    exit 1
  fi
done

DB_USER=$(grep '^DB_USERNAME=' "$ENV_FILE" | cut -d= -f2-)
DB_PASS=$(grep '^DB_PASSWORD=' "$ENV_FILE" | cut -d= -f2-)

mkdir -p "$APP" "$WEB" "$DATA/uploads" "$DATA/uploads_protected" "$DATA/judge-work" "$DATA/logs" "$RUNTIME/logs"

echo "STEP 1: replace source tree"
rm -rf "$APP"
mkdir -p "$APP"
tar -xzf "$SOURCE" -C "$APP"

echo "STEP 2: build backend from current source"
cd "$APP"
mvn -DskipTests package

if [[ ! -f "$APP/target/lab-recruitment-1.0.0.jar" ]]; then
  echo "built jar missing" >&2
  exit 1
fi

echo "STEP 3: stop current service"
systemctl stop "$SERVICE"

echo "STEP 4: delete project runtime data and reset database"
rm -rf "$DATA/uploads"/* "$DATA/uploads_protected"/* "$DATA/judge-work"/* "$DATA/logs"/* "$RUNTIME/logs"/* || true
mysql <<SQL
DROP DATABASE IF EXISTS \`$DB_NAME\`;
CREATE DATABASE \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
ALTER USER '$DB_USER'@'127.0.0.1' IDENTIFIED BY '$DB_PASS';
ALTER USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'127.0.0.1';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
SQL
mysql "$DB_NAME" < "$APP/src/main/resources/init.sql"

echo "STEP 5: replace backend jar and frontend static files"
install -m 0644 -o root -g root "$APP/target/lab-recruitment-1.0.0.jar" "$RUNTIME/lab-recruitment-1.0.0.jar"
find "$WEB" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
tar -xzf "$FRONTEND" -C "$WEB" --strip-components=1
chown -R www-data:www-data "$WEB"

echo "STEP 6: start service and validate"
systemctl start "$SERVICE"
sleep 18
systemctl is-active --quiet "$SERVICE"
curl -fsS "http://127.0.0.1:8081/labs/list?pageNum=1&pageSize=1" >/dev/null
curl -fsS "http://127.0.0.1/" >/dev/null

echo "STEP 7: cleanup release files"
rm -f "$SOURCE" "$FRONTEND"

echo "CLEAN_REDEPLOY_OK"