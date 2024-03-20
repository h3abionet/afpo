## Customize Makefile settings for afpo
## 
## If you need to customize your Makefile, make
## changes here rather than in the main Makefile

# Rules used to generate automated definition for populations
#.PHONY: update_def_table
#update_def_table: $(PATTERNDIR)/data/default/create_population_definition.tsv

#$(PATTERNDIR)/data/default/create_population_definition.tsv: $(SPARQLDIR)/population_annotation_definition.sparql $(SRC)
#	$(ROBOT) query --input $(SRC) --query $< $@.tmp.tsv
#	sed -e 's/?//g' -e 's/"//g' -e 's/http:\/\/purl.obolibrary.org\/obo\/AfPO_/AfPO:/g' < $@.tmp.tsv >$@ && rm $@.tmp.tsv

# imports/hancestro_import.owl: $(MIRRORDIR)/hancestro.owl $(IMPORTDIR)/hancestro_terms_combined.txt
# 	if [ $(IMP) = true ]; then $(ROBOT) query -i $< --update ../sparql/preprocess-module.ru \
#         extract -T $(IMPORTDIR)/hancestro_terms_combined.txt --copy-ontology-annotations true --force true --method MIREOT --branch-from-term "obo:BFO_0000141" \
#         query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
#         $(ANNOTATE_CONVERT_FILE); fi

# $(IMPORTDIR)/hancestro_import.owl: $(MIRRORDIR)/hancestro.owl $(IMPORTDIR)/hancestro_terms.txt
# 	if [ $(IMP) = true ]; then $(ROBOT) --prefix "dbpedia: http://dbpedia.org/resource/" \
# 		query -i $< --update ../sparql/preprocess-module.ru \
# 		extract -T $(IMPORTDIR)/hancestro_terms.txt --force true --copy-ontology-annotations true --individuals include --method BOT \
# 		filter $(patsubst %, --term %, $(ANNOTATION_PROPERTIES)) -T $(IMPORTDIR)/hancestro_terms.txt --select "self descendants" \
# 		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
# 		$(ANNOTATE_CONVERT_FILE); fi


$(IMPORTDIR)/hancestro_import.owl: $(MIRRORDIR)/hancestro.owl $(IMPORTDIR)/hancestro_terms.txt
	if [ $(IMP) = true ]; then $(ROBOT) --prefix "dbpedia: http://dbpedia.org/resource/" \
		query -i $< --update ../sparql/preprocess-module.ru \
		extract -T $(IMPORTDIR)/hancestro_terms.txt --force true --copy-ontology-annotations true --individuals include --method BOT \
		filter $(patsubst %, --term %, $(ANNOTATION_PROPERTIES)) -T $(IMPORTDIR)/hancestro_terms.txt --axioms all  --signature false \
		query --update ../sparql/inject-subset-declaration.ru --update ../sparql/inject-synonymtype-declaration.ru --update ../sparql/postprocess-module.ru \
		$(ANNOTATE_CONVERT_FILE); fi

