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
        string genome_annotation_ref;
    } GenomeAnnotationDetails;


    funcdef genbank_to_genome_annotation(GenbankToGenomeAnnotationParams params)
                returns (GenomeAnnotationDetails details) authentication required;


    /*
        genome_ref -- Reference to the GenomeAnnotation or Genome object in KBase in 
                      any ws supported format
        OR
        genome_name + workspace_name -- specifiy the genome name and workspace name
                      of what you want.  If genome_ref is defined, these args are ignored.
        
        new_genbank_file_name -- specify the output name of the genbank file, optional

        save_to_shock -- set to 1 or 0, if 1 then output is saved to shock. default is zero
     */
    typedef structure {

        string genome_ref;

        string genome_name;
        string workspace_name;

        string new_genbank_file_name;

        boolean save_to_shock;

    } GenomeAnnotationToGenbankParams;


    typedef structure {
        string path;
        string shock_id;
    } GenbankFile;

    funcdef genome_annotation_to_genbank(GenomeAnnotationToGenbankParams params)
                returns (GenbankFile file) authentication required;

};
