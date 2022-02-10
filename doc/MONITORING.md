# Monitoring

## Monitoring Import workflows

You can activate a monitoring of the etl / import-script processes and receive a daily report that includes number of sucesses and failures for each process.

### Requirements

`mail` (`mailutils`) needs to be available and configured on the system.

### Configuration

See [../ansible/roles/oer-search-index-etl/defaults/main.yml](../ansible/roles/oer-search-index-etl/defaults/main.yml)

* activate monitoring via `oerindex_monitoring: true`
* set sender address via `oerindex_monitoring_from_address: your-sender@somewhere`
* set recipient addess via `oerindex_monitoring_recipients: your-recipient1@somewhere,your-recipient2@somewhere`
* (optional) set failure-bound for the report via `oerindex_monitoring_import_failure_bound: <number>` (send ETL report when number of failures is greater than or equal to this bound, default: `0`)

## Metadata statistics

To avoid unnecessary amounts of data, small statistics of the existing metadata in the index can be activated. Thus not all old data must be kept up to pursue the development of the metadata. The statistic is stored in elasticsearch (index `oer_data_statistics`) and determines per source (and total) how many data are available and if certain fields are set.

It is only checked if the field is set, not how many values are present in the field.

If an OER is present in several sources, it can come to interactions in the statistics (in the data it is not recognizable from which source a field comes).

### Configuration

See [../ansible/roles/index-scripts/defaults/main.yml](../ansible/roles/index-scripts/defaults/main.yml)

* activate statistics via `oerindex_statistics: true`
* set fields to include in `oerindex_statistics_fields`
* schedule process via `oerindex_statistics_schedule_*` variables
