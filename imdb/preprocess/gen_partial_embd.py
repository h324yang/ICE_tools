from gensim.models.keyedvectors import KeyedVectors
from sys import argv
import json


def read_w2v_from_gensim(path):
    model = KeyedVectors.load_word2vec_format(path, binary=True)
    return model.wv

def read_tfidf_vocabs(path):
    with open(path) as f:
        tfidf_data = json.load(f)
    vocabs = set()
    for movie in tfidf_data:
        for w in movie["keywords"]:
            vocabs.add(w)
    return list(vocabs)

def main():
    pretrain = argv[1]
    tfidf_path = argv[2]
    save = argv[3]
    # pretrain = "../pretrain/GoogleNews-vectors-negative300.bin"
    # tfidf_path = "../data/omdb_keyword_tfidf.json"
    # save = "tmp.txt"

    wv = read_w2v_from_gensim(pretrain).wv
    vocabs = read_tfidf_vocabs(tfidf_path)
    with open(save, "w") as f:
        f.write("%s %s\n"%(len(vocabs), wv[vocabs[0][2:]].shape[0]))
        for w in vocabs:
            f.write(w+" "+" ".join(["%.6f"%val for val in wv[w[2:]]])+"\n")

if __name__ == "__main__":
    main()


