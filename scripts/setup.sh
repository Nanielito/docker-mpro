#!/bin/bash

OPTS=`getopt -o hr:b:t: --long help,repository:,branch:,tag: -n 'parse-options' -- "$@"`
eval set -- "$OPTS"

function usage() {
  printf "Usage: $0 -r|--repository REPOSITORY [-b|--branch BRANCH] [-t|--tag TAG]"
}

function setupGit() {
  git config push.default simple
  git config user.email "travis@travis-ci.org"
  git config user.name "Travis CI"
}

function commitVersion() {
  BRANCH=$1
  REPOSITORY=$(echo $2 | sed -e s#github#${GH_USER}\:${GH_TOKEN}@github#g)
  TYPE=$3
  USER=$(git config user.name)

  git add package.json
  git commit -m "$USER: Package version was updated to $TYPE"
  git push --quiet $REPOSITORY $BRANCH > /dev/null 2>&1
}

REPOSITORY=""
BRANCH=""
TAG=""
TYPE="release"

while true
  do
    case "$1" in
      -h | --help)
        usage; exit 0 ;;
      -r | --repository)
        REPOSITORY=$2; shift 2 ;;
      -b | --branch)
        BRANCH=$2; shift 2 ;;
      -t | --tag)
        TAG=$2; shift 2 ;;
      --)
        shift; break ;;
      *)
        usage; exit 1 ;;
    esac
  done

if [ -z "$REPOSITORY" ]; then
  usage
  exit 1
fi

if [ -z "$BRANCH" ]; then
  BRANCH="${DEVELOPMENT_BRANCH}"
fi

echo "Cloning $REPOSITORY on branch $BRANCH..."
git clone -b $BRANCH $REPOSITORY ./mpro

cd mpro

setupGit

# Storages the current version into a file to make it available if something wrong
# ocurrs to rollback it again.
echo $(bash scripts/appVersion.sh --version) > previousVersion

if [ "$BRANCH" = "${RELEASE_BRANCH}" ]; then
  $(bash scripts/appVersion.sh --release) > /dev/null 2>&1 
  TAG=$(bash scripts/appVersion.sh --version)
else
  if [ -z "$TAG" ]; then
    $(bash scripts/appVersion.sh --snapshot) > /dev/null 2>&1 
    TAG="latest"
  fi

  TYPE="snapshot"
fi

# Pushes the new version into repository
commitVersion $BRANCH $REPOSITORY $TYPE

cd ..

docker build --build-arg VERSION=$TAG -t mpro/mpro-app:$TAG .
