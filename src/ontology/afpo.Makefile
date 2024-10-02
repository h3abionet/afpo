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
# We need to materialize the inferences and not remove redundant axioms so we can check the population group inconsistency violation
$(ONT)-sparqltest-full.owl: $(EDIT_PREPROCESSED) $(OTHER_SRC) $(IMPORT_FILES)
	$(ROBOT_RELEASE_IMPORT_MODE) \
	materialize --reasoner ELK --term http://purl.obolibrary.org/obo/AfPO_0000447 --term http://purl.obolibrary.org/obo/HANCESTRO_0308 \
	$(SHARED_ROBOT_COMMANDS) annotate --ontology-iri $(ONTBASE)/$@ $(ANNOTATE_ONTOLOGY_VERSION) --output $@.tmp.owl && mv $@.tmp.owl $@

# Command to split annotations using comma as a separator. If the annotation uses a different sep, please update the Python script.
# The annotations that will be split are population synonym (AfPO:0000450) and family (AfPO:0000565).
# 1. Need to convert to RDF/XML to be able to load the ontology using rdflib. rdflib can load OFN, but it requires the use of the plugin
# rdflib-owl which needs to be installed, and it's not available in the ODK. 
# 2. Run Python script which queries each annotation entry and splits it using the separator into N annotations.
# The N new annotations are added to the annotation.owl graph and the combined annotation is deleted and saved in afpo-edit-annotation.owl
# The two graphs could be merged into one, but this gives a chance to review the changes.
# 3. Merge the two owl files and save the output as afpo-edit.ofn after converting as OFN.
# 4. Remove intermediary files
split_annotation: $(SRC)
	$(ROBOT) convert -i $(SRC) -o $(ONT)-edit.owl
	python $(SCRIPTSDIR)/split_annotation.py
	$(ROBOT) merge -i afpo-edit-annotation.owl -i annotations.owl --collapse-import-closure false convert -o $(SRC)
	rm afpo-edit-annotation.owl
	rm annotations.owl
	rm $(ONT)-edit.owl

add_family: $(SRC)
	$(ROBOT) convert -i $(SRC) -o $(ONT)-edit.owl
	python $(SCRIPTSDIR)/add_family_tree.py
	$(ROBOT) merge -i $(ONT)-edit-family.owl --collapse-import-closure false convert -o $(SRC)
	rm $(ONT)-edit-family.owl
	rm $(ONT)-edit.owl