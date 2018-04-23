#!/bin/bash

OPTS=`getopt -o hr: --long help,repository: -n 'parse-options' -- "$@"`
eval set -- "$OPTS"

function usage() {
  printf "Usage: $0 -r|--repository REPOSITORY"
}

function updateDevelopmentVersion() {
  VERSION=""
  REPOSITORY=$(echo $1 | sed -e s#github#${GH_USER}\:${GH_TOKEN}@github#g)
  USER=$(git config user.name)

  $(bash scripts/appVersion.sh --next) > /dev/null 2>&1 

  git add package.json 
  git commit -m "$USER: Package version was updated to next development phase"
  git push --quiet $REPOSITORY ${RELEASE_BRANCH} > /dev/null 2>&1

  git checkout ${DEVELOPMENT_BRANCH}
  git merge ${RELEASE_BRANCH} --no-edit 
  git push --quiet $REPOSITORY ${DEVELOPMENT_BRANCH} > /dev/null 2>&1
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
  updateDevelopmentVersion $REPOSITORY
else
  echo "Version still in development phase"
fi

cd ..

rm -rf mpro $VERSION.tgz