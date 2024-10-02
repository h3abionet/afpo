import pandas as pd
from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.plugins.sparql import prepareQuery

AFPO_NAMESPACE = Namespace("http://purl.obolibrary.org/obo/AfPO_")
g = Graph().parse(location="ontology/afpo-edit.owl")
family_data = pd.read_csv("resources/afpo-full.iso639-3.family.tsv", sep="\t")

prep_query = prepareQuery(
    "SELECT ?term WHERE { ?term AfPO:0000567 ?value . }",
    initNs={"AfPO": AFPO_NAMESPACE},
)


def add_family_tree():
    for _, row in family_data.iterrows():
        qres = g.query(prep_query, initBindings={"value": Literal(row["ISO639-3"])})
        print(row["ISO639-3"])
        print(len(qres))
        for term in qres:
            print(term)
            g.remove((term[0], URIRef(AFPO_NAMESPACE + "0000565"), None))
            g.add((term[0], URIRef(AFPO_NAMESPACE + "0000565"), Literal(row["Family"])))

    g.serialize(destination="afpo-edit-family.owl", format="xml")

    
add_family_tree()