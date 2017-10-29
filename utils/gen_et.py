import json
import sys
from nltk.corpus import stopwords
import re
from sklearn.feature_extraction.text import TfidfVectorizer
from scipy.sparse import dok_matrix
import operator

def load_json(fjson):
    return json.load(open(fjson))

def extract_plot(dataset):
    return {elem["movieId"]:elem["plot"] for elem in dataset}

def preprocess(plot):
    words = re.sub(r'[^\w]', ' ', plot.strip()).split()
    words_lower = [(w.lower()) for w in words]
    return ' '.join(words_lower)

def dict_processor(dict_data, func):
    return {k:preprocess(v) for k, v in dict_data.items()}

def get_tfidf_edgelist(dict_data, topM, binary=False):
    edgelist = ""
    corpus = []
    tf = TfidfVectorizer(analyzer='word', ngram_range=(1,1), min_df=0, stop_words='english')
    sorted_keys = sorted([int(k) for k in dict_data.keys()])
    for k in sorted_keys:
        corpus.append(dict_data[str(k)])
    tfidf_matrix = tf.fit_transform(corpus)
    feature_names = tf.get_feature_names()
    dok_tfidf_matrix = dok_matrix(tfidf_matrix)
    for j, doc in enumerate(dok_tfidf_matrix):
        print(j)
        value_sorted = sorted(doc.items(), key=operator.itemgetter(1), reverse=True)
        for i in range(min(len(value_sorted), topM)):
            if binary:
                edgelist += "m_%s w_%s 1\n"%(sorted_keys[j], str(feature_names[value_sorted[i][0][1]]))
            else:
                edgelist += "m_%s w_%s %s\n"%(sorted_keys[j], str(feature_names[value_sorted[i][0][1]]), str(value_sorted[i][1]))
    return edgelist

if __name__ == "__main__":
    json_path = sys.argv[1]
    out_path = sys.argv[2]
    topM = int(sys.argv[3])
    binary = bool(sys.argv[4])
    dataset = load_json(json_path)
    parsed_plot = dict_processor(extract_plot(dataset), preprocess)
    edgelist = get_tfidf_edgelist(parsed_plot, topM, binary)
    with open(out_path, "w") as f:
        f.write(edgelist)

