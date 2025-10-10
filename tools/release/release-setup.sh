#!/bin/bash
# used by release.sh

RELEASE_VERSION=$1
NEXT_VERSION=$2
RELEASE_ISSUE_URL=$3
PUSH_TO_ORIGIN=$4
WORKING_DIR=$5
ETL_RELEASE_ARTIFACT_URL=$6
IMPORTSCRIPTS_RELEASE_ARTIFACT_URL=$7
SCHEMA_RELEASE_ARTIFACT_URL=$8
SIDRE_SETUP_RELEASE_ARTIFACT_URL=$9

echo "Parameters"
echo "RELEASE_VERSION=$RELEASE_VERSION"
echo "NEXT_VERSION=$NEXT_VERSION"
echo "RELEASE_ISSUE_URL=$RELEASE_ISSUE_URL"
echo "PUSH_TO_ORIGIN=$PUSH_TO_ORIGIN"
echo "WORKING_DIR=$WORKING_DIR"

ETL_SNAPSHOT_ARTIFACT_URL="https://gitlab.com/oersi/oersi-etl/-/jobs/artifacts/master/download?job=deploy"
IMPORTSCRIPTS_SNAPSHOT_ARTIFACT_URL="https://gitlab.com/oersi/oersi-import-scripts/-/jobs/artifacts/master/download?job=deploy"
SCHEMA_SNAPSHOT_ARTIFACT_URL="https://gitlab.com/oersi/oersi-schema/-/jobs/artifacts/main/download?job=deploy"
SIDRE_SETUP_SNAPSHOT_ARTIFACT_URL="https://gitlab.com/oersi/sidre/sidre-setup/-/jobs/artifacts/main/raw/search_index-setup.tar.gz?job=deploy"

echo "---------------"
echo "Release Setup"
echo "---------------"
echo "Cleanup WORKING_DIR"
rm -rf $WORKING_DIR/oersi-setup
cd $WORKING_DIR
git clone git@gitlab.com:oersi/oersi-setup.git -b master
cd $WORKING_DIR/oersi-setup

sed -i "s#- source: ${SIDRE_SETUP_SNAPSHOT_ARTIFACT_URL}#- source: ${SIDRE_SETUP_RELEASE_ARTIFACT_URL}#g" requirements.yml
git add requirements.yml
sed -i "s#search_index_etl_artifact_url: .*#search_index_etl_artifact_url: '${ETL_RELEASE_ARTIFACT_URL}'#g" default-config.yml
sed -i "s#search_index_import_scripts_artifact_url: .*#search_index_import_scripts_artifact_url: '${IMPORTSCRIPTS_RELEASE_ARTIFACT_URL}'#g" default-config.yml
sed -i "s#search_index_metadata_schema_artifact_url: .*#search_index_metadata_schema_artifact_url: '${SCHEMA_RELEASE_ARTIFACT_URL}'#g" default-config.yml
git add default-config.yml
git commit -m "release $RELEASE_VERSION (Ref $RELEASE_ISSUE_URL)"
git tag -a $RELEASE_VERSION -m "release $RELEASE_VERSION (Ref $RELEASE_ISSUE_URL)"
sed -i "s#- source: ${SIDRE_SETUP_RELEASE_ARTIFACT_URL}#- source: ${SIDRE_SETUP_SNAPSHOT_ARTIFACT_URL}#g" requirements.yml
git add requirements.yml
sed -i "s#search_index_etl_artifact_url: .*#search_index_etl_artifact_url: '${ETL_SNAPSHOT_ARTIFACT_URL}'#g" default-config.yml
sed -i "s#search_index_import_scripts_artifact_url: .*#search_index_import_scripts_artifact_url: '${IMPORTSCRIPTS_SNAPSHOT_ARTIFACT_URL}'#g" default-config.yml
sed -i "s#search_index_metadata_schema_artifact_url: .*#search_index_metadata_schema_artifact_url: '${SCHEMA_SNAPSHOT_ARTIFACT_URL}'#g" default-config.yml
git add default-config.yml
git commit -m "use next snapshot artifacts (Ref $RELEASE_ISSUE_URL)"
if [ "$PUSH_TO_ORIGIN" = true ] ; then
  echo "push to origin"
  git push origin master
  git push origin $RELEASE_VERSION
fi
