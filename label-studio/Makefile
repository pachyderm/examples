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

put-text-examples2:
	$(PACHCTL) put file raw_data@master:/test-example.json -f raw_data/test-example2.json --split json --target-file-datums 1 --overwrite

clean-project: delete label-studio-setup

delete:
	yes | $(PACHCTL) delete all

clean: delete