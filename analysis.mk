INPUT_FILE := enwiki-latest-pages-meta-current1.xml-p000000010p000010000.bz2

get-wiki: $(INPUT_FILE)

$(INPUT_FILE):
	wget http://dumps.wikimedia.org/enwiki/latest/$(INPUT_FILE)

memcheck: $(INPUT_FILE)
	valgrind --tool=memcheck --dsymutil=yes --leak-check=full \
		--show-leak-kinds=all --track-origins=yes \
		--suppressions=valgrind-python.supp \
		env/bin/python -- examples/example.py -w -c $(INPUT_FILE) 2> valgrind_python_stderr.txt

process-wiki: $(INPUT_FILE)
	$(PYTHON) -- examples/example.py -w -c $(INPUT_FILE)

train-wiki: process-wiki
	$(PYTHON) -i -- examples/example.py -t 30 -p 2

all-wiki: process-wiki train-wiki
	@echo "done"

.PHONY: get-wiki process-wiki train-wiki
