from rdflib import Graph, Literal, Namespace, URIRef
from rdflib.plugins.sparql import prepareQuery

g = Graph().parse(location="ontology/afpo-edit.owl")

prep_query = prepareQuery(
    "SELECT ?term ?value WHERE { ?term ?annotation ?value . }",
    initNs={"AfPO": Namespace("http://purl.obolibrary.org/obo/AfPO_")}
)


def split_annotation():
    annotations = [
        "http://purl.obolibrary.org/obo/AfPO_0000453",
        # "http://purl.obolibrary.org/obo/AfPO_0000450",
        # "http://purl.obolibrary.org/obo/AfPO_0000565"
    ]
    sep_cases = [
        ", and ",
        ", OR ",
        ", or ",
        " or ",
        " / ",
        ", ",
        ","
    ]
    g_annotations = Graph()
    for an in annotations:
        qres = g.query(prep_query, initBindings={"annotation": URIRef(an)})
        for row in qres:
            t, v = row
            values = v.split(",")
            for value in values:
                g_annotations.add((URIRef(t), URIRef(an), Literal(value)))
            g.remove((URIRef(t), URIRef(an), Literal(v)))

    g_annotations.serialize(destination="annotations.owl", format="xml")
    g.serialize(destination="afpo-edit-annotation.owl", format="xml")


split_annotation()
