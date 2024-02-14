from rdflib import Graph, Namespace, URIRef
from rdflib.plugins.sparql import prepareQuery


g = Graph().parse(location="afpo-edit.owl")

prep_query = prepareQuery (
    "SELECT ?term ?value WHERE { ?term ?annotation ?value . }",
    initNs={"AfPO": Namespace("http://purl.obolibrary.org/obo/AfPO_")}
)


def query_annotation(annotation: str):
    qres = g.query(prep_query, initBindings={"annotation": URIRef(annotation)})
    for row in qres:
        term, value = row
        
        
        


# v = g.serialize(format="xml")
annotations = [
    "http://purl.obolibrary.org/obo/AfPO_0000450"
]

for an in annotations:
    query_annotation(an)
