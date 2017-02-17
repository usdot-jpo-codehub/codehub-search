ctx._source.userForkedRepos = (!ctx._source.userForkedRepos)?[]:ctx._source.userForkedRepos
def combined = ctx._source.userForkedRepos +[userForkedReposData]
def filtered = combined.unique()
ctx._source.userForkedRepos = (ctx._source.userForkedRepos)? filtered : [userForkedReposData]
