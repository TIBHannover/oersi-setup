import re
import json

def populate_json(item):
    return {
        "creator": [
            {
                "name": item["author"],
                "type": "Person"
            }
        ],
        "dateCreated": item["date_published"][:10],
        "datePublished": item["date_published"][:10],
        "description": item["about"],
        "id": item["url"],
        "image": item["thumbnail"],
        "inLanguage": item["inLanguage"],
        "learningResourceType": {
            "id": item["learningResourceType"]
        },
        "license": item["license"],
        "mainEntityOfPage": {
            "id": item["url"]
        },
        "name": item["name"]
    }


