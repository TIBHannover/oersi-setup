#!/bin/bash
#
# Autmatically process all release steps of oersi
# Prerequisites:
#   - Release Issue
#   - local bash, git, curl, sed, jq, mvn, npm
#   - git connected to gitlab maintainer-account without pw-prompt (e.g. ssh-key)
#   - gitlab access token
#

RELEASE_VERSION=0.9.0
NEXT_VERSION=1.0.0
SIDRE_VERSION=0.9.0
RELEASE_ISSUE_URL=https://gitlab.com/oersi/oersi-setup/-/issues/xxx
#MILESTONE="OERSI prototype release"       # optional
MILESTONE=                                 # optional
DRY_RUN=false                              # true | false - if true all changes are applied only locally, nothing is pushed to origin
GITLAB_ACCESS_TOKEN=SET-YOUR-TOKEN         # set your gitlab access token here; necessary to create release entries

RELEASE_ETL=true
RELEASE_IMPORTSCRIPTS=true
RELEASE_SCHEMA=true
RELEASE_MARC_TRANSFORMATION=true
GITLAB_PROJECT_ID_ETL="17726912"
GITLAB_PROJECT_ID_IMPORTSCRIPTS="26258348"
GITLAB_PROJECT_ID_OERSI_SETUP="16999502"
GITLAB_PROJECT_ID_SCHEMA="44205972"
GITLAB_PROJECT_ID_MARC_TRANSFORMATION="51597408"
GITLAB_PROJECT_ID_SIDRE_SETUP="55327433"
GITLAB_PROJECT_ID_SIDRE_IMPORTSCRIPTS_COMMONS="52881614"
GITLAB_API_URL=https://gitlab.com/api/v4
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")
WORKING_DIR=/tmp/oersi-release
if [ "$DRY_RUN" = true ] ; then
  PUSH_TO_ORIGIN=false
else
  PUSH_TO_ORIGIN=true
fi

date +"%Y-%m-%d %H:%M:%S Starting OERSI release process for version $RELEASE_VERSION - SIDRE version $SIDRE_VERSION, dry run: $DRY_RUN, push to origin: $PUSH_TO_ORIGIN"

mkdir -p $WORKING_DIR

release_module() {
  RELEASE_SCRIPT_NAME=$1
  RELEASE_FLAG=$2
  shift 2
  REMAINING_PARAMS="$@"
  if [ "$RELEASE_FLAG" = true ] ; then
    $SCRIPT_DIR/$RELEASE_SCRIPT_NAME $RELEASE_VERSION $NEXT_VERSION $RELEASE_ISSUE_URL $PUSH_TO_ORIGIN $WORKING_DIR $REMAINING_PARAMS
  fi
}
get_release_package_id() {
  PROJECT_ID=$1
  SEARCH_VERSION=$2
  PACKAGE_ID=$(curl -s "${GITLAB_API_URL}/projects/${PROJECT_ID}/packages" | jq ".[] | select(.version == \"$SEARCH_VERSION\") | .id")
  echo $PACKAGE_ID
}
get_release_artifact_url() {
  PROJECT_ID=$1
  ARTIFACT_NAME_ENDING=$2
  SEARCH_VERSION=$3
  if [ -z "$SEARCH_VERSION" ] ; then
    SEARCH_VERSION=$RELEASE_VERSION
  fi
  if [ "$DRY_RUN" = true ] ; then
    echo "https://example.com/artifact-$PROJECT_ID-$ARTIFACT_NAME_ENDING"
    return
  fi
  PACKAGE_ID=$(get_release_package_id $PROJECT_ID $SEARCH_VERSION)
  PACKAGE_FILE_ID=$(curl -s "${GITLAB_API_URL}/projects/${PROJECT_ID}/packages/${PACKAGE_ID}/package_files" | jq ".[] | select(.file_name | endswith(\"${ARTIFACT_NAME_ENDING}\")) | .id")
  if [ -n "$PACKAGE_FILE_ID" ] ; then
    REPO_URL=$(curl -s "${GITLAB_API_URL}/projects/${PROJECT_ID}" | jq -r ".web_url")
    RELEASE_ARTIFACT_URL="${REPO_URL}/-/package_files/${PACKAGE_FILE_ID}/download"
    echo $RELEASE_ARTIFACT_URL
  fi
}

date +"%Y-%m-%d %H:%M:%S Determine SIDRE release artifact URLs"
SIDRE_SETUP_RELEASE_ARTIFACT_URL=$(get_release_artifact_url $GITLAB_PROJECT_ID_SIDRE_SETUP "search_index-setup.tar.gz" $SIDRE_VERSION)
SIDRE_IMPORTSCRIPTS_COMMONS_RELEASE_ARTIFACT_URL=$(get_release_artifact_url $GITLAB_PROJECT_ID_SIDRE_IMPORTSCRIPTS_COMMONS "import-scripts.zip" $SIDRE_VERSION)
echo "SIDRE_SETUP_RELEASE_ARTIFACT_URL=$SIDRE_SETUP_RELEASE_ARTIFACT_URL"
echo "SIDRE_IMPORTSCRIPTS_COMMONS_RELEASE_ARTIFACT_URL=$SIDRE_IMPORTSCRIPTS_COMMONS_RELEASE_ARTIFACT_URL"
if [ -z "$SIDRE_SETUP_RELEASE_ARTIFACT_URL" ] || [ -z "$SIDRE_IMPORTSCRIPTS_COMMONS_RELEASE_ARTIFACT_URL" ] ; then
  date +"%Y-%m-%d %H:%M:%S Missing SIDRE release artifacts"
  exit 1
fi

date +"%Y-%m-%d %H:%M:%S Process module releases"
release_module "release-etl.sh" $RELEASE_ETL
release_module "release-import-scripts.sh" $RELEASE_IMPORTSCRIPTS $SIDRE_IMPORTSCRIPTS_COMMONS_RELEASE_ARTIFACT_URL
release_module "release-marc-transformation.sh" $RELEASE_MARC_TRANSFORMATION
release_module "release-schema.sh" $RELEASE_SCHEMA

date +"%Y-%m-%d %H:%M:%S Determine release artifact URLs"
for run in {1..30}; do
  date +"%Y-%m-%d %H:%M:%S Searching for release artifacts"
  ETL_RELEASE_ARTIFACT_URL=$(get_release_artifact_url $GITLAB_PROJECT_ID_ETL "etl.zip")
  IMPORTSCRIPTS_RELEASE_ARTIFACT_URL=$(get_release_artifact_url $GITLAB_PROJECT_ID_IMPORTSCRIPTS "import-scripts.zip")
  MARC_TRANSFORMATION_RELEASE_ARTIFACT_URL=$(get_release_artifact_url $GITLAB_PROJECT_ID_MARC_TRANSFORMATION "oersi-marc.zip")
  SCHEMA_RELEASE_ARTIFACT_URL=$(get_release_artifact_url $GITLAB_PROJECT_ID_SCHEMA "schema.zip")

  date +"%Y-%m-%d %H:%M:%S package urls: etl $ETL_RELEASE_ARTIFACT_URL, import-scripts $IMPORTSCRIPTS_RELEASE_ARTIFACT_URL, marc-transformation $MARC_TRANSFORMATION_RELEASE_ARTIFACT_URL, schema $SCHEMA_RELEASE_ARTIFACT_URL"
  if [ -z "$ETL_RELEASE_ARTIFACT_URL" ] || [ -z "$IMPORTSCRIPTS_RELEASE_ARTIFACT_URL" ] || [ -z "$MARC_TRANSFORMATION_RELEASE_ARTIFACT_URL" ] || [ -z "$SCHEMA_RELEASE_ARTIFACT_URL" ] ; then
    date +"%Y-%m-%d %H:%M:%S wait for packages"
    sleep 60
  else
    break
  fi
done

if [ -z "$ETL_RELEASE_ARTIFACT_URL" ] ; then
  echo "Missing etl artifact for version $RELEASE_VERSION"
fi
if [ -z "$MARC_TRANSFORMATION_RELEASE_ARTIFACT_URL" ] ; then
  echo "Missing marc-transformation artifact for version $RELEASE_VERSION"
fi
if [ -z "$IMPORTSCRIPTS_RELEASE_ARTIFACT_URL" ] ; then
  echo "Missing import-scripts artifact for version $RELEASE_VERSION"
fi
if [ -z "$SCHEMA_RELEASE_ARTIFACT_URL" ] ; then
  echo "Missing schema artifact for version $RELEASE_VERSION"
fi
if [ -z "$ETL_RELEASE_ARTIFACT_URL" ] || [ -z "$MARC_TRANSFORMATION_RELEASE_ARTIFACT_URL" ] || [ -z "$IMPORTSCRIPTS_RELEASE_ARTIFACT_URL" ] || [ -z "$SCHEMA_RELEASE_ARTIFACT_URL" ] ; then
  exit 1
fi
echo $ETL_RELEASE_ARTIFACT_URL
echo $MARC_TRANSFORMATION_RELEASE_ARTIFACT_URL
echo $IMPORTSCRIPTS_RELEASE_ARTIFACT_URL
echo $SCHEMA_RELEASE_ARTIFACT_URL

date +"%Y-%m-%d %H:%M:%S Release setup"
# RELEASE SETUP -> no need to wait for artifact, as setup release does not produce artifacts
release_module "release-setup.sh" true $ETL_RELEASE_ARTIFACT_URL $IMPORTSCRIPTS_RELEASE_ARTIFACT_URL $SCHEMA_RELEASE_ARTIFACT_URL $SIDRE_SETUP_RELEASE_ARTIFACT_URL

date +"%Y-%m-%d %H:%M:%S Create gitlab release entries"
create_gitlab_release_entry() {
  PROJECT_ID=$1
  RELEASE_FLAG=$2
  ARTIFACT_URL=$3
  if [ "$RELEASE_FLAG" = true ] && [ "$PUSH_TO_ORIGIN" = true ] ; then
    if [ -z "$ARTIFACT_URL" ] ; then
      curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
          --data "{ \"name\": \"$RELEASE_VERSION\", \"tag_name\": \"$RELEASE_VERSION\", \"description\": \"Release $RELEASE_VERSION\", \"milestones\": [\"$MILESTONE\"] }" \
          --request POST "${GITLAB_API_URL}/projects/${PROJECT_ID}/releases"
    else
      curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
          --data "{ \"name\": \"$RELEASE_VERSION\", \"tag_name\": \"$RELEASE_VERSION\", \"description\": \"Release $RELEASE_VERSION\", \"milestones\": [\"$MILESTONE\"], \"assets\": { \"links\": [{ \"name\": \"package\", \"url\": \"$ARTIFACT_URL\", \"filepath\": \"/package\", \"link_type\":\"package\" }] } }" \
          --request POST "${GITLAB_API_URL}/projects/${PROJECT_ID}/releases"
    fi
  fi
}
create_gitlab_release_entry $GITLAB_PROJECT_ID_ETL $RELEASE_ETL $ETL_RELEASE_ARTIFACT_URL
create_gitlab_release_entry $GITLAB_PROJECT_ID_IMPORTSCRIPTS $RELEASE_IMPORTSCRIPTS $IMPORTSCRIPTS_RELEASE_ARTIFACT_URL
create_gitlab_release_entry $GITLAB_PROJECT_ID_MARC_TRANSFORMATION $RELEASE_MARC_TRANSFORMATION $MARC_TRANSFORMATION_RELEASE_ARTIFACT_URL
create_gitlab_release_entry $GITLAB_PROJECT_ID_SCHEMA $RELEASE_SCHEMA $SCHEMA_RELEASE_ARTIFACT_URL
create_gitlab_release_entry $GITLAB_PROJECT_ID_OERSI_SETUP true

date +"%Y-%m-%d %H:%M:%S Finished OERSI release process for version $RELEASE_VERSION"
