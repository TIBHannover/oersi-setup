#!/bin/bash

echo "import $@"

for spider in "$@"
do
  if [ -f "oer_scrapy/spiders/${spider}_spider.py" ]
  then
    echo "import spider ${spider}_spider"
    source oermetadata_harvester_scrapy/bin/activate && scrapy crawl ${spider}_spider
  else
    echo "${spider}_spider does not exist -> stop import"
    exit 1
  fi
done
