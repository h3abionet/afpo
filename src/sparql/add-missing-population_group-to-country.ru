PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
PREFIX owl: <http://www.w3.org/2002/07/owl#>
PREFIX Country: <http://purl.obolibrary.org/obo/NCIT_C25464>
PREFIX population_group: <http://purl.obolibrary.org/obo/AfPO_0000447>
PREFIX Population: <http://purl.obolibrary.org/obo/AfPO_0000146>
PREFIX hasCountryOfOrigin: <http://purl.obolibrary.org/obo/HANCESTRO_0308>

INSERT {
  ?country rdfs:subClassOf [
      a owl:Restriction ;
      owl:onProperty population_group:;
      owl:someValuesFrom ?population
  ] .

}
WHERE {
  ?country rdfs:subClassOf [
      a owl:Restriction ;
      owl:onProperty population_group:;
      owl:someValuesFrom ?population_group
  ] .
  ?population rdfs:subClassOf [
      a owl:Restriction ;
      owl:onProperty hasCountryOfOrigin:;
      owl:someValuesFrom ?country_origin
  ] .
  FILTER NOT EXISTS {
    ?country_origin rdfs:subClassOf [
        a owl:Restriction ;
        owl:onProperty population_group:;
        owl:someValuesFrom ?population
    ] }
  FILTER (?country = ?country_origin)
}
