import base64
from datetime import datetime
import io
import requests
import getopt, os, sys
from PIL import Image, ImageOps
from svglib.svglib import svg2rlg
from reportlab.graphics import renderPM


oersi_search_api_url = "{{ oerindex_backend_searchapi_url }}/{{ elasticsearch_oer_index_alias_name }}/_search"
thumbnail_webserver_path = "{{ thumbnail_webserver_instdir }}/"
image_width = {{ thumbnail_image_width }}
image_height = {{ thumbnail_image_height }}
image_creation_method = "{{ thumbnail_creation_method }}"
splash_base_url = "{{ thumbnail_splash_base_url }}"
image_output_format = "webp" # | "PNG" | "JPEG"


class OersiDataLoader:
    def __init__(self):
        self.image_urls_loaded = False
        self.image_urls_after_key = None
        self.ids_without_image_loaded = False
        self.ids_without_image_after_key = None
    
    def load_next_image_urls(self):
        if self.image_urls_loaded:
            return None
        headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
        data = {
            "size": 0,
            "aggregations": {
                "images": {
                    "composite": {
                        "size": 2000,
                        "sources": [
                            {"keyword": {"terms": {"field": "image"}}}
                        ]
                    },
                    "aggregations": {
                        "identifier": {
                            "terms": {
                                "field": "id"
                            }
                        }
                    }
                }
            }
        }
        if self.image_urls_after_key:
            data["aggregations"]["images"]["composite"]["after"] = self.image_urls_after_key

        result = requests.post(oersi_search_api_url, headers=headers, json=data)
        json_result = result.json()

        if "after_key" in json_result["aggregations"]["images"]:
            self.image_urls_after_key = json_result["aggregations"]["images"]["after_key"]
        else:
            self.image_urls_loaded = True

        return list(
            filter(
                None,
                [{"image": b["key"]["keyword"], "identifier": [a["key"] for a in b["identifier"]["buckets"]]} for b in json_result["aggregations"]["images"]["buckets"]]
            )
        )

    def load_next_ids_without_image(self):
        if self.ids_without_image_loaded:
            return None
        headers = {'Content-type': 'application/json', 'Accept': 'application/json'}
        data = {
            "size": 0,
            "query": {
                "bool": {
                    "must_not": {
                        "exists": {"field": "image"}
                    }
                }
            },
            "aggregations": {
                "identifier": {
                    "composite": {
                        "size": 2000,
                        "sources": [
                            {"keyword": {"terms": {"field": "id"}}}
                        ]
                    }
                }
            }
        }
        if self.ids_without_image_after_key:
            data["aggregations"]["identifier"]["composite"]["after"] = self.ids_without_image_after_key

        result = requests.post(oersi_search_api_url, headers=headers, json=data)
        json_result = result.json()

        if "after_key" in json_result["aggregations"]["identifier"]:
            self.ids_without_image_after_key = json_result["aggregations"]["identifier"]["after_key"]
        else:
            self.ids_without_image_loaded = True

        return list(
            filter(
                None,
                [b["key"]["keyword"] for b in json_result["aggregations"]["identifier"]["buckets"]]
            )
        )


class OersiThumbnailCreator:
    def __init__(self, skip_for_existing_files):
        self.skip_for_existing_files = skip_for_existing_files
        self.method = {
            "NEAREST": Image.Resampling.NEAREST,
            "BILINEAR": Image.Resampling.BILINEAR,
            "BICUBIC": Image.Resampling.BICUBIC,
            "LANCZOS": Image.Resampling.LANCZOS
        }.get(image_creation_method)

    def __convert_image_url_to_thumbnail__(self, image_url, image_url_params, oersi_ids):
        outfiles = [thumbnail_webserver_path + base64.urlsafe_b64encode(oersi_id.encode()).decode("ascii") + "." + image_output_format.lower() for oersi_id in oersi_ids]
        if self.skip_for_existing_files:
            for outfile in outfiles:
                if os.path.isfile(outfile):
                    print("Skipping existing file " + outfile)
            outfiles = [f for f in outfiles if not os.path.isfile(outfile)]
            if not outfiles:
                return
        image_respone = requests.get(image_url, params=image_url_params)
        image_bytes = io.BytesIO(image_respone.content)
        if "Content-Type" in image_respone.headers and image_respone.headers["Content-Type"] == "image/svg+xml":
            print("Received svg -> convert")
            d = svg2rlg(image_bytes)
            factor = max([image_width / d.width, image_height / d.height])
            d.width = d.width * factor
            d.height = d.height * factor
            d.scale(factor, factor)
            image_bytes = io.BytesIO(renderPM.drawToString(d, fmt='PNG'))
        with Image.open(image_bytes) as im:
          thumbnail = ImageOps.fit(im, (image_width, image_height), self.method)
          for outfile in outfiles:
            thumbnail.save(outfile, image_output_format)
            print("Created " + outfile)

    def convert_oersi_image_to_thumbnail(self, urls):
        try:
          self.__convert_image_url_to_thumbnail__(urls["image"], {}, urls["identifier"])
        except Exception as e:
          print(e)
          print("cannot convert to thumbnail for " + urls["image"])
          for identifier in urls["identifier"]:
              self.create_splash_thumbnail_for_url(identifier)

    def create_splash_thumbnail_for_url(self, url):
        print("Creating splash thumbnail for " + url)
        # curl --output test.png 'http://oerrs01.develop.service.tib.eu:8050/render.png?url=your-url&width=320&height=240'
        # https://splash.readthedocs.io/en/stable/api.html#render-png
        splash_image_url = splash_base_url + "/render.png"
        splash_params = {"engine": "chromium", "url": url, "width": image_width, "height": image_height}
        try:
          self.__convert_image_url_to_thumbnail__(splash_image_url, splash_params, [url])
        except Exception as e:
          print(e)
          print("cannot create splash thumbnail for " + url)


def generate_thumbnails_for_records_without_image(skip_existing):
    oersi_data_loader = OersiDataLoader()
    thumbnail_creator = OersiThumbnailCreator(skip_existing)
    oersi_urls_without_image = oersi_data_loader.load_next_ids_without_image()
    while oersi_urls_without_image is not None:
        print("Processing next " + str(len(oersi_urls_without_image)) + " urls without image")
        for url in oersi_urls_without_image:
            thumbnail_creator.create_splash_thumbnail_for_url(url)
        oersi_urls_without_image = oersi_data_loader.load_next_ids_without_image()


def generate_thumbnails_for_oersi_images(skip_existing):
    oersi_data_loader = OersiDataLoader()
    thumbnail_creator = OersiThumbnailCreator(skip_existing)
    oersi_image_data = oersi_data_loader.load_next_image_urls()
    while oersi_image_data is not None:
        print("Processing next " + str(len(oersi_image_data)) + " image urls")
        for urls in oersi_image_data:
            thumbnail_creator.convert_oersi_image_to_thumbnail(urls)
        oersi_image_data = oersi_data_loader.load_next_image_urls()


if __name__ == "__main__":
    try:
        opts, args = getopt.getopt(sys.argv[1:], "s", ["skip-existing"])
    except getopt.GetoptError as err:
        print(err)
        sys.exit(2)
    skip_existing = False
    for o, a in opts:
        if o in ("-s", "--skip-existing"):
            skip_existing = True

    start = datetime.today()
    print("Start " + start.strftime('%Y-%m-%d %H:%M:%S'))
    print("skip thumbnail-creation for already existing thumbnails: " + str(skip_existing))
    
    generate_thumbnails_for_records_without_image(skip_existing)
    generate_thumbnails_for_oersi_images(skip_existing)

    end = datetime.today()
    print("Done " + end.strftime('%Y-%m-%d %H:%M:%S') + " (duration: " + str(end - start) + ")")
