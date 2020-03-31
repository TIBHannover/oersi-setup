import re
import json

def populate_json(item):
    return {
        "authors": [
            {
                "familyName": item["author"].split()[1],
                "givenName": item["author"].split()[0],
                "gnd": " ",
                "orcid": " "
            }
        ],
        "didactics": {
            "audience": "",
            "educationalUse": item["educationalUse"],
            "interactivityType": item["interactivityType"],
            "timeRequired": item["timeRequired"]
        },
        "educationalResource": {
            "dateCreated": item["date_published"],
            "dateLastUpdated": item["date_published"],
            "datePublished": item["date_published"],
            "description": item["about"],
            "identifier": " ",
            "inLanguage": item["inLanguage"],
            "keywords": re.split("\s|(?<!\d)[,.](?!\d)", item["tags"]),
            "learningResourceType": item["learningResourceType"],
            "license": item["license"],
            "name": item["name"],
            "subject": "We don't have Subject now ",
            "thumbnailUrl": item["thumbnail"],
            "url": item["url"],
            "version": "1"
        },
        "institution": {
            "name": "OER ",
            "ror": "TIB-Hannover"
        },
        "source": item["source"]
    }


