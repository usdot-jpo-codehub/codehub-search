# heimdall-search
The Heimdall Search subsystem that uses Elastic Search and other search and learning technologies

# Installation, configuration, and data load for Elasticsearch and Logstash
```
Prerequisites:
- logstash.conf, es_ls_driver.sh, es_ls_install.sh, es_ls_config.sh, es_ls_load_data.sh, and organization_info.json all located in /opt/heimdall

Installation:
1) Run the shell script driver to kick off installation, configuration, and data load for Elasticsearch and Logstash 
	$ sh ./es_ls_driver.sh
2) Once everything has run, Cntl-C to kill Logstash to prevent it from trying to continually index data
	- This is a temporary solution until we have Logstash running upsert queries
```

# Elasticsearch installation (by hand)
```
1) Download and install the Public Signing Key:
	$ sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
2) Create a new yum repository file for Elasticsearch. Note that this is a single command:
	$ echo '[elasticsearch-2.x]
	name=Elasticsearch repository for 2.x packages
	baseurl=http://packages.elastic.co/elasticsearch/2.x/centos
	gpgcheck=1
	gpgkey=http://packages.elastic.co/GPG-KEY-elasticsearch
	enabled=1
	' | sudo tee /etc/yum.repos.d/elasticsearch.repo
3) And your repository is ready for use. You can install it with:
	$ sudo yum -y install elasticsearch
4) Elasticsearch is now installed. Let's edit the configuration:
	$ sudo vi /etc/elasticsearch/elasticsearch.yml
5) Restrict outside access to Elasticsearch instance so outsiders can't read data or shutdown cluster through HTTP API. Uncomment line that specifies network.host and replace IP with 0.0.0.0
6) Save and exit elasticsearch.yml
6a) If you want Elasticsearch to automatically start during boot up:
	$ chkconfig --add elasticsearch
7) Start Elasticsearch
	$ sudo /etc/init.d/elasticsearch start
	OR
	$ sudo service elasticsearch start
8) Test it out by running the following:
	$ curl 'http://localhost:9200/?pretty'
You should see a response like: 
{
  "name" : "Dyna-Mite",
  "cluster_name" : "elasticsearch",
  "version" : {
    "number" : "2.3.3",
    "build_hash" : "218bdf10790eef486ff2c41a3df5cfa32dadcfde",
    "build_timestamp" : "2016-05-17T15:40:04Z",
    "build_snapshot" : false,
    "lucene_version" : "5.5.0"
  },
  "tagline" : "You Know, for Search"
}
9) To stop Elasticsearch:
	$ sudo /etc/init.d/elasticsearch stop
	OR
	$ sudo service elasticsearch stop
```
# Logstash installation (by hand)
```
1) Download and install the Public Signing Key (unless you already did it with ES installation):
	$ sudo rpm --import https://packages.elastic.co/GPG-KEY-elasticsearch
2) Create a new yum repository file for Logstash. Note that this is a single command:
	$ echo '[logstash-2.3]
	name=Logstash repository for 2.3.x packages
	baseurl=https://packages.elastic.co/logstash/2.3/centos
	gpgcheck=1
	gpgkey=https://packages.elastic.co/GPG-KEY-elasticsearch
	enabled=1
	' | sudo tee /etc/yum.repos.d/logstash.repo
3) And your repository is ready for use. You can install it with:
	$ sudo yum -y install logstash
4) Create logstash.conf in /etc/logstash/conf.d/
Example config (from tutorial https://www.elastic.co/guide/en/logstash/current/advanced-pipeline.html):
input {
    file {
        path => "/home/ec2-user/test.log"
        start_position => beginning
        ignore_older => 0
    }
}
filter { 
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    geoip {
        source => "clientip"
    }
}
output {
    elasticsearch {}
    stdout {}
}
5) To run logstash (specify config file with -f flag)
	$ /opt/logstash/bin/logstash -f /path/to/config.conf
```

# Python Ingestion Script Requirements
```
1) Use Python version >= 2.7
2) pip install requirements
3) github_auth.txt
	- First line of text file is client id
	- Second line is client secret
```
