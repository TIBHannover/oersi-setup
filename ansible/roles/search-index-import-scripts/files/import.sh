#!/bin/bash

echo "import $@"

for source in "$@"
do
  if [ -f "${source}Import.py" ]
  then
    echo "import source ${source}"
    python3 ${source}Import.py
  else
    echo "${source}Import.py does not exist -> stop import"
    exit 1
  fi
done
