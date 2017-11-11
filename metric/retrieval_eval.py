import json
import numpy as np
from sklearn.metrics import pairwise_distances
import argparse

def get_eval_genres():
    return ["Horror", "Thriller", "Western", "Action", "Short", "Sci-Fi"]


def extract_genres(dataset):
    return {elem["movieId"]:elem["genre"].split(", ") for elem in dataset}


def load_json(fjson):
    return json.load(open(fjson))


def get_args():
    PARSER = argparse.ArgumentParser(description='Evaluating retrival task.')
    PARSER.add_argument('-entity', default=None, help='Path of item embeddings')
    PARSER.add_argument('-text', default=None, help='Path of word embeddings')
    PARSER.add_argument('-omdb', default=None, help='OMDB dataset')
    PARSER.add_argument('-seeds', default=None, help='Seed words of genres')
    CONFIG = PARSER.parse_args()
    return CONFIG.entity, CONFIG.text, CONFIG.omdb, CONFIG.seeds


def read_w2v_from_file(path, prefix=""):
    w2v_dict = {}
    with open(path, "r") as f:
        next(f) # assume the first line is header
        for line in f:
            splited = line.strip().split()
            word = prefix+splited[0]
            embd = np.array(splited[1:]).astype(np.float32)
            w2v_dict[word] = embd
    return w2v_dict


def get_seeds(seed_dict, genre, topW=20, filter_dict=None):
    seeds = []
    quota = topW
    word_dict = seed_dict[genre]
    N = len(word_dict)
    for i in range(1, N+1):
        cur_word = word_dict[str(i)][0]
        if cur_word not in filter_dict:
            continue
        else:
            seeds.append(cur_word)
            quota -= 1
            if quota <= 0:
                break
    return seeds


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


def genre_precision(genre, id2genres, retrieved):
    x, y = np.array(retrieved).shape
    hit = 0.
    for i in range(x):
        for j in range(y):
            # print(retrieved[i][j], id2genres[retrieved[i][j][2:]])
            if genre in id2genres[retrieved[i][j][2:]]:
                # print("This is %s movie."%genre)
                hit += 1.
    return hit / float(x*y)


def evaluate(genres, id2genres, seed_dict, word_embd, item_embd):
    topK = [50, 100]
    for k in topK:
        print("Precision@%s:"%k)
        avg = 0.
        for g in genres:
            seeds = get_seeds(seed_dict, g, filter_dict=word_embd)
            retrieved = batch_retrieve(seeds, word_embd, item_embd, k)
            precision = genre_precision(g, id2genres, retrieved)
            print("%s %.3f"%(g, precision))
            avg += precision/float(len(genres))
        print("Average %.3f"%avg)


def main():
    item_p, word_p, data_p, seed_p = get_args()
    # item_p = "../reproduce/item1.embd"
    # word_p = "../reproduce/word1.embd"
    # data_p = "../OMDB_dataset/OMDB.json"
    # seed_p = "../OMDB_dataset/genre_seeds.json"
    item_embd = read_w2v_from_file(item_p)
    word_embd = read_w2v_from_file(word_p)
    id2genres = extract_genres(load_json(data_p))
    seed_dict = load_json(seed_p)
    eval_genres = get_eval_genres()
    evaluate(eval_genres, id2genres, seed_dict, word_embd, item_embd)


if __name__ == "__main__":
    main()
