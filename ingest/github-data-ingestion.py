import requests
import json
import base64
import re


def ingest_org_data(config):
    orgs = get_all_orgs(config)
    repos_result = []

    for org in orgs:
        repos_response = requests.get(org['repos_url'] + '?' + get_auth_http_params(config))
        repos = json.loads(repos_response.text)

        for repo in repos:
            repo_info = {}
            repo_name = None
            org_name = None
            proj_desc = None
            proj_lang = None
            num_stars = None
            num_watchers = None
            num_forks = None

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

            contributors = get_contributors_info(config, org, repo_name)
            num_releases = count_releases(config, org, repo_name)
            readme_results = get_readme_info(config, org, repo_name)

            repo_info['repository'] = repo_name
            repo_info['full_name'] = org_name + '/' + repo_name
            repo_info['project_name'] = repo_name
            repo_info['organization'] = org_name
            repo_info['project_description'] = proj_desc
            repo_info['language'] = proj_lang
            repo_info['stars'] = num_stars
            repo_info['watchers'] = num_watchers
            repo_info['contributors'] = contributors['num_contributors']
            repo_info['commits'] = contributors['num_commits']
            repo_info['releases'] = num_releases
            repo_info['forks'] = num_forks
            repo_info['rank'] = num_stars + num_watchers + contributors['num_contributors'] + contributors['num_commits'] + num_releases
            repo_info['content'] = readme_results['readme_contents']
            repo_info['readme_url'] = readme_results['readme_url']
            repo_info['contributors_list'] = contributors['contributors']
            repo_info['suggest'] = get_suggest_info(repo_name, proj_desc)

            repos_result.append(repo_info)

    write_data_to_file(config, repos_result)


def get_auth_http_params(config):
    if config['env'] == 'enterprise':
        return 'access_token=' + config['github_access_secret']
    else:
        return 'client_id=' + config['github_client_id'] + '&client_secret=' + config['github_access_secret']


def get_all_orgs(config):
    orgs_response = requests.get(config['github_url'] + '/organizations?' + get_auth_http_params(config))
    return json.loads(orgs_response.text)


#
# Calculate:
#   Number of Commits by all Contributors
#   Number of Contributors
#   List of Contributors
#
def get_contributors_info(config, org, repo_name):
    contribs_response = requests.get(config['github_url'] + '/repos/' + org['login'] + '/' + repo_name + '/contributors?anon=true&' + get_auth_http_params(config))

    num_contributors = 0
    num_commits = 0
    contributor_list = []
    if contribs_response.text != '':
        contributors = json.loads(contribs_response.text)

        for contributor in contributors:
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

    return {'num_commits': num_commits, 'num_contributors': num_contributors, 'contributors': contributor_list}


#
# Process README content and url
#
def get_readme_info(config, org, repo_name):
    readme_response = requests.get(config['github_url'] + '/repos/' + org['login'] + '/' + repo_name + '/contents/README.md?' + get_auth_http_params(config))
    readme_response = json.loads(readme_response.text)
    readme_results = {'readme_contents': '', 'readme_url': ''}

    if not readme_response.has_key('documentation_url'):
        readme_results['readme_contents'] = base64.b64decode(readme_response['content'])
        readme_results['readme_url'] = readme_response['download_url']

    return readme_results


def get_suggest_info(repo_name, proj_desc):
    suggest = '{"input": ["' + re.sub("[^a-zA-Z0-9\s]", '', repo_name) + '", "' + re.sub("[^a-zA-Z0-9\s]", '', proj_desc) + '"], "output": "' + re.sub("[^a-zA-Z0-9-\s]", '', repo_name) + '"}'
    return json.loads(suggest)


def count_releases(config, org, repo_name):
    releases = requests.get(config['github_url'] + '/repos/' + org['login'] + '/' + repo_name + '/releases?' + get_auth_http_params(config))
    releases = json.loads(releases.text)

    num_releases = 0
    for release in releases:
        num_releases += 1

    return num_releases

def write_data_to_file(config, repo_list):
    with open(config['data_output_filename'], "w") as outfile:
        json.dump(repo_list, outfile, indent=4)

#
# Input:
#   Config file with 3 values on separate lines.  No comments should be in the config file.
#       1: access token
#       2: output file name
#       3: github url
#
# Outputs as a List:
#   1: access token
#   2: output file name
#   3: github url
#
#
def read_config(conf_file):
    with open(conf_file, 'r') as config_file:
        results = config_file.read().splitlines()

    if results[0] == 'enterprise':
        return {'env': 'enterprise',
                'github_access_secret': results[1],
                'data_output_filename': results[2],
                'github_url': results[3]}
    else:
        return {'env': 'public',
                'github_client_id': results[1],
                'github_access_secret': results[2],
                'data_output_filename': results[3],
                'github_url': results[4]}

def main():
    config = read_config("ingest.conf")
    print("Ingesting data using this configuration: ", config)
    ingest_org_data(config)

if __name__ == "__main__":
    main()
