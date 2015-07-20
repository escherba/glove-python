.PHONY: clean nuke test coverage build_ext all

PYENV = . env/bin/activate;
PYTHON = $(PYENV) python
PIP = $(PYENV) pip
EXTRAS_REQS := $(wildcard requirements-*.txt)
export QUICK_INSTALL=1

DISTRIBUTE = sdist bdist_wheel

include analysis.mk

release: env
	$(PYTHON) setup.py $(DISTRIBUTE) upload -r livefyre

package: env
	$(PYTHON) setup.py $(DISTRIBUTE)

nuke: clean
	rm -rf *.egg *.egg-info env cover coverage.xml nosetests.xml

clean:
	python setup.py clean
	rm -rf dist build
	find . -path ./env -prune -o -type f -name '*.pyc' -or -name '*.so' -exec rm {} \;

coverage: test
	open cover/index.html

ifeq ($(QUICK_INSTALL),1)
VENV_OPTS="--system-site-packages"
else
VENV_OPTS="--no-site-packages"
endif

test: setup
	$(PYTHON) `which nosetests` $(NOSEARGS)
	$(PYENV) py.test README.rst

all: extras build_ext
	$(PIP) install -e .

# TODO: move list of extensions to an external text file
.PHONY: build_ext
build_ext glove/glove_cython.so glove/corpus_cython.so glove/metrics/accuracy_cython.so: env
	$(PYTHON) setup.py build_ext --inplace

extras: env/make.extras
env/make.extras: $(EXTRAS_REQS) | env
	rm -rf env/build
	$(PYENV) for req in $?; do pip install -r $$req; done
	touch $@

env: env/bin/activate
env/bin/activate: requirements.txt setup.py
	test -f $@ || virtualenv $(VENV_OPTS) env
	$(PYENV) easy_install -U pip
	$(PYENV) curl https://bootstrap.pypa.io/ez_setup.py | python
	$(PIP) install setuptools
	$(PIP) install distribute
	$(PIP) install wheel
	$(PIP) install numpy
	$(PIP) install -r $<
	touch $@
