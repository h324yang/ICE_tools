import json


def get_eval_genres():
    return ["Horror", "Thriller", "Western", "Action", "Short", "Sci-Fi"]


def load_json(fjson):
    return json.load(open(fjson))


def split_network(n_path, id2genre_dict, genre_list):
    res = {g:"" for g in genre_list}
    with open(n_path) as f:
        for line in f:
            l = line
            sp_line = l.strip().split()
            entity_id = sp_line[0][2:]
            for cur_g in id2genre_dict[entity_id]:
                if cur_g in res:
                    res[cur_g] += line
    return res


def main():
    id2genres_p = "../OMDB_dataset/id2genres.json"
    top5_p = "../data/et_top5_w0.edge"
    top10_p = "../data/et_top10_w0.edge"
    SAVE_DIR = "../genre_data"
    genre_list = get_eval_genres()
    id2genres_dict = load_json(id2genres_p)
    top5_res = split_network(top5_p, id2genres_dict, genre_list)
    top10_res = split_network(top10_p, id2genres_dict, genre_list)
    for cur_g in genre_list:
        with open("%s/%s/%s"%(SAVE_DIR, cur_g, "et_top5_w0.edge"), "w") as f:
            f.write(top5_res[cur_g])
        with open("%s/%s/%s"%(SAVE_DIR, cur_g, "et_top10_w0.edge"), "w") as f:
            f.write(top10_res[cur_g])


if __name__ == '__main__':
    main()


