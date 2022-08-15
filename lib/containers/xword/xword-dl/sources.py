"""Source list."""
import argparse


def main():
    """Program entry."""
    p = argparse.ArgumentParser()
    p.add_argument("--remotes")
    a, _ = p.parse_known_args()
    for o in a.remotes.split(","):
        print(o)


if __name__ == "__main__":
    main()
