## Customize Makefile settings for afpo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile


$(PATTERNDIR)/data/default/create_definition.tsv: $(SRC)
    $(ROBOT) query --input $< --query $(SPARQLDIR)/annotation_definition.sparql $@