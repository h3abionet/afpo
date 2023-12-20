## Customize Makefile settings for afpo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

.PHONY: update_def_table
update_def_table: $(PATTERNDIR)/data/default/create_definition.tsv

$(PATTERNDIR)/data/default/create_definition.tsv: $(SPARQLDIR)/annotation_definition.sparql $(SRC)
	$(ROBOT) query --input $(SRC) --query $< $@.tmp.tsv
	sed -e 's/?//g' -e 's/"//g' -e 's/http:\/\/purl.obolibrary.org\/obo\/AfPO_/AfPO:/g' < $@.tmp.tsv >$@ && rm $@.tmp.tsv