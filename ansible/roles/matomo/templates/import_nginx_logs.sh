#!/bin/bash
# {{ ansible_managed }}

# all nginx files from yesterday
date +"*** %Y-%m-%d %H:%M:%S start matomo import of nginx accesslog"
find /var/log/nginx -type f -name "access.log*[0-9]" -newermt `date --date="yesterday" +"%Y-%m-%d"` ! -newermt `date +"%Y-%m-%d"` | while read logfile ; do
  python {{ matomo_inst_dir }}/matomo/misc/log-analytics/import_logs.py --url=http://localhost:{{ matomo_port }}/matomo --idsite={{ matomo_init_website.idsite }} $logfile
done
date +"*** %Y-%m-%d %H:%M:%S stop matomo import of nginx accesslog"
