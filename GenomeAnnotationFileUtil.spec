/*


*/
module GenomeAnnotationFileUtil {

    /* A boolean - 0 for false, 1 for true.
       @range (0, 1)
    */
    typedef int boolean;

    /*
        file_path or shock_id -- Local path or shock_id of the uploaded file with genome
                       sequence in GenBank format or zip-file with GenBank files.

        genome_name -- The name you would like to use to reference this GenomeAnnotation.  
                       If not supplied, will use the Taxon Id and the data source to 
                       determine the name.
        taxon_wsname - name of the workspace containing the Taxonomy data, defaults to 'ReferenceTaxons'
    */
    typedef structure {
        string file_path;
        string shock_id;
        string ftp_url;

        string genome_name;
        string workspace_name;

        string source;
        string taxon_wsname;

        boolean convert_to_legacy;

    } GenbankToGenomeAnnotationParams;


    /* */
    typedef structure {

    } GenomeAnnotationDetails;


    funcdef genbank_to_genome_annotation(GenbankToGenomeAnnotationParams params)
                returns (GenomeAnnotationDetails details) authentication required;

};
