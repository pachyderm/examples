SHELL := /bin/bash
PACHCTL := pachctl
KUBECTL := kubectl

label-studio-setup:
	$(PACHCTL) create repo raw_data
	$(PACHCTL) create repo labeled_data
	$(PACHCTL) create branch labeled_data@master
	$(PACHCTL) create branch raw_data@master

put-text-examples1:
	$(PACHCTL) put file raw_data@master:/test-example.json -f raw_data/test-example.json --split json --target-file-datums 1

clean-project: delete label-studio-setup

delete:
	$(PACHCTL) delete repo labeled_data
	$(PACHCTL) delete repo raw_data

clean: delete