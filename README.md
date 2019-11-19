# codehub-search

This repository contains the ITS CodeHub ElasticSearch schema documents as well as a variety of helpful example scripts.

## Getting Started

This repository is broken down into two folders: schemas and scripts. The schemas directory contains the ElasticSearch schemas that ITS CodeHub uses to organize and manage data. The scripts directory provides guidance for how to interact with ElasticSearch, particularly running ES in Docker, creating indexes, listing them, and using elasticsearch-dump for data management.

### Prerequisites

The schemas and scripts in this repository are designed to run with an ElasticSearch instance of version 7.4.x, either running locally, in Docker, or deployed using AWS ElasticSearch Service.

The following tools are required to use the provided scripts:

- [cURL](https://curl.haxx.se/)
- [Docker](https://www.docker.com/)
- [ElasticDump](https://github.com/taskrabbit/elasticsearch-dump) (either installed locally using NPM or prebuilt Docker image)

### Schemas

There are three schema files:

1. `schemas/projects.json` - This stores general GitHub repository metadata

2. `schemas/code.json` - This stores CodeHub specific information about the repositories

3. `schemas/repos.json` - This stores CodeHub repository management information

### Scripts

There are several scripts provided in the scripts directory. 

**Note: These scripts all require that the URL of your ElasticSearch instance be set in the `ELASTICSEARCH_URL` environment variable.**

1. `run-docker-es7.sh` - Runs ElasticSearch 7.4.1 locally as a Docker container.

2. `create-indexes.sh` - Takes all three index files from the schemas directory and creates them in your ES instance.

3. `list-indexes.sh` - Shows a simple cURL command that can be used to return information about existing ES indexes.

4. `elasticdump-output-data.sh` - Gives an example of how to use NPM-installed elasticsearch-dump to dump data from ES into a file. Swap the input and output to reverse and upload data from a file into ES. Swap index name to change which index you are accessing. See script comments for more information.

5. `elasticdump-output-data-docker.sh` - Gives an example of how to use Dockerized elasticsearch-dump to dump data from ES into a file. Swap the input and output to reverse and upload data from a file into ES. Swap index name to change which index you are accessing. See script comments for more information.

## Contributing

Please contribute to this repository using pull requests or submit questions or problems using GitHub issues.

## Authors

Built by the ITS CodeHub team.

## License

This project is licensed under the Apache 2.0 License - see the [LICENSE](LICENSE) file for details

## Acknowledgments

Acknowledgment given to [TaskRabbit's elasticsearch-dump](https://github.com/taskrabbit/elasticsearch-dump) tool.

## Code.gov Registration Info

Agency: DOT

Short Description: ElasticSearch scripts and schemas for ITS CodeHub.

Status: Released

Tags: codehub, elasticsearch, scripts

Labor hours: 0

Contact Name: Brian Brotsos

Contact Phone:
