import argparse
from collections import defaultdict
import retrieval_eval
from os import listdir, remove
from time import sleep


def get_args():
    PARSER = argparse.ArgumentParser(description='Evaluating retrival task.')
    PARSER.add_argument('-dir', default=None, help='Path of directory being monitored')
    PARSER.add_argument('-entity', default=None, help='Path of item embeddings')
    PARSER.add_argument('-text', default=None, help='Path of word embeddings')
    PARSER.add_argument('-context', default=None, help='Path of context embeddings')
    PARSER.add_argument('-omdb', default=None, help='OMDB dataset')
    PARSER.add_argument('-seeds', default=None, help='Seed words of genres')
    CONFIG = PARSER.parse_args()
    return CONFIG.dir, CONFIG.entity, CONFIG.text, CONFIG.context, CONFIG.omdb, CONFIG.seeds


class Monitor():
    def __init__(self, DIR, item_p, word_p, context_p, data_p, seed_p):
        self.DIR = DIR
        self.item_p = item_p
        self.word_p = word_p
        self.context_p = context_p
        self.data_p = data_p
        self.seed_p = seed_p

    def check(self):
        self.collector = defaultdict(int)
        files = listdir(self.DIR)
        print("%s files are found."%len(files))
        for f in files:
            file_name = f
            splited = file_name.split(".")
            if len(splited) > 2:
                file_name = ".".join(splited[:-1])
                iter_trained = splited[-1]
            else:
                iter_trained = "final"
            if file_name in [self.word_p, self.item_p]:
                self.collector[iter_trained] += 1

        return self.collector

    def run(self, sec=30, keep=None):
        self.sec = sec
        self.keep = keep
        self.done = []
        id2genres = retrieval_eval.extract_genres(retrieval_eval.load_json(data_p))
        seed_dict = retrieval_eval.load_json(seed_p)
        eval_genres = retrieval_eval.get_eval_genres()
        while True:
            files = listdir(self.DIR)
            checked = self.check()
            # print(checked); exit()
            for iter_trained, n_files in checked.items():
                do_remove = False if iter_trained in keep or iter_trained == "final" else True
                if n_files == 2 and iter_trained not in self.done:
                    self.done.append(iter_trained)
                    print("Evaluating %s and %s, trained by %s iterations."%(self.item_p, self.word_p, iter_trained))
                    iter_trained = "" if iter_trained == "final" else "."+iter_trained
                    cur_item_p = self.DIR + self.item_p + iter_trained
                    cur_word_p = self.DIR + self.word_p + iter_trained
                    item_embd = retrieval_eval.read_w2v_from_file(cur_item_p)
                    word_embd = retrieval_eval.read_w2v_from_file(cur_word_p)
                    retrieval_eval.evaluate(eval_genres, id2genres, seed_dict, word_embd, item_embd)
                    if do_remove:
                        remove(cur_item_p)
                        remove(cur_word_p)
                        if self.context_p:
                            cur_context_p = self.DIR + self.context_p + iter_trained
                            remove(cur_context_p)

            sleep(self.sec)


if __name__ == "__main__":
    DIR, item_p, word_p, context_p, data_p, seed_p = get_args()
    monitor = Monitor(DIR, item_p, word_p, context_p, data_p, seed_p)
    monitor.run(sec=5, keep=[str(i*10000) for i in range(1, 8)])


