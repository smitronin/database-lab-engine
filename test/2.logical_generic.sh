#!/bin/bash
set -euxo pipefail

DIR=${0%/*}
IMAGE2TEST="registry.gitlab.com/postgres-ai/database-lab/dblab-server:master"
SOURCE_DBNAME="${SOURCE_DBNAME:-test}"
SOURCE_HOST="${SOURCE_HOST:-172.31.39.142}"
SOURCE_USERNAME="${SOURCE_USERNAME:-postgres}"
SOURCE_PASSWORD="${SOURCE_PASSWORD:-qwerty}"
POSTGRES_VERSION="${SOURCE_PASSWORD:-10}"

### Step 1: Prepare a machine with two disks, Docker and ZFS

source "${DIR}/_prerequisites.ubuntu.sh"
source "${DIR}/_zfs.file.sh"

### Step 2. Prepare database data directory

### Step ?. Configure and launch the Database Lab server
mkdir -p ~/.dblab
cp ./configs/config.example.logical_generic.yml ~/.dblab/server_test.yml
sed -ri 's/^(\s\s)(port:.*$)/\1port: 12345/' ~/.dblab/server_test.yml
sed -ri 's/^(\s*)(debug:.*$)/\1debug: true/' ~/.dblab/server_test.yml
sed -ri 's/^(\s*)(pool:.*$)/\1pool: "test_pool"/' ~/.dblab/server_test.yml
sed -ri "s/^(\s*)(host: 34\.56\.78\.90$)/\1host: \"${SOURCE_HOST}\"/" ~/.dblab/server_test.yml
sed -ri "s/^(\s*)(dbname:.*$)/\1dbname: \"${SOURCE_DBNAME}\"/" ~/.dblab/server_test.yml
sed -ri "s/^(\s*)(username: postgres$)/\1username: \"${SOURCE_USERNAME}\"/" ~/.dblab/server_test.yml
sed -ri "s/^(\s*)(password:.*$)/\1password: \"${SOURCE_PASSWORD}\"/" ~/.dblab/server_test.yml

### Step ?. Create source database
export PGPASSWORD=${SOURCE_PASSWORD}
psql -h ${SOURCE_HOST}  -U ${SOURCE_USERNAME} -c 'drop database test' || echo "database test does not exist"
psql -h ${SOURCE_HOST}  -U ${SOURCE_USERNAME} -c 'create database test'
pgbench -h ${SOURCE_HOST}  -U ${SOURCE_USERNAME} -i -s 10 test

### Step ? Run dblab
sudo docker run \
  --detach \
  --name dblab_test \
  --label dblab_control \
  --privileged \
  --publish 12345:12345 \
  --volume /var/run/docker.sock:/var/run/docker.sock \
  --volume /var/lib/dblab:/var/lib/dblab:rshared \
  --volume ~/.dblab/server_test.yml:/home/dblab/configs/config.yml \
  "${IMAGE2TEST}"

sudo docker logs -f dblab_test 2>&1 | awk '{print "[CONTAINER dblab_test]: "$0}' &

### Waiting fori dblab initialization
for i in {1..30}; do
  curl http://localhost:12345 > /dev/null 2>&1 && break || echo "dblab is not ready yet"
  sleep 10
done

### Step ?. Setup Dnd init atabase Lab client CLI
curl https://gitlab.com/postgres-ai/database-lab/-/raw/master/scripts/cli_install.sh | bash
dblab --version
dblab init --url http://localhost:12345 --token secret_token --environment-id test
dblab instance status

### Step ?. Create clone and connect to it
dblab clone create --username testuser --password testuser --id testclone
dblab clone list
export PGPASSWORD=testuser
psql "host=localhost port=6000 user=testuser dbname=test" -c '\l'


### Step 6. Reset clone
psql "host=localhost port=6000 user=testuser dbname=test" -c 'create database reset_database';
psql "host=localhost port=6000 user=testuser dbname=test" -c '\l'
dblab clone reset testclone
dblab clone status testclone
psql "host=localhost port=6000 user=testuser dbname=test" -c '\l'

### Step 9. Destroy clone
dblab clone create --username testuser --password testuser --id testclone2
dblab clone list
dblab clone destroy testclone2
dblab clone list

### Step ?. Restart containers
sudo docker ps -a --filter 'label=dblab_control' \
    | grep -v CONTAINER \
    | awk '{print $1}' \
    | sudo xargs --no-run-if-empty docker restart \
  || true
sudo docker ps -a --filter 'label=dblab-clone' \
    | grep -v CONTAINER \
    | awk '{print $1}' \
    | sudo xargs --no-run-if-empty docker restart \
  || true

for i in {1..300}; do
  psql "host=localhost port=6000 user=testuser dbname=test" -c '\l' 2>/dev/null  && break || echo "cloned database is not ready yet"
  sleep 1
done
