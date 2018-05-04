import argparse
from collections import defaultdict
from gensim.models.keyedvectors import KeyedVectors
import numpy as np


def get_args():
    PARSER = argparse.ArgumentParser(description='Calculating the average embedding.')
    PARSER.add_argument('-entity', default=None, help='Path of item embeddings')
    PARSER.add_argument('-text', default=None, help='Path of word embeddings')
    PARSER.add_argument('-et', default=None, help='Path of et graph')
    PARSER.add_argument('-w2v', default=None, help='Path of w2v embedding')
    # PARSER.add_argument('-omdb', default=None, help='OMDB dataset')
    CONFIG = PARSER.parse_args()
    return CONFIG.entity, CONFIG.text, CONFIG.et, CONFIG.w2v


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


def read_et(et):
    et_dict = defaultdict(list)
    weight_dict = defaultdict(float)
    with open(et) as f:
        for line in f:
            splited = line.strip().split()
            item = splited[0]
            word = splited[1]
            weight = splited[2]
            et_dict[item].append(word)
            weight_dict[item] += float(weight)

    return et_dict, weight_dict


def gen(entity, text, et, w2v):
    entity_emdb = dict()
    et_dict, weight_dict = read_et(et)
    wv = read_w2v_from_file(w2v)
    for e, ts in et_dict.items():
        embds = []
        for t in ts:
            embds.append(wv[t])
            # embds.append([1. for _ in range(100)])
        embd = np.sum(embds, axis=0) / weight_dict[e]
        entity_emdb[e] = embd

    return entity_emdb, wv


def save_embd(path, embd_dict):
    res = ""
    for elem, embd in embd_dict.items():
        res += elem+" "+" ".join(["%.6f"%n for n in list(embd)])+"\n"
    with open(path, "w") as f:
        f.write(res)


def main():
    entity, text, et, w2v = get_args()
    # entity = "./item.embd"
    # text = "./word.embd"
    # et = "../data/et_top20_w0.edge"
    # w2v = "../pretrain/partial_embd.txt"
    entity_embd, text_embd = gen(entity, text, et, w2v)
    save_embd(entity, entity_embd)
    save_embd(text, text_embd)


if __name__ == "__main__":
    main()



