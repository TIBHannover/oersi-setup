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
RELEASE_ISSUE_URL=https://gitlab.com/oersi/oersi-setup/-/issues/xxx
#MILESTONE="OERSI prototype release"       # optional
MILESTONE=                                 # optional
PUSH_TO_ORIGIN=true                        # true | false
GITLAB_ACCESS_TOKEN=SET-YOUR-TOKEN         # set your gitlab access token here; necessary to create release entries

RELEASE_BACKEND=true
RELEASE_ETL=true
RELEASE_IMPORTSCRIPTS=true
RELEASE_SCHEMA=true
RELEASE_FRONTEND=true
WAIT_FOR_RELEASE_ARTIFACTS=${PUSH_TO_ORIGIN} # wait until all artifacts are available before releasing oersi-setup
BACKEND_RELEASE_VERSION=${RELEASE_VERSION}
BACKEND_NEXT_VERSION=${NEXT_VERSION}
ETL_RELEASE_VERSION=${RELEASE_VERSION}
ETL_NEXT_VERSION=${NEXT_VERSION}
IMPORTSCRIPTS_RELEASE_VERSION=${RELEASE_VERSION}
IMPORTSCRIPTS_NEXT_VERSION=${NEXT_VERSION}
SCHEMA_RELEASE_VERSION=${RELEASE_VERSION}
SCHEMA_NEXT_VERSION=${NEXT_VERSION}
FRONTEND_RELEASE_VERSION=${RELEASE_VERSION}
FRONTEND_NEXT_VERSION=${NEXT_VERSION}
GITLAB_BACKEND_API=https://gitlab.com/api/v4/projects/16856715
GITLAB_FRONTEND_API=https://gitlab.com/api/v4/projects/16666399
GITLAB_ETL_API=https://gitlab.com/api/v4/projects/17726912
GITLAB_IMPORTSCRIPTS_API=https://gitlab.com/api/v4/projects/26258348
GITLAB_SCHEMA_API=https://gitlab.com/api/v4/projects/44205972
GITLAB_SETUP_API=https://gitlab.com/api/v4/projects/16999502
SCRIPT=$(readlink -f "$0")
SCRIPT_DIR=$(dirname "$SCRIPT")
WORKING_DIR=/tmp/oersi-release

mkdir $WORKING_DIR

if [ "$RELEASE_BACKEND" = true ] ; then
  $SCRIPT_DIR/release-backend.sh $BACKEND_RELEASE_VERSION $BACKEND_NEXT_VERSION $RELEASE_ISSUE_URL $PUSH_TO_ORIGIN $WORKING_DIR
fi
if [ "$RELEASE_ETL" = true ] ; then
  $SCRIPT_DIR/release-etl.sh $ETL_RELEASE_VERSION $ETL_NEXT_VERSION $RELEASE_ISSUE_URL $PUSH_TO_ORIGIN $WORKING_DIR
fi
if [ "$RELEASE_IMPORTSCRIPTS" = true ] ; then
  $SCRIPT_DIR/release-import-scripts.sh $IMPORTSCRIPTS_RELEASE_VERSION $IMPORTSCRIPTS_NEXT_VERSION $RELEASE_ISSUE_URL $PUSH_TO_ORIGIN $WORKING_DIR
fi
if [ "$RELEASE_SCHEMA" = true ] ; then
  $SCRIPT_DIR/release-schema.sh $SCHEMA_RELEASE_VERSION $SCHEMA_NEXT_VERSION $RELEASE_ISSUE_URL $PUSH_TO_ORIGIN $WORKING_DIR
fi
if [ "$RELEASE_FRONTEND" = true ] ; then
  $SCRIPT_DIR/release-frontend.sh $FRONTEND_RELEASE_VERSION $FRONTEND_NEXT_VERSION $RELEASE_ISSUE_URL $PUSH_TO_ORIGIN $WORKING_DIR
fi

if [ "$WAIT_FOR_RELEASE_ARTIFACTS" = true ] ; then
  while :
  do
    date +"%Y-%m-%d %H:%M:%S Searching for release artifacts"
    BACKEND_PACKAGE_ID=$(curl -s "${GITLAB_BACKEND_API}/packages" | jq ".[] | select(.version == \"$BACKEND_RELEASE_VERSION\") | .id")
    FRONTEND_PACKAGE_ID=$(curl -s "${GITLAB_FRONTEND_API}/packages" | jq ".[] | select(.version == \"$FRONTEND_RELEASE_VERSION\") | .id")
    ETL_PACKAGE_ID=$(curl -s "${GITLAB_ETL_API}/packages" | jq ".[] | select(.version == \"$ETL_RELEASE_VERSION\") | .id")
    IMPORTSCRIPTS_PACKAGE_ID=$(curl -s "${GITLAB_IMPORTSCRIPTS_API}/packages" | jq ".[] | select(.version == \"$IMPORTSCRIPTS_RELEASE_VERSION\") | .id")
    SCHEMA_PACKAGE_ID=$(curl -s "${GITLAB_SCHEMA_API}/packages" | jq ".[] | select(.version == \"$SCHEMA_RELEASE_VERSION\") | .id")
    date +"%Y-%m-%d %H:%M:%S package ids: backend $BACKEND_PACKAGE_ID, etl $ETL_PACKAGE_ID, frontend $FRONTEND_PACKAGE_ID, import-scripts $IMPORTSCRIPTS_PACKAGE_ID, schema $SCHEMA_PACKAGE_ID"
    if [ -z "$BACKEND_PACKAGE_ID" ] || [ -z "$ETL_PACKAGE_ID" ] || [ -z "$FRONTEND_PACKAGE_ID" ] || [ -z "$IMPORTSCRIPTS_PACKAGE_ID" ] || [ -z "$SCHEMA_PACKAGE_ID" ] ; then
      echo "wait for packages"
      sleep 60
    else
      break
    fi
  done
fi

echo "Determine artifacts"
# Backend
BACKEND_PACKAGE_ID=$(curl "${GITLAB_BACKEND_API}/packages" | jq ".[] | select(.version == \"$BACKEND_RELEASE_VERSION\") | .id")
BACKEND_PACKAGE_FILE_ID=$(curl "${GITLAB_BACKEND_API}/packages/${BACKEND_PACKAGE_ID}/package_files" | jq ".[] | select(.file_name | endswith(\".war\")) | .id")
BACKEND_RELEASE_ARTIFACT_URL="https://gitlab.com/oersi/oersi-backend/-/package_files/${BACKEND_PACKAGE_FILE_ID}/download"
echo $BACKEND_RELEASE_ARTIFACT_URL

# Frontend
FRONTEND_PACKAGE_ID=$(curl "${GITLAB_FRONTEND_API}/packages" | jq ".[] | select(.version == \"$FRONTEND_RELEASE_VERSION\") | .id")
FRONTEND_PACKAGE_FILE_ID=$(curl "${GITLAB_FRONTEND_API}/packages/${FRONTEND_PACKAGE_ID}/package_files" | jq ".[] | select(.file_name == \"frontend.zip\") | .id")
FRONTEND_RELEASE_ARTIFACT_URL="https://gitlab.com/oersi/oersi-frontend/-/package_files/${FRONTEND_PACKAGE_FILE_ID}/download"
echo $FRONTEND_RELEASE_ARTIFACT_URL

# ETL
ETL_PACKAGE_ID=$(curl "${GITLAB_ETL_API}/packages" | jq ".[] | select(.version == \"$ETL_RELEASE_VERSION\") | .id")
ETL_PACKAGE_FILE_ID=$(curl "${GITLAB_ETL_API}/packages/${ETL_PACKAGE_ID}/package_files" | jq ".[] | select(.file_name == \"etl.zip\") | .id")
ETL_RELEASE_ARTIFACT_URL="https://gitlab.com/oersi/oersi-etl/-/package_files/${ETL_PACKAGE_FILE_ID}/download"
echo $ETL_RELEASE_ARTIFACT_URL

# IMPORTSCRIPTS
IMPORTSCRIPTS_PACKAGE_ID=$(curl "${GITLAB_IMPORTSCRIPTS_API}/packages" | jq ".[] | select(.version == \"$IMPORTSCRIPTS_RELEASE_VERSION\") | .id")
IMPORTSCRIPTS_PACKAGE_FILE_ID=$(curl "${GITLAB_IMPORTSCRIPTS_API}/packages/${IMPORTSCRIPTS_PACKAGE_ID}/package_files" | jq ".[] | select(.file_name == \"import-scripts.zip\") | .id")
IMPORTSCRIPTS_RELEASE_ARTIFACT_URL="https://gitlab.com/oersi/oersi-import-scripts/-/package_files/${IMPORTSCRIPTS_PACKAGE_FILE_ID}/download"
echo $IMPORTSCRIPTS_RELEASE_ARTIFACT_URL

# SCHEMA
SCHEMA_PACKAGE_ID=$(curl "${GITLAB_SCHEMA_API}/packages" | jq ".[] | select(.version == \"$SCHEMA_RELEASE_VERSION\") | .id")
SCHEMA_PACKAGE_FILE_ID=$(curl "${GITLAB_SCHEMA_API}/packages/${SCHEMA_PACKAGE_ID}/package_files" | jq ".[] | select(.file_name == \"schema.zip\") | .id")
SCHEMA_RELEASE_ARTIFACT_URL="https://gitlab.com/oersi/oersi-schema/-/package_files/${SCHEMA_PACKAGE_FILE_ID}/download"
echo $SCHEMA_RELEASE_ARTIFACT_URL

if [ -z "$BACKEND_PACKAGE_FILE_ID" ] ; then
  echo "Missing backend artifact for version $BACKEND_RELEASE_VERSION"
fi
if [ -z "$FRONTEND_PACKAGE_FILE_ID" ] ; then
  echo "Missing frontend artifact for version $FRONTEND_RELEASE_VERSION"
fi
if [ -z "$ETL_PACKAGE_FILE_ID" ] ; then
  echo "Missing etl artifact for version $ETL_RELEASE_VERSION"
fi
if [ -z "$IMPORTSCRIPTS_PACKAGE_FILE_ID" ] ; then
  echo "Missing import-scripts artifact for version $IMPORTSCRIPTS_RELEASE_VERSION"
fi
if [ -z "$SCHEMA_PACKAGE_FILE_ID" ] ; then
  echo "Missing schema artifact for version $SCHEMA_RELEASE_VERSION"
fi
if [ -z "$BACKEND_PACKAGE_FILE_ID" ] || [ -z "$FRONTEND_PACKAGE_FILE_ID" ] || [ -z "$ETL_PACKAGE_FILE_ID" ] || [ -z "$IMPORTSCRIPTS_PACKAGE_FILE_ID" ] || [ -z "$SCHEMA_PACKAGE_FILE_ID" ] ; then
  exit 1
fi

if [ "$RELEASE_BACKEND" = true ] && [ "$PUSH_TO_ORIGIN" = true ] ; then
  curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
       --data "{ \"name\": \"$BACKEND_RELEASE_VERSION\", \"tag_name\": \"$BACKEND_RELEASE_VERSION\", \"description\": \"Release $BACKEND_RELEASE_VERSION\", \"milestones\": [\"$MILESTONE\"], \"assets\": { \"links\": [{ \"name\": \"package\", \"url\": \"$BACKEND_RELEASE_ARTIFACT_URL\", \"filepath\": \"/package\", \"link_type\":\"package\" }] } }" \
       --request POST "$GITLAB_BACKEND_API/releases"
fi
if [ "$RELEASE_ETL" = true ] && [ "$PUSH_TO_ORIGIN" = true ] ; then
  curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
       --data "{ \"name\": \"$ETL_RELEASE_VERSION\", \"tag_name\": \"$ETL_RELEASE_VERSION\", \"description\": \"Release $ETL_RELEASE_VERSION\", \"milestones\": [\"$MILESTONE\"], \"assets\": { \"links\": [{ \"name\": \"package\", \"url\": \"$ETL_RELEASE_ARTIFACT_URL\", \"filepath\": \"/package\", \"link_type\":\"package\" }] } }" \
       --request POST "$GITLAB_ETL_API/releases"
fi
if [ "$RELEASE_IMPORTSCRIPTS" = true ] && [ "$PUSH_TO_ORIGIN" = true ] ; then
  curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
       --data "{ \"name\": \"$IMPORTSCRIPTS_RELEASE_VERSION\", \"tag_name\": \"$IMPORTSCRIPTS_RELEASE_VERSION\", \"description\": \"Release $IMPORTSCRIPTS_RELEASE_VERSION\", \"milestones\": [\"$MILESTONE\"], \"assets\": { \"links\": [{ \"name\": \"package\", \"url\": \"$IMPORTSCRIPTS_RELEASE_ARTIFACT_URL\", \"filepath\": \"/package\", \"link_type\":\"package\" }] } }" \
       --request POST "$GITLAB_IMPORTSCRIPTS_API/releases"
fi
if [ "$RELEASE_SCHEMA" = true ] && [ "$PUSH_TO_ORIGIN" = true ] ; then
  curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
       --data "{ \"name\": \"$SCHEMA_RELEASE_VERSION\", \"tag_name\": \"$SCHEMA_RELEASE_VERSION\", \"description\": \"Release $SCHEMA_RELEASE_VERSION\", \"milestones\": [\"$MILESTONE\"], \"assets\": { \"links\": [{ \"name\": \"package\", \"url\": \"$SCHEMA_RELEASE_ARTIFACT_URL\", \"filepath\": \"/package\", \"link_type\":\"package\" }] } }" \
       --request POST "$GITLAB_SCHEMA_API/releases"
fi
if [ "$RELEASE_FRONTEND" = true ] && [ "$PUSH_TO_ORIGIN" = true ] ; then
  curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
       --data "{ \"name\": \"$FRONTEND_RELEASE_VERSION\", \"tag_name\": \"$FRONTEND_RELEASE_VERSION\", \"description\": \"Release $FRONTEND_RELEASE_VERSION\", \"milestones\": [\"$MILESTONE\"], \"assets\": { \"links\": [{ \"name\": \"package\", \"url\": \"$FRONTEND_RELEASE_ARTIFACT_URL\", \"filepath\": \"/package\", \"link_type\":\"package\" }] } }" \
       --request POST "$GITLAB_FRONTEND_API/releases"
fi

$SCRIPT_DIR/release-setup.sh $RELEASE_VERSION $NEXT_VERSION $RELEASE_ISSUE_URL $PUSH_TO_ORIGIN $WORKING_DIR $BACKEND_RELEASE_ARTIFACT_URL $ETL_RELEASE_ARTIFACT_URL $FRONTEND_RELEASE_ARTIFACT_URL $IMPORTSCRIPTS_RELEASE_ARTIFACT_URL
curl --header 'Content-Type: application/json' --header "PRIVATE-TOKEN: $GITLAB_ACCESS_TOKEN" \
     --data "{ \"name\": \"$RELEASE_VERSION\", \"tag_name\": \"$RELEASE_VERSION\", \"description\": \"Release $RELEASE_VERSION\", \"milestones\": [\"$MILESTONE\"] }" \
     --request POST "$GITLAB_SETUP_API/releases"
