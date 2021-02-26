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

echo "---------------"
echo "Release ETL"
echo "---------------"
echo "Cleanup WORKING_DIR"
rm -rf $WORKING_DIR/oersi-etl
cd $WORKING_DIR
git clone git@gitlab.com:oersi/oersi-etl.git -b master
if [ $? -ne 0 ] ; then
  echo "Cloning failed."
  exit 1
fi
cd $WORKING_DIR/oersi-etl
git tag -a $RELEASE_VERSION -m "release $RELEASE_VERSION (Ref $RELEASE_ISSUE_URL)"
if [ "$PUSH_TO_ORIGIN" = true ] ; then
  echo "push to origin"
  git push origin $RELEASE_VERSION
fi
