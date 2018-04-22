#!/bin/bash

OPTS=`getopt -o hau:p: --long help,auto,registry-user:,registry-password: -n 'parse-options' -- "$@"`
eval set -- "$OPTS"

COMMANDS=(                                                                                      \
    "$0 -u|--registry-user USER -p|--registry-password PASSWORD  To use Docker Hub credentials" \
    "$0 -a|--auto                                                To be used by Travis CI job"   \
)

function usage() {
  printf '%s\n\t' "Usage:" "${COMMANDS[@]}"
}

REGISTRY_USER=""
REGISTRY_PASSWORD=""
BRANCH=""
TAG=""

while true
  do
    case "$1" in
      -h | --help)
        usage; exit 0 ;;
      -a | --auto)
        REGISTRY_USER=${DH_USER}; REGISTRY_PASSWORD=${DH_PASSWORD}; break ;;
      -u | --registry-user)
        REGISTRY_USER=$2; shift 2 ;;
      -p | --registry-password)
        REGISTRY_PASSWORD=$2; shift 2 ;;
      --)
        shift; break ;;
      *)
        usage; exit 1 ;;
    esac
  done

if [ -z "$REGISTRY_USER" ] || [ -z "$REGISTRY_PASSWORD" ]; then
  usage
  exit 1
fi

cd mpro

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH" = "${RELEASE_BRANCH}" ]; then
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
