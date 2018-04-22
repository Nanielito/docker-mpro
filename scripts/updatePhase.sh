#!/bin/bash

OPTS=`getopt -o hr: --long help,repository: -n 'parse-options' -- "$@"`
eval set -- "$OPTS"

function usage() {
  printf "Usage: $0 -r|--repository REPOSITORY"
}

function updateDevelopmentVersion() {
  VERSION=""
  MASTER=$1
  DEVELOPMENT=$2
  REPOSITORY=$(echo $3 | sed -e s#github#${GH_USER}\:${GH_TOKEN}@github#g)
  USER=$(git config user.name)

  git checkout $DEVELOPMENT
  git checkout $MASTER

  git merge $DEVELOPMENT --no-edit 

  $(bash scripts/appVersion.sh --next) > /dev/null 2>&1 

  git add package.json 
  git commit -m "$USER: Package version was updated to next development phase"
  git push --quiet $REPOSITORY $MASTER > /dev/null 2>&1

  git checkout $DEVELOPMENT
  git merge $MASTER --no-edit 
  git push --quiet $REPOSITORY $DEVELOPMENT > /dev/null 2>&1
}

REPOSITORY=""
BRANCH=""

while true
  do
    case "$1" in
      -h | --help)
        usage; exit 0 ;;
      -r | --repository)
        REPOSITORY=$2; shift 2 ;;
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

cd mpro

BRANCH=$(git rev-parse --abbrev-ref HEAD)

if [ "$BRANCH" = "${RELEASE_BRANCH}" ]; then
  updateDevelopmentVersion ${RELEASE_BRANCH} ${DEVELOPMENT_BRANCH} $REPOSITORY
else
  echo "Version still in development phase"
fi

cd ..

rm -rf mpro $VERSION.tgz