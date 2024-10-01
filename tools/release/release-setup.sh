#!/bin/bash
# used by release.sh

RELEASE_VERSION=$1
NEXT_VERSION=$2
RELEASE_ISSUE_URL=$3
PUSH_TO_ORIGIN=$4
WORKING_DIR=$5
BACKEND_RELEASE_ARTIFACT_URL=$6
ETL_RELEASE_ARTIFACT_URL=$7
FRONTEND_RELEASE_ARTIFACT_URL=$8
IMPORTSCRIPTS_RELEASE_ARTIFACT_URL=$9
echo "Parameters"
echo "RELEASE_VERSION=$RELEASE_VERSION"
echo "NEXT_VERSION=$NEXT_VERSION"
echo "RELEASE_ISSUE_URL=$RELEASE_ISSUE_URL"
echo "PUSH_TO_ORIGIN=$PUSH_TO_ORIGIN"
echo "WORKING_DIR=$WORKING_DIR"

BACKEND_SNAPSHOT_ARTIFACT_URL=https://gitlab.com/oersi/sidre/sidre-backend/-/jobs/artifacts/master/download?job=deploy+branch
ETL_SNAPSHOT_ARTIFACT_URL=https://gitlab.com/oersi/oersi-etl/-/jobs/artifacts/master/download?job=deploy
IMPORTSCRIPTS_SNAPSHOT_ARTIFACT_URL=https://gitlab.com/oersi/oersi-import-scripts/-/jobs/artifacts/master/download?job=deploy
FRONTEND_SNAPSHOT_ARTIFACT_URL=https://gitlab.com/oersi/sidre/sidre-frontend/-/jobs/artifacts/master/download?job=build

echo "---------------"
echo "Release Setup"
echo "---------------"
echo "Cleanup WORKING_DIR"
rm -rf $WORKING_DIR/oersi-setup
cd $WORKING_DIR
git clone git@gitlab.com:oersi/oersi-setup.git -b master
cd $WORKING_DIR/oersi-setup
sed -i "s#oerindex_backend_artifact_url: .*#oerindex_backend_artifact_url: '${BACKEND_RELEASE_ARTIFACT_URL}'#g" ansible/group_vars/all.yml
sed -i "s#oerindex_etl_artifact_url: .*#oerindex_etl_artifact_url: '${ETL_RELEASE_ARTIFACT_URL}'#g" ansible/group_vars/all.yml
sed -i "s#oerindex_import_scripts_artifact_url: .*#oerindex_import_scripts_artifact_url: '${IMPORTSCRIPTS_RELEASE_ARTIFACT_URL}'#g" ansible/group_vars/all.yml
sed -i "s#oerindex_frontend_artifact_url: .*#oerindex_frontend_artifact_url: '${FRONTEND_RELEASE_ARTIFACT_URL}'#g" ansible/group_vars/all.yml
git add ansible/group_vars/all.yml
git commit -m "use release artifacts (Ref $RELEASE_ISSUE_URL)"
git tag -a $RELEASE_VERSION -m "release $RELEASE_VERSION (Ref $RELEASE_ISSUE_URL)"
sed -i "s#oerindex_backend_artifact_url: .*#oerindex_backend_artifact_url: '${BACKEND_SNAPSHOT_ARTIFACT_URL}'#g" ansible/group_vars/all.yml
sed -i "s#oerindex_etl_artifact_url: .*#oerindex_etl_artifact_url: '${ETL_SNAPSHOT_ARTIFACT_URL}'#g" ansible/group_vars/all.yml
sed -i "s#oerindex_import_scripts_artifact_url: .*#oerindex_import_scripts_artifact_url: '${IMPORTSCRIPTS_SNAPSHOT_ARTIFACT_URL}'#g" ansible/group_vars/all.yml
sed -i "s#oerindex_frontend_artifact_url: .*#oerindex_frontend_artifact_url: '${FRONTEND_SNAPSHOT_ARTIFACT_URL}'#g" ansible/group_vars/all.yml
git add ansible/group_vars/all.yml
git commit -m "use branch artifacts (Ref $RELEASE_ISSUE_URL)"
if [ "$PUSH_TO_ORIGIN" = true ] ; then
  echo "push to origin"
  git push origin master
  git push origin $RELEASE_VERSION
fi
