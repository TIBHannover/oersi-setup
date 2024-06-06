#!/bin/bash
# used by release.sh

RELEASE_VERSION=$1
NEXT_VERSION=$2
RELEASE_ISSUE_URL=$3
PUSH_TO_ORIGIN=$4
WORKING_DIR=$5
echo "Parameters"
echo "RELEASE_VERSION=$RELEASE_VERSION"
echo "NEXT_VERSION=$NEXT_VERSION"
echo "RELEASE_ISSUE_URL=$RELEASE_ISSUE_URL"
echo "PUSH_TO_ORIGIN=$PUSH_TO_ORIGIN"
echo "WORKING_DIR=$WORKING_DIR"

NEXT_SNAPSHOT_VERSION=${NEXT_VERSION}-SNAPSHOT

echo "---------------"
echo "Release backend"
echo "---------------"
echo "Cleanup WORKING_DIR"
rm -rf $WORKING_DIR/sidre-backend
cd $WORKING_DIR
git clone git@gitlab.com:oersi/sidre/sidre-backend.git -b master
if [ $? -ne 0 ] ; then
  echo "Cloning failed."
  exit 1
fi
cd $WORKING_DIR/sidre-backend
mvn versions:set -DnewVersion=$RELEASE_VERSION
git add pom.xml
git commit -m "release $RELEASE_VERSION (Ref $RELEASE_ISSUE_URL)"
git tag -a $RELEASE_VERSION -m "release $RELEASE_VERSION (Ref $RELEASE_ISSUE_URL)"
mvn versions:set -DnewVersion=$NEXT_SNAPSHOT_VERSION
git add pom.xml
git commit -m "next snapshot (Ref $RELEASE_ISSUE_URL)"
if [ "$PUSH_TO_ORIGIN" = true ] ; then
  echo "push to origin"
  git push origin master
  git push origin $RELEASE_VERSION
fi
