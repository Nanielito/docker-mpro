#!/bin/bash

OPTS=`getopt -o hu:p: --long help,registry-user:,registry-password: -n 'parse-options' -- "$@"`
eval set -- "$OPTS"

function usage() {
  printf "Usage: $0 -u|--regisrty-user USER -p|--registry-password PASSWORD"
}

REGISTRY_USER=""
REGISTRY_PASSWORD=""
TAG=""

while true
  do
    case "$1" in
      -h | --help)
        usage; exit 0 ;;
      -u | --registry-user)
        REGISTRY_USER=$2; shift 2 ;;
      -p | --registry-password)
        REGISTRY_PASSWORD=$2; shift 2 ;;
      --)
        shift; break ;;
      *)
        echo "1"
        usage; exit 1 ;;
    esac
  done

if [ -z "$REGISTRY_USER" ] || [ -z "$REGISTRY_PASSWORD" ]; then
  echo "2"
  usage
  exit 1
fi

cd mpro

if [ "$BRANCH" = "ci-test" ]; then
  TAG=$(bash scripts/appVersion.sh --version)
else
  if [ -z "$TAG" ]; then
    TAG="latest"
  fi
fi

cd ..

docker login -u "$REGISTRY_USER" -p "$REGISTRY_PASSWORD"

docker tag mpro/mpro-app:$TAG $REGISTRY_USER/mpro-app:$TAG

docker push $REGISTRY_USER/mpro-app:$TAG
