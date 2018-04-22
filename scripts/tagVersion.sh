#!/bin/bash

OPTS=`getopt -o hr: --long help,repository: -n 'parse-options' -- "$@"`
eval set -- "$OPTS"

function usage() {
  printf "Usage: $0 -r|--repository REPOSITORY"
}

function setupGit() {
  git config --global push.default simple
  git config --global user.email "travis@travis-ci.org"
  git config --global user.name "Travis CI"
}

function tagVersion() {
  TAG=$1
  BRANCH=$2
  REPOSITORY=$(echo $3 | sed -e s#github#${GH_USER}\:${GH_TOKEN}@github#g)

  git tag $TAG $BRANCH -m "Release version $TAG"
  git push --quiet $REPOSITORY $TAG > /dev/null 2>&1
}

REPOSITORY=""
BRANCH=""
TAG=""

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

if [ "$BRANCH" = "ci-test" ]; then
  TAG=$(bash scripts/appVersion.sh --version)

  setupGit
  tagVersion $TAG $BRANCH $REPOSITORY
fi
