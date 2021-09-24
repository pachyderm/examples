SHELL := /bin/bash
PACHCTL := pachctl
KUBECTL := kubectl

setup: 
	$(PACHCTL) create repo language_model
	$(PACHCTL) create repo financial_phrase_bank
	cd models/finbertTCR2/; $(PACHCTL) put file -r language_model@master -f ./

	cd data/FinancialPhraseBank-v1.0/; $(PACHCTL) put file financial_phrase_bank@master -f Sentences_50Agree.txt

	$(PACHCTL) create repo labeled_data
	$(PACHCTL) create branch labeled_data@master
	$(PACHCTL) start commit labeled_data@master; $(PACHCTL) finish commit labeled_data@master

	$(PACHCTL) create pipeline -f pachyderm/dataset.json

	$(PACHCTL) create repo sentiment_words
	$(PACHCTL) put file sentiment_words@master:/LoughranMcDonald_SentimentWordLists_2018.csv -f resources/LoughranMcDonald_SentimentWordLists_2018.csv
	$(PACHCTL) create pipeline -f pachyderm/visualizations.json

	$(PACHCTL) create pipeline -f pachyderm/train_model.json

delete:
	$(PACHCTL) delete pipeline train_model
	$(PACHCTL) delete pipeline visualizations
	$(PACHCTL) delete pipeline dataset
	$(PACHCTL) delete pipeline raw_data
	$(PACHCTL) delete repo sentiment_words
	$(PACHCTL) delete repo language_model
	$(PACHCTL) delete repo financial_phrase_bank
	$(PACHCTL) delete repo labeled_data

clean: delete
