# -*- coding: utf-8 -*-
"""
For loading the model and saving the data.

If the model gets to be too large, or take too long to train,
having this in two files will be of use.

May change later for automation purposes.
"""
import numpy as np
import re
from bs4 import BeautifulSoup
import pandas as pd
from gensim import utils
from gensim.models.doc2vec import TaggedDocument
from gensim.models import Doc2Vec
from nltk.corpus import stopwords

model = Doc2Vec.load('~/Documents/Stage_Doc2Vec_Model.d2v')

"""
Document similarity query example

I want the actual similar document and not an out of bag query.

Unseen_docs shouldn't be used for this. docvecs.most_similar should.

The labels should also be changed to reference the full_names.
"""

train = pd.read_json("~/Downloads/corpus_2.json")

##############Parsing the dataset
temp = pd.DataFrame(train["hits"]["hits"])
id_list = temp["_id"]
temp = temp["_source"]
new = temp.to_json()
train = pd.read_json(new, orient='columns').T
################Done

print id_list
name_list = train["full_name"]
#create a list for the similar tuples created by doc2vec
sim_list = []
for i in xrange(id_list.size):    
    #take an id in the list
    entry = id_list[i]
    #give a tuple for the most similar document from that entry
    #returns the label and the similarity.
    sims =  model.docvecs.most_similar(entry, topn=10)
    #append it to a list
    sim_list.append(sims)

#putting it into a dataframe, just for properly parsing the data.
top_10_array = pd.DataFrame({"model_data" : sim_list}, index=id_list)

#saving the model.
top_10_array.to_json('~/Documents/Stage_top_10_array_doc2vec.json')

#print top_10_array.to_json()