"""
Script for generating sequence probabilities for arithmetic language
"""

from collections import defaultdict

PROLOG_DEF_FILE = "markov_lang_seq.pl"

NUMS = [
    "zero",
    "one",
    "two",
    "three",
    "four",
    "five",
    "six",
    "seven",
    "eight",
    "nine",
    "ten"
]

OPS = ["plus","minus","times"]

def gen():

    preds = []

    inputs = []
    for i in range(0,11):
        number_i = NUMS[i]
        for j in range(0,11):
            number_j = NUMS[j]
            for op in OPS:
                inputs.append([number_i, op, number_j])

    total_count = len(inputs) * len(inputs[0])

    margin_counts = defaultdict(lambda: 0)

    for i in inputs:
        for w in i:
            margin_counts[w] += 1

    for w in margin_counts:
        preds.append('seq("%s",%f)' % (w, margin_counts[w]/total_count))

    gram_counts = defaultdict(lambda: 0)

    for i in inputs:
        for w_idx in range(0, len(i)-1):
            gram = (i[w_idx],i[w_idx+1])
            gram_counts[gram] += 1
    
    all_words = NUMS + OPS

    for wi in all_words:
        for wj in all_words:
            g = (wi, wj)
            preds.append('seq("%s","%s",%f)' % (g[0], g[1], gram_counts[g]/margin_counts[g[0]]) )


    return preds

if __name__ == "__main__":
    
    with open(PROLOG_DEF_FILE, "w+") as f:
        f.write(
            "% ------------------------------------------------------------ \n"
            "% Auto-generated prolog definitions for sequence probabilities \n"
            "% ------------------------------------------------------------ \n\n")
        preds = gen()
        for p in preds:
            f.write(p + ".\n")
