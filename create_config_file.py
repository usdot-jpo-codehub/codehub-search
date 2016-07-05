import requests
import json

# Read orgs in from file
orgs = []
f = open("orgs.txt", "r")
for line in iter(f):
    line = line.replace("\n", "")
    orgs.append(line)
    
f.close()

# Create dictionary to map orgs with their repos
org_dict = {}

# Loop through each organization 
for org in orgs:
    r = requests.get('https://api.github.com/orgs/' + org + '/repos')
    
    # Load orgs API response into list
    orgs_response = json.loads(r.text)
    
    # Make repos list to be added to org dictionary
    repos = []
    
    # Create list of repos under an org
    for repo in orgs_response:
        repos.append(repo['name'].encode('utf-8'))
        
    # Map repos to org
    org_dict[org] = repos

# Beginning of the config file template
template = str("input {\n    http_poller {\n        urls => {\n")

# Add each URL that Logstash needs to reach out to in the config file
new_str = template
for org in orgs:
    for repo in org_dict[org]:
        # Get README in encoded form
        s = str("            \"" + org + "_" + repo +"\" => \"" + "https://api.github.com/repos/" + org + "/"+ repo +"/contents/README.md\"\n")
        # Or get raw README
        # s = str("            \"" + org + "_" + repo +"\" => \"" + "https://raw.githubusercontent.com/" + org + "/"+ repo +"/master/README.md\"\n")
        new_str = new_str + s

# End of the config file template
closing_input = "        }\n        request_timeout => 30\n        interval => 86400\n        codec => json\n    }\n}\n"
filter_template = "filter {\n    ruby {\n        init => \"require 'base64'\"\n        code => \"event['content'] = Base64.decode64(event['content']) if event.include?('content'); result = event['url'].match(/https:\/\/api.github.com\/repos\/(\S+)\/(\S+)\/contents/); org, repo = result.captures; event['organization'] = org; event['repository'] = repo\"\n    }\n}\n"
output_template = "output {\n    elasticsearch { index => \"readmes\" }\n    stdout {}\n}"
final_str = new_str + closing_input + filter_template + output_template

# Write the config file to a file
conf_file = open("logstash.conf", "w")
conf_file.write(final_str)
conf_file.close()