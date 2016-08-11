import requests
import json
import base64
import re

client_id = ''
client_secret = ''
with open('github_auth.txt', 'r') as myfile:
    client_id=myfile.readline().replace('\n', '')
    client_secret=myfile.readline()

orgs = ["boozallen", "booz-allen-hamilton", "netflix", "elastic", "nodejs", "durandalproject", "jquery", "spring-projects", "18F"]

# Create dictionary to map orgs with their repos
org_dict = {}

# Create dictionary of dictionaries to store all data needed for repository
all_repos = {}

# Loop through each organization 
for org in orgs:
    r = requests.get('https://api.github.com/orgs/' + org + '/repos?client_id=' + client_id +'&client_secret=' + client_secret)
    
    # Load orgs API response into list
    orgs_response = json.loads(r.text)
    
    # Make repos list to be added to org dictionary
    repos = []
    
    # Create list of repos under an org
    for repo in orgs_response:
        # Create dictionary to store all pertinent repository data
        repo_info = {}
        
        repo_name = None
        org_name = None
        proj_desc = None
        proj_lang = None
        num_stars = None
        num_watchers = None
        num_forks = None
        
        # Extract repository information
        if repo['name'] is not None:
            repo_name = repo['name'].encode('utf-8')
        if repo['full_name'] is not None:
            org_name = repo['full_name'].encode('utf-8').split('/', 1)[0]
        if repo['description'] is not None:
            proj_desc = repo['description'].encode('utf-8')
        if repo['language'] is not None:
            proj_lang = repo['language'].encode('utf-8')
        if repo['stargazers_count'] is not None:
            num_stars = repo['stargazers_count']
        if repo['watchers_count'] is not None:
            num_watchers = repo['watchers_count']
        if repo['forks'] is not None:
            num_forks = repo['forks']
        
        # Call API to retrieve information about contributors (including anonymous contributors)
        r_contributors = requests.get('https://api.github.com/repos/' + org + '/' + repo_name + '/contributors?client_id=' + client_id + '&client_secret=' + client_secret + '&anon=true')
        
        # Load contributors API response into list
        num_contributors = 0
        num_commits = 0
        contributor_list = []
        if r_contributors.text != '':
            contributors_response = json.loads(r_contributors.text)
            
            for contributor in contributors_response:
                num_contributors += 1
                num_commits += contributor['contributions']
                contributor_info = {}
                # If user is anonymous, they do not have 
                if contributor['type'] == 'User':
                    contributor_info['username'] = contributor['login']
                    contributor_info['profile_url'] = contributor['html_url']
                else:
                    contributor_info['username'] = contributor['name']
                    contributor_info['profile_url'] = None
                
                contributor_list.append(contributor_info)
                 
            
        # Call API to retrive information about releases for repository
        r_releases = requests.get('https://api.github.com/repos/' + org + '/' + repo_name + '/releases?client_id=' + client_id + '&client_secret=' + client_secret)
        
        # Load releases API response into list
        releases_response = json.loads(r_releases.text)
        
        num_releases = 0
        for release in releases_response:
            num_releases += 1
            
        # Call API to retrive Readme
        r_readme = requests.get('https://api.github.com/repos/' + org + '/' + repo_name + '/contents/README.md?client_id=' + client_id + '&client_secret=' + client_secret)
        
        readme_contents = ''
        readme_url = ''

        readme_response = json.loads(r_readme.text)
        
        # Get contents of readme and download url of readme
        if not readme_response.has_key('documentation_url'):
            readme_contents = base64.b64decode(readme_response['content'])
            readme_url = readme_response['download_url']

        # Clean up and include project_name and project_description fields as input for autocomplete. Return only project_name as suggestions
        suggest = '{"input": ["' + re.sub("[^a-zA-Z0-9\s]", '', repo_name) + '", "' + re.sub("[^a-zA-Z0-9\s]", '', proj_desc) + '"], "output": "' + re.sub("[^a-zA-Z0-9-\s]", '', repo_name) + '"}'
        suggest = json.loads(suggest)
            
        # Store all repo information in dictionary
        repo_info['repository'] = repo_name
        repo_info['full_name'] = org_name + '/' + repo_name
        repo_info['project_name'] = repo_name
        repo_info['organization'] = org_name
        repo_info['project_description'] = proj_desc
        repo_info['language'] = proj_lang
        repo_info['stars'] = num_stars
        repo_info['watchers'] = num_watchers
        repo_info['contributors'] = num_contributors
        repo_info['commits'] = num_commits
        repo_info['releases'] = num_releases
        repo_info['forks'] = num_forks
        repo_info['rank'] = num_stars + num_watchers + num_contributors + num_commits + num_releases
        repo_info['content'] = readme_contents
        repo_info['readme_url'] = readme_url
        repo_info['contributors_list'] = contributor_list
        repo_info['suggest'] = suggest
        
        # Add repo info to dictionary of all repos
        all_repos[repo_name] = repo_info
        
# Add all repos to a master list to convert to json file        
repo_list = []
for repo in all_repos:
    repo_list.append(all_repos[repo])
    

with open("organization_info.json", "w") as outfile:
    json.dump(repo_list, outfile, indent=4)

