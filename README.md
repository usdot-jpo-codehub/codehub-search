# heimdall-search
The Heimdall Search subsystem that uses Elastic Search and other search and learning technologies to perform intelligent deep search against project information in either text, numeric, or code format.

# Local Dev Install
## Install Search using Docker
1. `Clone` repository
1. `Install` [Docker Engine](https://docs.docker.com/) for your specific OS
1. `Build Search Image`: `./ops/create-search-docker-image.sh`
1. `Create and Run Container`: `./ops/create-run-search-container.sh`
1. `Open a browser` to `http://localhost:9200`
1. `Stop Container` type: `docker stop stage-search`
1. `Start Container` after the initial run type: `docker start stage-search`

# Production Install
`Docker coming soon!`

1. `Be Local` to the machine you're doing the install.
1. `Run Install Scripts`: `./ops/create-search-server-driver.sh`

# Load Initial Data
`Run Data Loading` scripts `./ops/load-index-data.sh <host URL or IP> <json data file>`

# Reload Data (drops index and data)
`Run Data Loading` scripts `./ops/reload-index-data.sh <host URL or IP> <json data file>`
