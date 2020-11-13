# -*- coding: utf-8 -*-

# Define your item pipelines here
#
# Don't forget to add your pipeline to the ITEM_PIPELINES setting
# See: https://docs.scrapy.org/en/latest/topics/item-pipeline.html

from scrapy.exceptions import DropItem
import json
import re
from w3lib.html import replace_escape_chars
import mysql.connector
import requests
from mapping_data import populate_json

# defining the api-endpoint
API_ENDPOINT = "http://localhost:8080/oersi/api/metadata"

# your API key here
headers = {
    "content-type": "application/json",
    "authorization": "Basic dGVzdDp0ZXN0"
}


class OerScrapyPipeline(object):
    def process_item(self, item, spider):
        return item


class JoinLongWhiteSpaceStringsPipeline(object):
    def process_item(self, item, spider):
        if spider.name == "zoerr_spider":
            return item
        if spider.name == "oernds_spider":
            return item
        if spider.name == "hhu_spider":
            return item
        if item['author']:
            item['author'] = re.sub('  +', ', ', item['author'])
            item['tags'] = " ".join(item['tags'].split())
            return item
        return item


class TagPipeline(object):
    def process_item(self, item, spider):
        if item['tags']:
            item['tags'] = item['tags'].replace(" ", ",")
            return item
        return item


class NormLinksPipeline(object):
    def process_item(self, item, spider):
        print("Items is: ", item)
        if item['learningResourceType'] and item['learningResourceType'].strip() == "":
            item['learningResourceType'] = "https://w3id.org/kim/hcrt/other"
        if spider.name == "zoerr_spider":
            return item
        elif spider.name == "oernds_spider":
            return item
        elif item['url']:
            if not any(x in item['url'] for x in ["http://", "https://"]):
                item['url'] = "https://" + item['url'].strip()
                return item
            else:
                item['url'] = item['url'].strip()
                return item
        else:
            return item


class NormLicensePipeline(object):
    def process_item(self, item, spider):
        if item['license']:
            if any(x in item["license"].lower() for x in
                   ["cc_0", "cc 0" "cc0", "public domain", "publicdomain", "zero"]):
                item["license"] = "https://creativecommons.org/licenses/by/4.0"
                return item
            elif all(x in item['license'].lower() for x in ["sa", "by"]) and not "nc" in item["license"].lower():
                item["license"] = "https://creativecommons.org/licenses/by-sa/4.0"
                return item
            elif any(x in item['license'].lower() for x in ["sa", "nd", "nc"]) == False:
                item["license"] = "https://creativecommons.org/licenses/by/4.0"
                return item
            elif all(x in item["license"].lower() for x in ["by", "sa", "nc"]) == True:
                item["license"] = "https://creativecommons.org/licenses/by-nc/4.0"
                return item
            elif all(x in item["license"].lower() for x in ["by", "nc", "nd"]) == True:
                item["license"] = "https://creativecommons.org/licenses/by-nc-nd/4.0"
                return item
            elif "nd" and not "nc" in item["license"].lower():
                item["license"] = "https://creativecommons.org/licenses/by-nd/4.0"
                return item
            elif "nc" in item['license'].lower() and (any(x in item['license'].lower() for x in ["nd", "sa"]) == False):
                item["license"] = "https://creativecommons.org/licenses/by-nc/4.0"
                return item
            else:
                item["license"] = "https://creativecommons.org/licenses/"
                raise DropItem("Missing or unknown license in %s" % item)


class NormLanguagePipeline(object):

    def process_item(self, item, spider):
        if item['inLanguage']:
            print("=============== LanguagessIF", item['inLanguage'])
            item['inLanguage'] = item['inLanguage'][:2].lower()
            return item
        else:
            item['inLanguage'] = "de"
            print("=============== LanguagessELSE", item['inLanguage'])
            return item


class NormDatePipeline(object):

    def process_item(self, item, spider):
        if item['date_published'] and (not (re.match("[0-9]{4}-[0-9]{2}-[0-9]{2}", item['date_published'][:10]))):
            print("=============== Invalid date -> clear date_published", item['date_published'])
            item['date_published'] = ""
            return item
        return item


class ServisePipeline(object):

    def process_item(self, item, spider):
        # self.store_db(item, spider)
        self.sent_thrue_api(item)
        return item

    def sent_thrue_api(self, item):
        x = requests.post(API_ENDPOINT, json=populate_json(item), headers=headers)
        print("Status Code= %s || Message %s " % (x.status_code, x.text))
        print(
            "=========================================================================================================================================")
        print(populate_json(item))
