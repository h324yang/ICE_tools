import json
import numpy as np
from sklearn.metrics import pairwise_distances
import argparse


def get_args():
    PARSER = argparse.ArgumentParser(description='Case Study')
    PARSER.add_argument('-item', default=None, help='Path of item embeddings')
    PARSER.add_argument('-word', default=None, help='Path of item embeddings')
    PARSER.add_argument('-omdb', default=None, help='Path of OMDB dataset')
    CONFIG = PARSER.parse_args()
    return CONFIG.item, CONFIG.word


def load_json(fjson):
    return json.load(open(fjson))


def read_w2v_from_file(path, prefix="", skip_header=False):
    w2v_dict = {}
    with open(path, "r") as f:
        if skip_header: next(f) # assume the first line is header
        for line in f:
            splited = line.strip().split()
            word = prefix+splited[0]
            embd = np.array(splited[1:]).astype(np.float32)
            w2v_dict[word] = embd
    return w2v_dict


class IndexedMatrix():
    def __init__(self, items, repr_matrix):
        self.items = np.array(items)
        self.repr_matrix = np.array(repr_matrix).astype(np.float32)


def gen_indexed_matrix(items, repr_dict):
    repr_matrix = [repr_dict[item] for item in items]
    return IndexedMatrix(items, repr_matrix)


def batch_retrieve(seeds, word_embd, item_embd, topK):
    word_imat = gen_indexed_matrix(seeds, word_embd)
    item_imat = gen_indexed_matrix(list(item_embd.keys()), item_embd)
    cos_mat = pairwise_distances(word_imat.repr_matrix, item_imat.repr_matrix, metric="cosine")
    res = []
    for idx in range(cos_mat.shape[0]):
        seed_res = []
        ranked = np.argsort(cos_mat[idx])[:topK]
        for r in ranked:
            seed_res.append(item_imat.items[r])
        res.append(seed_res)
    return res


class CaseStudy():
    def __init__(self, item_p, word_p, omdb_p):
        self.item_embd = read_w2v_from_file(item_p)
        self.word_embd = read_w2v_from_file(word_p)
        self.ombd_dict = self.read_omdb(omdb_p)


    def read_omdb(self, omdb_p):
        dataset = load_json(omdb_p)
        omdb_dict = {dt["movieId"]:dt for dt in dataset}
        return omdb_dict


    def item2item(self, item_id, k=5):
        res = batch_retrieve(item_id, self.item_embd, self.item_embd, k+1)[0][1:]
        for r_id in res:
            r = r_id[2:]
            print("%-40s%s"%(self.ombd_dict[r]["title"], self.ombd_dict[r]["genre"]))

    def item2word(self, item_id, k=10):
        res = batch_retrieve(item_id, self.item_embd, self.word_embd, k)[0]
        for r in res:
            print(r)


    def word2item(self, word, k=5):
        res = batch_retrieve(word, self.word_embd, self.item_embd, k)[0]
        for r_id in res:
            r = r_id[2:]
            print("%-40s%s"%(self.ombd_dict[r]["title"], self.ombd_dict[r]["genre"]))


if __name__ == "__main__":
    # item_p, word_p = get_args()
    item_p = "../sample_sensi/1/item.embd.2000"
    word_p = "../sample_sensi/1/word.embd.2000"
    omdb_p = "../OMDB_dataset/OMDB.json"
    cs = CaseStudy(item_p, word_p, omdb_p)
    print("----movie-to-word----")
    cs.item2word(["m_1"]) # Toy Story
    print("----movie-to-movie----")
    cs.item2item(["m_4310"]) # American Pie
    print("----word-to-movie----")
    cs.word2item(["w_alien"])
