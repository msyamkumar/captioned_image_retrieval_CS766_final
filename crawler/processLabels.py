
if __name__ == "__main__":
    print "Hello, world!"

    searchTags = []

    with open("synset_words.txt", "r") as inFile:
        for line in inFile:
            line = line.strip()
            parts = line.split(",")
            searchTags = searchTags + parts
        print searchTags
