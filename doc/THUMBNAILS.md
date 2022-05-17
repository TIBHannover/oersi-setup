# Thumbnail Generator

Sometimes OERSI resources do not have an image or the images are very large and therefore cause unnecessary overhead when rendering in the frontend.

For this reason there is a small tool that allows to provide thumbnails in a uniform format for each OERSI resource. The tool first converts the images from the `image` property of each resource into a uniform wepb-image, if the field is set. If the field is not set, then the tool tries to create an html preview image of the resource (using an existing [splash](https://splash.readthedocs.io/en/stable/) service). The OERSI frontend rendering will then use these thumbnails if they exist - fallback is the `image` URL.

To activate this feature, set `oerindex_features_generate_thumbnails` to `true` and set the URL to your splash-service in `thumbnail_splash_base_url`.

The creation of thumbnails is cron controlled. There is a cron entry for incremental creation (existing thumbnails are kept) - intended for daily execution. Then there is another cron entry for the complete creation (existing thumbnails are overwritten) - intended for weekly execution.
