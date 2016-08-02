# -*- coding: utf-8 -*-
"""
Document for creating the Stage model.
"""

import numpy as np
import re
from bs4 import BeautifulSoup
import pandas as pd
from gensim.models.doc2vec import TaggedDocument
from gensim.models import Doc2Vec #to train model
from nltk.corpus import stopwords #to remove stopwords
from textblob import TextBlob #for translations
import textblob

#load the data. the data is in json
train = pd.read_json("~/Downloads/corpus_2.json")

##############Parsing the dataset
temp = pd.DataFrame(train["hits"]["hits"])

#grab the id from the temp file.
id_list = temp["_id"]

temp = temp["_source"]
new = temp.to_json()
train = pd.read_json(new, orient='columns').T
################Done

#converting characters to strings.
train["full_name"] = train["full_name"].astype(str)
train["language"] = train["language"].astype(str)


"""To join the text from the two other fields"""
train['combined'] = train[["full_name", 'language', "project_description", "content"]].apply(lambda x: ' '.join(x), axis=1)

#needed more than the content from the dataframe.
documents = train["combined"].copy()

#use index as labels
labels_vec = id_list

#change documents and labels to numpy arrays for faster processing.
documents = np.asarray(documents)
labels_vec = np.asarray(labels_vec)
print labels_vec[0:4]

#keep @ signs in.
def review_to_words(review, remove_stopwords=True ):
    # Function to convert a document to a sequence of words,
    # optionally removing stop words.  Returns a list of words.
    #
    # 1. Remove HTML
    #review_text = BeautifulSoup(review).get_text()
    #2. Remove non-letters
    review = re.sub("[^a-zA-Z]"," ", review)
    # 3. Convert words to lower case and split them
    words = review.lower().split()
    #
    # 4. Optionally remove stop words (false by default)
    if remove_stopwords:
        stops = set(stopwords.words("english")) | set("public private http https www com none v f x web author \
        org href n io copyright license licenses os sa l c p j a b c d e f g h i j k l m n o p q r s t u v w z y z cc help\
        ci file code please software bugs time date html format".split()) # ci is for continuous integration I think came up with 34 values in the dataset. 
        #Should probably be taken out. Many teams use continuous integration.
        #use the set if there are other words #web appears in 90 cells, removing.
        #put the alphabet in above to deal with sudo 'command' -c or a, etc.
        words = [w for w in words if not w in stops]

    # 5. Return a list of words
    return(words)

for i in xrange(documents.size):
    documents[i] = review_to_words(documents[i])

#to put it into a format that is recognizable.
def labelizeReviews(reviews, labs):
    #The way I'm labeling these is wrong.
    import gensim
    #changed LabeledSentence to Tagged Document.
    #Labeled Sentence from gensim is deprecated apparently
    LabeledSentence = gensim.models.doc2vec.TaggedDocument
    labelized = []
    for i,v in enumerate(reviews):
        #label = '%s_%s'%(label_type,i)
        labelized.append(LabeledSentence(v,labs[i].split()))
    return labelized

#sentences = [TaggedDocument((doc, [labels_vec[index]])) for index, doc in enumerate(documents)]
#sentences = labelizeReviews((documents),np.asarray(labels_vec))
sentences = labelizeReviews((documents),(labels_vec))

print sentences[0:5]
#"Doc2vec performs strongly over larger documents. Doc2vec performs well when trained against a large external corpora"
#^ https://arxiv.org/pdf/1607.05368v1.pdf

#I doubt the current dataset --255 rows -- will be enough to perform well by itself.
"""
Think of doc2vec as a neural network type classifier that is an extension of word2vec, to work with documents.

Explanation of hyperparams:

dm = 0 is dbow, or distributed bag of words. Basically ignores word order, and gives each document it's own vector
dm = 1 is dmpv, includes the word order
both rely on log probabilities.

In choosing either dm = 0 or dm = 1, ask yourself if the documents have a consistent english structure.
Here, in the ReadMe data, they do not follow coherent english. Structures will vary with writing styles and programming languages.
So pick dm = 0.

From Gensim docs:

size is the dimensionality of the feature vectors.

window is the maximum distance between the predicted word and context words used for prediction within a document.

alpha is the initial learning rate (will linearly drop to zero as training progresses).

seed = for the random number generator. Note that for a fully deterministically-reproducible run, you must also limit the model to a single worker thread, to eliminate ordering jitter from OS thread scheduling. (In Python 3, reproducibility between interpreter launches also requires use of the PYTHONHASHSEED environment variable to control hash randomization.)

min_count = ignore all words with total frequency lower than this.

max_vocab_size = limit RAM during vocabulary building; if there are more unique words than this, then prune the infrequent ones. Every 10 million word types need about 1GB of RAM. Set to None for no limit (default).

sample = threshold for configuring which higher-frequency words are randomly downsampled;
default is 0 (off), useful value is 1e-5.
workers = use this many worker threads to train the model (=faster training with multicore machines).

iter = number of iterations (epochs) over the corpus. The default inherited from Word2Vec is 5, but values of 10 or 20 are common in published ‘Paragraph Vector’ experiments.

hs = if 1 (default), hierarchical sampling will be used for model training (else set to 0).

negative = if > 0, negative sampling will be used, the int for negative specifies how many “noise words” should be drawn (usually between 5-20).

dm_mean = if 0 (default), use the sum of the context word vectors. If 1, use the mean. Only applies when dm is used in non-concatenative mode.

dm_concat = if 1, use concatenation of context vectors rather than sum/average; default is 0 (off). Note concatenation results in a much-larger model, as the input is no longer the size of one (sampled or arithmatically combined) word vector, but the size of the tag(s) and all words in the context strung together.

dm_tag_count = expected constant number of document tags per document, when using dm_concat mode; default is 1.

dbow_words if set to 1 trains word-vectors (in skip-gram fashion) simultaneous with DBOW doc-vector training; default is 0 (faster training of doc-vectors only).

trim_rule = vocabulary trimming rule, specifies whether certain words should remain
in the vocabulary, be trimmed away, or handled using the default (discard if word count < min_count). Can be None (min_count will be used), or a callable that accepts parameters (word, count, min_count) and returns either util.RULE_DISCARD, util.RULE_KEEP or util.RULE_DEFAULT. Note: The rule, if given, is only used prune vocabulary during build_vocab() and is not stored as part

of the model.

"""
model = Doc2Vec(dm=0, min_count=2, window=15, size=30, sample=1e-4, negative=5, workers=8, seed = 1234) #decreasing size, due to small number of sentences.

model.build_vocab(sentences)

for epoch in range(3):
    #should implement random permutations, perm doesn't work well with "TaggedDocument"
    #perm = np.random.permutation(sentences)
    #model.train(perm)
    model.train(sentences)
    model.alpha -= 0.002 # decrease the learning rate
    model.min_alpha = model.alpha # fix the learning rate, no deca 
   
#Save and load models. change locations.
model.save('~/Documents/Stage_Doc2Vec_Model.d2v')
