#!/bin/bash
#
# Builds a map "childId -> ParentId" for the given vocab-json-scheme that is needed in OERSI-frontend for hierarchical-filters.
#

if [ $# -lt 2 ]; then
  echo "Please specify the vocab-json-file and the output-file as parameter!"
  exit 1
fi

VOCAB_FILE=$1
OUTPUT_FILE=$2

PARENT_MAP="{}"
for ID in $(jq -r '.hasTopConcept[] | .. | .id? // empty' "${VOCAB_FILE}")
do
  for CHILD_ID in $(jq ".hasTopConcept[] | .. | select(.id? == \"$ID\") | select(has(\"narrower\")) | .narrower[].id" "${VOCAB_FILE}")
  do
    PARENT_MAP=$(echo "$PARENT_MAP" | jq --sort-keys ".$CHILD_ID =\"$ID\"")
  done
done

echo "$PARENT_MAP" > "$OUTPUT_FILE"
touch -r "$VOCAB_FILE" "$OUTPUT_FILE"
