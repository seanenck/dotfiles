#!/usr/bin/python
import os
import random
import argparse


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--length", type=int, default=64)
    args = parser.parse_args()
    if "PWGEN_SOURCE" not in os.environ:
        print("PWGEN_SOURCE not exported")
        exit(1)
    if "PWGEN_ALLOWED" not in os.environ:
        print("PWGEN_ALLOWED not exported")
        exit(1)
    source = os.environ["PWGEN_SOURCE"]
    allow = os.environ["PWGEN_ALLOWED"]
    if not os.path.exists(source):
        print("source does not exist")
        exit(1)
    options = [x for x in os.listdir(source)]
    gen = ""
    while len(gen) < args.length:
        r = random.randint(0, len(options))
        first = True
        for c in options[r]:
            if c in allow:
                if first:
                    gen += c.upper()
                    first = False
                else:
                    gen += c
    if len(gen) > args.length:
        gen = gen[0:args.length]
    print(gen)


if __name__ == "__main__":
    main()
