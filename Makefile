# The executable paths below are set to generic values.
# Modify them for your system by setting environment variables, using a command like this
# to both fetch the version of pachyderm you want to use and execute it.
# "../etc/fetch_release_pachctl.py 1.10.0 ; env PACHCTL=${GOPATH}/bin/pachctl make -e opencv"

SHELL := /bin/bash
PACHCTL := pachctl
KUBECTL := kubectl

bc-single-stage:
	$(PACHCTL) create repo models
	$(PACHCTL) create repo sample_data
	$(PACHCTL) put file -r models@master:/ -f breast-cancer-detection/models/
	$(PACHCTL) put file -r sample_data@master:/ -f breast-cancer-detection/sample_data/
	$(PACHCTL) create pipeline -f breast-cancer-detection/single-stage/bc_classification.json 

bc-multi-stage:
	$(PACHCTL) create repo models
	$(PACHCTL) create repo sample_data
	$(PACHCTL) put file -r models@master:/ -f breast-cancer-detection/models/
	$(PACHCTL) put file -r sample_data@master:/ -f breast-cancer-detection/sample_data/
	$(PACHCTL) create pipeline -f breast-cancer-detection/multi-stage/crop.json
	$(PACHCTL) create pipeline -f breast-cancer-detection/multi-stage/extract_centers.json
	$(PACHCTL) create pipeline -f breast-cancer-detection/multi-stage/generate_heatmaps.json
	$(PACHCTL) create pipeline -f breast-cancer-detection/multi-stage/visualize_heatmaps.json
	$(PACHCTL) create pipeline -f breast-cancer-detection/multi-stage/classify.json

bc-delete:
	$(PACHCTL) delete pipeline bc_classification
	$(PACHCTL) delete pipeline bc_classification_cpu
	$(PACHCTL) delete pipeline classify
	$(PACHCTL) delete pipeline visualize_heatmaps
	$(PACHCTL) delete pipeline generate_heatmaps
	$(PACHCTL) delete pipeline extract_centers
	$(PACHCTL) delete pipeline crop
	$(PACHCTL) delete repo sample_data
	$(PACHCTL) delete repo models

delete:
	yes | $(PACHCTL) delete all

clean: delete

minikube:echo hi
	minikube start
	@WHEEL="-\|/"; \
	until minikube ip 2>/dev/null; do \
	    WHEEL=$${WHEEL:1}$${WHEEL:0:1}; \
	    echo -en "\e[G\e[K$${WHEEL:0:1} waiting for minikube to start..."; \
	    sleep 1; \
	done
	$(PACHCTL) deploy local
	@until "$$(
		$(KUBECTL) get po \
		  -l suite=pachyderm,app=dash \
		  -o jsonpath='{.items[0].status.conditions[?(@.type=="Ready")].status}')" = True; \
	do \
		WHEEL=$${WHEEL:1}$${WHEEL:0:1}; \
		$(ECHO) -en "\e[G\e[K$${WHEEL:0:1} waiting for pachyderm to start..."; \
		sleep 1; \
	done
	pachctl port-forward &
