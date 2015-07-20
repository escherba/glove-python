INPUT_FILE := enwiki-latest-pages-meta-current1.xml-p000000010p000010000.bz2

get-wiki: $(INPUT_FILE)

$(INPUT_FILE):
	wget http://dumps.wikimedia.org/enwiki/latest/$(INPUT_FILE)

process-wiki: $(INPUT_FILE)
	$(PYTHON) -- examples/example.py -w -c $(INPUT_FILE)

train-wiki: process-wiki
	$(PYTHON) -i -- examples/example.py -t 30 -p 2

all-wiki: process-wiki train-wiki
	@echo "done"

.PHONY: get-wiki process-wiki train-wiki
