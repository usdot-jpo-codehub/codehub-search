import requests
import json
import os

ELASTICSEARCH_API_BASE_URL = os.environ.get('ELASTICSEARCH_API_BASE_URL')
JSONHeader={'content-type':'application/json'}

##########

INDEX_ALIAS_NAME = 'INDEX_ALIAS_NAME' # this name of the index that points to the current version of the schema
SOURCE_INDEX = 'SOURCE_INDEX' # old index name, including version
TARGET_INDEX = 'TARGET_INDEX' # new index name, including version
MAPPING_FILE_PATH = '../schemas/MAPPING_FILE.json'

def migrateData(source_dataset):
	migratedDataset = {}

	# MIGRATION LOGIC GOES HERE

	# Sample logic to copy dataset with no changes
	migratedDataset = source_dataset

	return migratedDataset


##########

def createNewIndex(target_index, mapping_file_path):

	with open(mapping_file_path) as f:
		mappingJSON = json.load(f)

	response = requests.put(ELASTICSEARCH_API_BASE_URL + '/' + target_index, data=json.dumps(mappingJSON), headers=JSONHeader)
	print(response.text)

def getIndices():
	result = []
	response = requests.get(ELASTICSEARCH_API_BASE_URL + '/_cat/indices?format=JSON')
	
	if (response.status_code == 200):
		responseJSON = json.loads(response.text)
		for index in responseJSON:
			result.append({'name': index['index'], 'docCount': index['docs.count']})

	return result

def getIndexDocs(source_index):
	result = []

	response = requests.get(ELASTICSEARCH_API_BASE_URL + '/' + source_index + '/_search?size=10000')

	if (response.status_code == 200):
		responseJSON = json.loads(response.text)
		hits = responseJSON['hits']['hits']

		for hit in hits:
			result.append({'id': hit['_id'], 'source': hit['_source']})

	else:
		print('bad things have happened...')

	return result

def loadDataset(targetIndex, datasets):
	result = ''

	for entry in datasets:
		indexStr = json.dumps({'create': {'_index': targetIndex, '_id': entry['id']}}) + '\r\n'
		result += indexStr
		dataStr = json.dumps(entry['source']) + '\r\n'
		result += dataStr

	response = requests.post(ELASTICSEARCH_API_BASE_URL + '/_bulk', data=result, headers=JSONHeader)
	print(response.text)

def updateAlias(index_alias_name, target_index):
	payload = {}
	payload['actions'] = []
	payload['actions'].append({'remove' : { 'index': '*', 'alias': index_alias_name}})
	payload['actions'].append({'add' : { 'index': target_index, 'alias': index_alias_name}})

	response = requests.post(ELASTICSEARCH_API_BASE_URL + '/_aliases', data=json.dumps(payload), headers=JSONHeader)


def doesIndexExist(target_index):
	existingIndices = getIndices()

	for index in existingIndices:
		if index['name'] == TARGET_INDEX:
			return True

	return False


if doesIndexExist(TARGET_INDEX) == False:
	sourceDataset = getIndexDocs(SOURCE_INDEX)
	migratedDataset = migrateData(sourceDataset)
	createNewIndex(TARGET_INDEX, MAPPING_FILE_PATH)
	loadDataset(TARGET_INDEX, migratedDataset)
	updateAlias(INDEX_ALIAS_NAME, TARGET_INDEX)

else:
	print("Index already exists")
	# throw a fit and stop the deployment
