SHELL := /bin/bash
PACHCTL := pachctl
KUBECTL := kubectl

label-studio-setup:
	$(PACHCTL) create repo raw_data
	$(PACHCTL) create repo labeled_data
	$(PACHCTL) create branch labeled_data@master
	$(PACHCTL) create branch raw_data@master

put-text-examples1:
	cd raw_data/; $(PACHCTL) put file -r raw_data@master -f ./; cd ../

clean-project: delete label-studio-setup

delete:
	$(PACHCTL) delete repo labeled_data
	$(PACHCTL) delete repo raw_data

clean: delete