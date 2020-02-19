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

class TagPipeline(object):
    def process_item(self, item, spider):
        if item['tags']:
            item['tags'] = item['tags'].replace(" ", ",")
            return item

class NormLinksPipeline(object):
    def process_item(self, item, spider):
        print("Items is: ", item)
        if spider.name == "zoerr_spider":
            return item
        elif spider.name == "oernds_spider":
            return item
        elif item['url']:
            if not any(x in item['url'] for x in ["http://", "https://"]):
                item['url'] = "https://" + item['url']
                return item
            else:
                return item

class NormLicensePipeline(object):
    def process_item(self, item, spider):
        if item['license']:
            if any(x in item["license"].lower() for x in ["cc_0", "cc 0" "cc0", "public domain", "publicdomain", "zero"]):
                item["license"] = "CC 0"
                return item
            elif all(x in item['license'].lower() for x in ["sa", "by"]) and not "nc" in item["license"].lower():
                item["license"] = "CC BY-SA"
                return item
            elif any(x in item['license'].lower() for x in ["sa", "nd", "nc"]) == False:
                item["license"] = "CC BY"
                return item
            elif all(x in item["license"].lower() for x in ["by","sa","nc"]) == True:
                item["license"] = "CC BY-SA-NC"
                return item
            elif all(x in item["license"].lower() for x in ["by", "nc", "nd"]) == True:
                item["license"] = "CC BY-NC-ND"
                return item
            elif "nd" and not "nc" in item["license"].lower():
                item["license"] = "CC BY-ND"
                return item
            elif "nc" in item['license'].lower() and (any(x in item['license'].lower() for x in ["nd", "sa"]) == False):
                item["license"] = "CC BY-NC"
                return item
            else:
                raise DropItem("Missing or unknown license in %s" % item)


class MySqlPipeline(object):

    def __init__(self):
        self.create_connection()

    def open_spider(self, spider):
        spider_name = spider.name
        print(spider_name)
        self.create_table(spider_name)

    def create_connection(self):
        self.conn = mysql.connector.connect(
            host = 'localhost',
            user = 'oerindex',
            passwd = 'oerindexpw',
            database = 'oerindex_db'
        )
        self.curr = self.conn.cursor()

    def create_table(self, spider_name):
        table = "metadata_lrmi"
        self.curr.execute("""create table IF NOT EXISTS """ + table + """(
            name text,
            about text,
            author text,
            publisher text,
            inLanguage text,
            accessibilityAPI text,
            accessibilityControl text,
            accessibilityFeature text,
            accessibilityHazard text,
            license text,
            timeRequired text,
            educationalRole text,
            alignmentType text,
            educationalFramework text,
            targetDescription text,
            targetName text,
            targetURL text,
            educationalUse text,
            typicalAgeRange text,
            interactivityType text,
            learningResourceType text,
            date_published text,
            url text,
            thumbnail text,
            tags text,
            source text,
            modificationDate datetime
        )""")

    def process_item(self, item, spider):
        self.store_db(item, spider)
        return item

    def store_db(self, item, spider):
        table = "metadata_lrmi"
        self.curr.execute("""insert into """ + table + """ values (%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s)""", (
            item['name'],
            item['about'],
            item['author'],
            item['publisher'],
            item['inLanguage'],
            item['accessibilityAPI'],
            item['accessibilityControl'],
            item['accessibilityFeature'],
            item['accessibilityHazard'],
            item['license'],
            item['timeRequired'],
            item['educationalRole'],
            item['alignmentType'],
            item['educationalFramework'],
            item['targetDescription'],
            item['targetName'],
            item['targetURL'],
            item['educationalUse'],
            item['typicalAgeRange'],
            item['interactivityType'],
            item['learningResourceType'],
            item['date_published'],
            item['url'],
            item['thumbnail'],
            item['tags'],
            item['source'],
            item['date_scraped']
        ))
        self.conn.commit()

