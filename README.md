# heimdall-search
The Heimdall Search subsystem that uses Elastic Search and other search and learning technologies to perform intelligent deep search against project information in either text, numeric, or code format.

# Local Dev Install
## Install Search using Docker
1. `Clone` repository
1. `Install` [Docker Engine](https://docs.docker.com/) for your specific OS
1. `Build Search Image` by running `docker build -t stage/search ops` from project root
1. `Run Container` by typing: `docker run -d -p 9200:9200 --name stage-search-local stage/search`
1. `Open a browser` to `http://localhost:9200`
1. `Stop Container` type: `docker stop stage-search-local`
1. `Start Container` after the initial run type: `docker start stage-search-local`

# Production Install
`Docker coming soon!`

1. `Be Local` to the machine you're doing the install.
1. `Run Install Scripts`: `./ops/create-search-server-driver.sh`

# Load Initial Data
`Run Data Loading` scripts `./ops/load-index-data.sh <host URL or IP> <json data file>`

# Reload Data (drops index and data)
`Run Data Loading` scripts `./ops/reload-index-data.sh <host URL or IP> <json data file>`

