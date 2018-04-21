#!/bin/bash

OPTS=`getopt -o hau:s: --long help,auto,user:,server: -n 'parse-options' -- "$@"`
eval set -- "$OPTS"

COMMANDS=(                                                                                      \
    "$0 -u|--user USER -s|--server SERVER  To use Docker Hub credentials" \
    "$0 -a|--auto                          To be used by Travis CI job"   \
)

function usage() {
  printf '%s\n\t' "Usage:" "${COMMANDS[@]}"
}

USER=""
SERVER=""
VERSION=""

while true
  do
    case "$1" in
      -h | --help)
        usage; exit 0 ;;
      -a | --auto)
        USER=${REMOTE_USER}; SERVER=${REMOTE_SERVER}; break ;;
      -u | --user)
        USER=$2; shift 2 ;;
      -s | --server)
        SERVER=$2; shift 2 ;;
      --)
        shift; break ;;
      *)
        usage; exit 1 ;;
    esac
  done

if [ -z "$USER" ] || [ -z "$SERVER" ]; then
  usage
  exit 1
fi

cd mpro

VERSION=$(bash scripts/appVersion.sh --version)

cd ..

docker run -p 3000:3000 -e COMMAND=start -e DB_HOST=mprodb --name mpro -d --rm mpro/mpro-app:$VERSION
docker cp mpro:/home/mpro/build/$VERSION.tgz .
docker stop mpro

scp -o "StrictHostKeyChecking no" $VERSION.tgz $USER@$SERVER:/home/deploy && \
ssh -o "StrictHostKeyChecking no" $USER@$SERVER 'bash -s' < scripts/install.sh $VERSION

rm -rf mpro $VERSION.tgz
