import random
import sys


def random_sampler(filename, num):
    sample_train = []
    sample_test = []
    index = random.sample(xrange(total_num),int(num))
    with open(filename) as f:
        for n, line in enumerate(f):
            if n+1 in index:
                sample_test.append(line.rstrip())
            else:
                sample_train.append(line.rstrip())

    return sample_train, sample_test


# total_num = 32672
train = sys.argv[1]
test = sys.argv[2]
filename = sys.argv[3]
fold = sys.argv[4]

total_num = 0
with open(filename) as f:
    for _ in f:
        total_num += 1

num = total_num/(int(fold))
fout1 = open("%s" %train, "w")
fout2 = open("%s" %test, "w")
# train = []
# test = []
train,test = random_sampler("%s" %filename, num)
fout1.write('\n'.join(train))
fout1.write('\n')
fout2.write('\n'.join(test))
fout2.write('\n')
