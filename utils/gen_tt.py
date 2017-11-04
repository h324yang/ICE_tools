from sklearn.metrics import pairwise_distances
import json
import numpy as np
import argparse
from tqdm import tqdm
from gensim.models.keyedvectors import KeyedVectors

def get_args():
    parser = argparse.ArgumentParser(description="Generating tt network.")
    parser.add_argument("-et", help="Corresponding et graph.")
    parser.add_argument("-w2v_embd", help="Pretrained word2vec embd file.")
    parser.add_argument("-expk", type=int, help="The number of expanded words for each.")
    parser.add_argument("-output", help="Output path, with edgelist format")
    parser.add_argument("-weighted", type=int, help="1:weighted / 0:unweighted (default:0)", default=0)
    CONFIG = parser.parse_args()
    return CONFIG.et, CONFIG.w2v_embd, int(CONFIG.expk), CONFIG.output, bool(CONFIG.weighted)

def main():
    et, w2v_embd, expk, fout, weighted = get_args()
    vocab_list = get_vocabs(et, remove_prefix="w_")
    w2v_dict = read_w2v_from_gensim(w2v_embd)
    res = gen(vocab_list, w2v_dict, expk, weighted)
    res = add_prefix(res, "w_", "w_")
    with open(fout, "w") as f:
        f.write(res)

class IndexedMatrix():
    def __init__(self, items, repr_matrix):
        self.items = np.array(items)
        self.repr_matrix = np.array(repr_matrix).astype(np.float32)

def gen_indexed_matrix(items, repr_dict):
    repr_matrix = []
    indexed_items = []
    for item in items:
        try:
            repr_matrix.append(repr_dict[item])
            indexed_items.append(item)
        except KeyError as err:
            print(err)
    return IndexedMatrix(indexed_items, repr_matrix)

def get_vocabs(et, remove_prefix="w_"):
    with open(et) as f:
        vocab_dict = {line.split()[1]:None for line in f.readlines()}
        vocab_list = [w[len(remove_prefix):] for w in list(vocab_dict.keys())]
    return vocab_list

def read_w2v_from_gensim(path):
    model = KeyedVectors.load_word2vec_format(path, binary=True)
    return model.wv

def read_w2v_from_file(path, prefix):
    w2v_dict = {}
    with open(path, "r") as f:
        next(f) # assume the first line is header
        for line in f:
            splited = line.strip().split()
            word = prefix+splited[0]
            embd = np.array(splited[1:]).astype(np.float32)
            w2v_dict[word] = embd
    return w2v_dict

def gen(vocab_list, w2v_dict, expk, weighted):
    mat = gen_indexed_matrix(vocab_list, w2v_dict)
    cos_mat = pairwise_distances(mat.repr_matrix, mat.repr_matrix, "cosine")
    res = ""
    for idx in tqdm(range(len(mat.items))):
        targets = cos_mat[idx].argsort()[1:expk+1]
        for t in targets:
            scr = str(-cos_mat[idx][t]+2)
            if weighted:
                res += mat.items[idx]+" "+mat.items[t]+" "+scr+"\n"
            else:
                res += mat.items[idx]+" "+mat.items[t]+" 1\n"
    return res

def add_prefix(edgelist, prefix1, prefix2):
    res = ""
    for i, elem in enumerate(edgelist.split()):
        if i%3 == 0:
            res += "%s%s "%(prefix1, elem)
        elif i%3 == 1:
            res += "%s%s "%(prefix2, elem)
        else:
            res += "%s\n"%elem
    return res


if __name__ == "__main__":
    main()
