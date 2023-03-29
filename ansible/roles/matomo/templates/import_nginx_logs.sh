#!/bin/bash
# {{ ansible_managed }}

# all nginx files from yesterday
date +"*** %Y-%m-%d %H:%M:%S start matomo import of nginx accesslog"
find /var/log/nginx -type f -name "access.log*[0-9]" -newermt `date --date="yesterday" +"%Y-%m-%d"` | while read logfile ; do
  # use custom regex to support use of http_x_forwarded_for (original IP behind reverse proxy)
  #python3 {{ matomo_inst_dir }}/matomo/misc/log-analytics/import_logs.py --url=http://localhost:{{ matomo_port }}/matomo --idsite={{ matomo_init_website.idsite }} $logfile
  python3 {{ matomo_inst_dir }}/matomo/misc/log-analytics/import_logs.py --url=http://localhost:{{ matomo_port }}/matomo --idsite={{ matomo_init_website.idsite }} --log-format-regex='([\w*.:-]+)\s+\S+\s+(?P<userid>\S+)\s+\[(?P<date>.*?)\s+(?P<timezone>.*?)\]\s+"(?P<method>\S+)\s+(?P<path>.*?)\s+\S+"\s+(?P<status>\d+)\s+(?P<length>\S+)\s+"(?P<referrer>.*?)"\s+"(?P<user_agent>.*?)"\s+"(?P<ip>[\w*.:-]+)"' $logfile
done
date +"*** %Y-%m-%d %H:%M:%S stop matomo import of nginx accesslog"
