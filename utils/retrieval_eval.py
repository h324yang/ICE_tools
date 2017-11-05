import json

def get_eval_genres():
    return ["Horror", "Thriller", "Western", "Action", "Short", "Sci-Fi"]

def extract_genres(dataset):
    return {elem["movieId"]:elem["genre"].split(", ") for elem in dataset}

def load_json(fjson):
    return json.load(open(fjson))

def get_args():
    pass

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

def read_seeds(seed_file):
    pass


def batch_retrieve(query_batch, query_embd, item_embd, topk):
    pass



def main():
    pass

if __name__ == "__main__":
    get_args()
    main()
