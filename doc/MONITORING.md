# Monitoring

## Monitoring ETL workflows

You can activate a monitoring of the etl processes and receive a daily report that includes number of sucesses and failures for each process.

### Requirements

`mail` (`mailutils`) needs to be available and configured on the system.

### Configuration

See [../ansible/roles/oer-search-index-etl/defaults/main.yml](../ansible/roles/oer-search-index-etl/defaults/main.yml)

* activate monitoring via `oerindex_monitoring_etl: true`
* set sender address via `oerindex_monitoring_etl_from_address: your-sender@somewhere`
* set recipient addess via `oerindex_monitoring_etl_recipients: your-recipient1@somewhere,your-recipient2@somewhere`
* (optional) set failure-bound for the report via `oerindex_monitoring_etl_failure_bound: <number>` (send ETL report when number of failures is greater than or equal to this bound, default: `0`)
