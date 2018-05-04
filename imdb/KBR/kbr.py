import json
import numpy as np
from sklearn.metrics import pairwise_distances
import argparse
import re
from operator import itemgetter


def get_eval_genres():
    return ["Horror", "Thriller", "Western", "Action", "Short", "Sci-Fi"]
    # return ["Horror"]


def extract_genres(dataset):
    return {elem["movieId"]:elem["genre"].split(", ") for elem in dataset}


def extract_plot(dataset):
    return {elem["movieId"]:elem["plot"].strip().lower() for elem in dataset}


def load_json(fjson):
    return json.load(open(fjson))


def get_args():
    PARSER = argparse.ArgumentParser(description='Evaluating retrival task.')
    PARSER.add_argument('-omdb', default=None, help='OMDB dataset')
    PARSER.add_argument('-seeds', default=None, help='Seed words of genres')
    PARSER.add_argument("-topW", type=int, default=20, help="The number of seed words")
    CONFIG = PARSER.parse_args()
    return CONFIG.omdb, CONFIG.seeds, CONFIG.topW


def get_seeds(seed_dict, genre, topW):
    seeds = []
    quota = topW
    word_dict = seed_dict[genre]
    N = len(word_dict)
    for i in range(1, N+1):
        seeds.append(word_dict[str(i)][0][2:])
        quota -= 1
        if quota <= 0:
            break
    return seeds


def batch_retrieve(seeds, plot_dict, topK):
    res = []
    for s in seeds:
        p = re.compile(r'\b%s\b'%s)
        # criteria 1: seed count; criteria 2: length of plot (the longer, the score is lower )
        stat = [(movie, len(p.findall(plot)), -len(plot)) for movie, plot in plot_dict.items()]
        sorted_stat = sorted(stat, key=itemgetter(1,2), reverse=True)
        seed_res = ["m_"+tup[0] for tup in sorted_stat[:topK]]
        res.append(seed_res)
    return res


def genre_precision(genre, id2genres, retrieved):
    x, y = np.array(retrieved).shape
    # print(x, y)
    hit = 0.
    for i in range(x):
        # seed_hit = 0.
        for j in range(y):
            # print(retrieved[i][j], id2genres[retrieved[i][j][2:]])
            if genre in id2genres[retrieved[i][j][2:]]:
                # print("This is %s movie."%genre)
                hit += 1.
                # seed_hit += 1.
        # print("seed_precision=%.3f"%(seed_hit/y))
    return hit / float(x*y)


def evaluate(genres, id2genres, seed_dict, plot_dict, topW=20):
    topK = [10, 50, 100]
    # topK = [100]
    for k in topK:
        print("Precision@%s:"%k)
        avg = 0.
        for g in genres:
            seeds = get_seeds(seed_dict, g, topW)
            retrieved = batch_retrieve(seeds, plot_dict, k)
            precision = genre_precision(g, id2genres, retrieved)
            print("%s %.3f"%(g, precision))
            avg += precision/float(len(genres))
        print("Average %.3f"%avg)


def main():
    data_p, seed_p, topW = get_args()
    # topW = 20
    # data_p = "../OMDB_dataset/OMDB.json"
    # seed_p = "../OMDB_dataset/genre_seeds_graphrank_w.json"
    id2genres = extract_genres(load_json(data_p))
    plot_dict = extract_plot(load_json(data_p))
    seed_dict = load_json(seed_p)
    eval_genres = get_eval_genres()
    evaluate(eval_genres, id2genres, seed_dict, plot_dict, topW)


if __name__ == "__main__":
    main()
