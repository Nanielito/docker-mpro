#!/bin/bash

OPTS=`getopt -o hr:b:u:p:t: --long help,repository:,branch:,registry-user:,registry-password:,tag: -n 'parse-options' -- "$@"`
eval set -- "$OPTS"

function usage() {
  printf "Usage: $0 -r|--repository REPOSITORY [-b|--branch BRANCH] -u|--regisrty-user USER -p|--registry-password PASSWORD [-t|--tag TAG]"
}

REPOSITORY=""
BRANCH=""
REGISTRY_USER=""
REGISTRY_PASSWORD=""
TAG=""

while true
  do
    case "$1" in
      -h | --help)
        usage; exit 0 ;;
      -r | --repository)
        REPOSITORY=$2; shift 2 ;;
      -b | --branch)
        BRANCH=$2; shift 2 ;;
      -u | --registry-user)
        REGISTRY_USER=$2; shift 2 ;;
      -p | --registry-password)
        REGISTRY_PASSWORD=$2; shift 2 ;;
      -t | --tag)
        TAG=$2; shift 2 ;;
      --)
        shift; break ;;
      *)
        usage; exit 1 ;;
    esac
  done

if [ -z "$REPOSITORY" ] || [ -z "$REGISTRY_USER" ] || [ -z "$REGISTRY_PASSWORD" ]; then
  usage
  exit 0
fi

if [ -z "$BRANCH" ]; then
  BRANCH="master"
fi

if [ -z "$TAG" ]; then
  TAG="latest"
fi

echo "Cloning $REPOSITORY on branch $BRANCH..."
git clone -b $BRANCH $REPOSITORY ./mpro

docker build -t mpro/mpro-app:$TAG .

docker login -u $REGISTRY_USER -p $REGISTRY_PASSWORD

docker tag mpro/mpro-app $REGISTRY_USER/mpro-app

docker push $REGISTRY_USER/mpro-app

rm -rf mpro
