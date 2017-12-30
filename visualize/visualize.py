from collections import defaultdict
import numpy as np
from operator import itemgetter
import matplotlib
import matplotlib.pyplot as plt
from matplotlib.backends.backend_pdf import PdfPages
matplotlib.rcParams['pdf.fonttype'] = 42
matplotlib.rcParams['ps.fonttype'] = 42
matplotlib.rcParams['text.usetex'] = True


def dd_list():
    return defaultdict(list)


def genre_check(line, genres):
    for g in genres:
        if line.startswith(g):
            cur_g, precision = line.strip().split()
            if precision: precision = float(precision)
            return cur_g, precision

    return None, None


def read_log(log_p, final=None, genres=["Horror", "Thriller", "Western", "Action", "Short", "Sci-Fi", "Average"]):
    if isinstance(log_p, str):
        log_p = [log_p]

    log = defaultdict(dd_list) # {TopK:{Genres:[(Iter, Precision)]}}
    iter_trained = None
    cur_topk = None
    # genres = ["Horror", "Thriller", "Western", "Action", "Short", "Sci-Fi", "Average"]
    for p in log_p:
        with open(p) as f:
            for line in f:
                if line.startswith("Evaluating"):
                    iter_trained = line.strip().split()[-2]
                    if iter_trained == 'final': iter_trained = final
                if line.startswith("Precision@"):
                    cur_topk = line.strip().split("@")[-1][:-1]
                genre, prec = genre_check(line, genres)
                if genre:
                    log[cur_topk][genre].append((int(iter_trained), prec))

    return log


def log_stat(logs, stat_func):
    stat_dict = defaultdict(list) # {Iter:[data]}
    stat_list = list()
    for iter_trained, prec in logs:
        stat_dict[iter_trained].append(prec)
    for iter_trained, data in stat_dict.items():
        stat_list.append((iter_trained, stat_func(data)))

    return stat_list


def print_stat(log):
    for topk in ['50', '100']:
        for genre, logs in log[topk].items():
            # for func, name in [(np.min, 'min'), (np.max, 'max'), (np.mean, 'mean')]:
            for func, name in [(np.mean, 'mean')]:
                stats = log_stat(logs, func)
                xs = []
                ys = []
                for x, y in sorted(stats, key=itemgetter(0)):
                    xs.append(x)
                    ys.append(y)
                for i, j in zip(xs, ys):
                    print("Genre:%s, Iter:%s, (%s)Precision%s:%.3f"%(genre, i, name, topk, j))


def draw_log_stat(log):
    pp = PdfPages('fig.pdf')
    r = 1
    for topk in ['50', '100']:
        for genre, logs in log[topk].items():
            for func, name in [(np.min, 'min'), (np.max, 'max'), (np.mean, 'mean')]:
                stats = log_stat(logs, func)
                xs = []
                ys = []
                for x, y in sorted(stats, key=itemgetter(0)):
                    xs.append(x)
                    ys.append(y)
                plt.subplot(2, 1, r)
                plt.plot(xs, ys, label=genre+"@"+topk+"(%s)"%name, color='r', linewidth=0.1)
            r += 1
            lgd = plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))

    plt.savefig(pp, bbox_extra_artists=(lgd,), bbox_inches='tight', format='pdf')
    pp.close()


def draw_log(log):
    pp = PdfPages('fig.pdf')
    r = 1
    for topk in ['50', '100']:
        for genre, logs in log[topk].items():
            xs = []
            ys = []
            for x, y in sorted(logs, key=itemgetter(0)):
                xs.append(x)
                ys.append(y)
            plt.subplot(2, 1, r)
            plt.plot(xs, ys, label=genre+"@"+topk)
        r += 1
        lgd = plt.legend(loc='center left', bbox_to_anchor=(1, 0.5))

    plt.savefig(pp, bbox_extra_artists=(lgd,), bbox_inches='tight', format='pdf')
    pp.close()


if __name__ == "__main__":
    log = read_log(["log/sample_sensi_log_10x5_10k_sep_%s.txt"%num for num in range(1,4)], 5000)
    # log = read_log(["log/sample_sensi_log_10x5_10k_unw_init1_twostage_w%s.txt"%num for num in range(1,4)], 5000)
    # draw_log_stat(log)
    print_stat(log)


