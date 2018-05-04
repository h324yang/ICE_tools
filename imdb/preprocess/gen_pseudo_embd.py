from gensim.models.keyedvectors import KeyedVectors
from sys import argv

def read_w2v_from_gensim(path):
    model = KeyedVectors.load_word2vec_format(path, binary=True)
    return model.wv

def main():
    pretrain = argv[1]
    save = argv[2]
    vocabs = read_w2v_from_gensim(pretrain).vocab
    with open(save, "w") as f:
        f.write("%s %s\n"%(len(vocabs), 0))
        for key in vocabs.keys():
            f.write("w_%s NA\n"%key)

if __name__ == "__main__":
    main()


