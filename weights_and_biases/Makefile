SHELL := /bin/bash
PACHCTL := pachctl
KUBECTL := kubectl

all:
	python download_mnist.py --data-location ./data/
	$(PACHCTL) create repo mnist
	cd data && $(PACHCTL) put file -r mnist@master:/ -f ./
	$(PACHCTL) create pipeline -f train-mnist.json

clean: 
	$(PACHCTL) delete pipeline train-mnist
	$(PACHCTL) delete repo mnist