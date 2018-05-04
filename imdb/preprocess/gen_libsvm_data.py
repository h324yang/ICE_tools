from sys import argv
import json
import numpy as np


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


def main():
    embd_p = argv[1]
    id2genres_p = argv[2]
    output = argv[3]

    with open(id2genres_p) as f:
        id2genres = json.load(f)

    embd = read_w2v_from_file(embd_p)
    res = ""
    for item, vector in embd.items():
        labels = ",".join(id2genres[item[2:]])
        features = " ".join(["%s:%.6f"%(n+1, entry) for n, entry in enumerate(vector)])
        res += labels + " " + features + "\n"

    with open(output, "w") as f:
        f.write(res)


if __name__ == "__main__":
    main()

