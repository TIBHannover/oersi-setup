#!/bin/bash
# used by release.sh

RELEASE_VERSION=$1
NEXT_VERSION=$2
RELEASE_ISSUE_URL=$3
PUSH_TO_ORIGIN=$4
WORKING_DIR=$5
SIDRE_IMPORTSCRIPTS_COMMONS_RELEASE_ARTIFACT_URL=$6
echo "Parameters"
echo "RELEASE_VERSION=$RELEASE_VERSION"
echo "NEXT_VERSION=$NEXT_VERSION"
echo "RELEASE_ISSUE_URL=$RELEASE_ISSUE_URL"
echo "PUSH_TO_ORIGIN=$PUSH_TO_ORIGIN"
echo "WORKING_DIR=$WORKING_DIR"

SIDRE_IMPORTSCRIPTS_COMMONS_SNAPSHOT_ARTIFACT_URL="https://gitlab.com/oersi/sidre/sidre-import-scripts-commons/-/jobs/artifacts/main/download?job=deploy"
NEXT_SNAPSHOT_VERSION=${NEXT_VERSION}-SNAPSHOT

echo "---------------"
echo "Release Import Scripts"
echo "---------------"
echo "Cleanup WORKING_DIR"
rm -rf $WORKING_DIR/oersi-import-scripts
cd $WORKING_DIR
git clone git@gitlab.com:oersi/oersi-import-scripts.git -b master
if [ $? -ne 0 ] ; then
  echo "Cloning failed."
  exit 1
fi
cd $WORKING_DIR/oersi-import-scripts

sed -i "s#$SIDRE_IMPORTSCRIPTS_COMMONS_SNAPSHOT_ARTIFACT_URL#$SIDRE_IMPORTSCRIPTS_COMMONS_RELEASE_ARTIFACT_URL#g" python/requirements.txt
git add python/requirements.txt
git commit -m "release $RELEASE_VERSION (Ref $RELEASE_ISSUE_URL)"
git tag -a $RELEASE_VERSION -m "release $RELEASE_VERSION (Ref $RELEASE_ISSUE_URL)"
sed -i "s#$SIDRE_IMPORTSCRIPTS_COMMONS_RELEASE_ARTIFACT_URL#$SIDRE_IMPORTSCRIPTS_COMMONS_SNAPSHOT_ARTIFACT_URL#g" python/requirements.txt
git add python/requirements.txt
git commit -m "next snapshot (Ref $RELEASE_ISSUE_URL)"

if [ "$PUSH_TO_ORIGIN" = true ] ; then
  echo "push to origin"
  git push origin master
  git push origin $RELEASE_VERSION
fi
