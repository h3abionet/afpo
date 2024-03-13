from rdflib import Graph, Namespace, URIRef, Literal
from rdflib.plugins.sparql import prepareQuery


g = Graph().parse(location="ontology/afpo-edit.owl")

prep_query = prepareQuery(
    "SELECT ?term ?value WHERE { ?term ?annotation ?value . }",
    initNs={"AfPO": Namespace("http://purl.obolibrary.org/obo/AfPO_")}
)


def split_annotation():
    annotations = [
        "http://purl.obolibrary.org/obo/AfPO_0000450",
        "http://purl.obolibrary.org/obo/AfPO_0000565"
    ]
    g_annotations = Graph()
    for an in annotations:
        qres = g.query(prep_query, initBindings={"annotation": URIRef(an)})
        for row in qres:
            t, v = row
            for value in v.split(", "):
                g_annotations.add((URIRef(t), URIRef(an), Literal(value)))
            g.remove((URIRef(t), URIRef(an), Literal(v)))

    g_annotations.serialize(destination="annotations.owl", format="xml")
    g.serialize(destination="afpo-edit-annotation.owl", format="xml")


split_annotation()
