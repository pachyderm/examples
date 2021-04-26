SHELL := /bin/bash
PACHCTL := pachctl
KUBECTL := kubectl

setup: 
	$(PACHCTL) create repo language_model
	$(PACHCTL) create repo financial_phrase_bank
	cd models/finbertTRC2/; $(PACHCTL) put file -r language_model@master -f ./

	cd data/FinancialPhraseBank/; $(PACHCTL) put file financial_phrase_bank@master -f Sentences_AllAgree.txt

	$(PACHCTL) create repo labeled_data
	$(PACHCTL) create repo raw_data

	$(PACHCTL) create pipeline -f pachyderm/dataset.json

	$(PACHCTL) create repo sentiment_words
	$(PACHCTL) put file sentiment_words@master:/LoughranMcDonald_SentimentWordLists_2018.csv -f resources/LoughranMcDonald_SentimentWordLists_2018.csv
	$(PACHCTL) create pipeline -f pachyderm/visualizations.json

	$(PACHCTL) create pipeline -f pachyderm/train_model.json

delete:
	$(PACHCTL) delete pipeline train_model
	$(PACHCTL) delete pipeline visualizations
	$(PACHCTL) delete pipeline dataset
	$(PACHCTL) delete repo sentiment_words
	$(PACHCTL) delete repo raw_data
	$(PACHCTL) delete repo labeled_data

clean: delete