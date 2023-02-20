# This Makefile is a reference for setting up and running various parts of this demo quickly
ifeq ($(PC25),)
	pachcmd := pachctl
else
	pachcmd=/opt/homebrew/Cellar/pachctl@2.5/v2.5.0-alpha.4/bin/pachctl
endif


wine-classifer:
	$(pachcmd) update repo wine-reviews
	$(pachcmd) update pipeline -f pipelines/prep_reviews.yaml
	$(pachcmd) update pipeline -f pipelines/split_data.yaml
	$(pachcmd) update pipeline -f pipelines/prep_files.yaml
	$(pachcmd) update pipeline -f pipelines/train_model.yaml
	$(pachcmd) update pipeline -f pipelines/test_model.yaml
	$(pachcmd) put file wine-reviews@master -f data/winemag-data-130k-v2.csv
	# $(pachcmd) put file wine-reviews@master -f data/winemag-data_first150k.csv

create-ui:
	$(pachcmd)  update pipeline -f pipelines/svc_pipe.yaml

cleanup:
	$(pachcmd) delete pipeline test_model
	$(pachcmd) delete pipeline classifer-serving
	$(pachcmd) delete pipeline train_model
	$(pachcmd) delete pipeline prep_files
	$(pachcmd) delete pipeline split_data
	$(pachcmd) delete pipeline prep_reviews
	$(pachcmd) delete repo wine-reviews


.PHONY: \
	echo \
	wine-classifer \
	create-ui \
	cleanup

