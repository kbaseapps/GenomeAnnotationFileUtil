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

    typedef structure {
        string input_ref;
    } ExportParams;

    typedef structure {
        string shock_id;
    } ExportOutput;

    /*
        A method designed especially for download, this calls 'genome_annotation_to_genbank' to do
        the work, but then packages the output with WS provenance and object info into
        a zip file and saves to shock.
    */
    funcdef export_genome_annotation_as_genbank(ExportParams params)
                returns (ExportOutput output) authentication required;

    /*---------------- Copy of types of sub-elements GenomeAnnotation ----------------*/

    /*
        contig_id - the identifier for the contig to which this region corresponds.
        strand - either a "+" or a "-", for the strand on which the region is located.
        start - starting position for this region.
        length - distance from the start position that bounds the end of the region.
    */
    typedef structure {
        string contig_id;
        string strand;
        int start;
        int length;
    }  Region;

    /*
        protein_id - protein identifier, which is feature ID plus ".protein"
        protein_amino_acid_sequence - amino acid sequence for this protein
        protein_function - function of protein
        protein_aliases - list of aliases for the protein
        protein_md5 - MD5 hash of the protein translation (uppercase)
    */
    typedef structure {
        string protein_id;
        string protein_amino_acid_sequence;
        string protein_function;
        list<string> protein_aliases;
        string protein_md5;
        list<string> protein_domain_locations;
    }  ProteinData;

    /*
        feature_id - identifier for this feature 
        feature_type - the Feature type e.g., "mRNA", "CDS", "gene", ... 
        feature_function - the functional annotation description
        feature_aliases - dictionary of Alias string to List of source string identifiers
        feature_dna_sequence_length - integer representing the length of the DNA sequence for 
            convenience
        feature_dna_sequence - string containing the DNA sequence of the Feature
        feature_md5 - string containing the MD5 of the sequence, calculated from the uppercase string
        feature_locations - list of Feature regions, where the Feature bounds are calculated as follows:
            - For "+" strand, [start, start + length)
            - For "-" strand, (start - length, start]
         feature_publications - ist of any known publications related to this Feature
        feature_quality_warnings - list of strings indicating known data quality issues (note: not used for 
            Genome type, but is used for GenomeAnnotation)
        feature_quality_score - quality value with unknown algorithm for Genomes, not calculated yet for 
            GenomeAnnotations.
        feature_notes - notes recorded about this Feature
        feature_inference - inference information
    */
    typedef structure {
        string feature_id;
        string feature_type;
        string feature_function;
        mapping<string, list<string>> feature_aliases;
        int feature_dna_sequence_length;
        string feature_dna_sequence;
        string feature_md5;
        list<Region> feature_locations;
        list<string> feature_publications;
        list<string> feature_quality_warnings;
        list<string> feature_quality_score;
        string feature_notes;
        string feature_inference;
        ProteinData protein;
    }  FeatureData;

    /*
        scientific_name - scientific name of the organism.
        taxonomy_id - NCBI taxonomic id of the organism.
        kingdom - taxonomic kingdom of the organism.
        scientific_lineage - scientific lineage of the organism.
        genetic_code - scientific name of the organism.
        organism_aliases - aliases for the organism associated with this GenomeAnnotation.
        assembly_source - source organization for the Assembly.
        assembly_source_id - identifier for the Assembly used by the source organization.
        assembly_source_date - date of origin the source indicates for the Assembly.
        gc_content - GC content for the entire Assembly.
        dna_size - total DNA size for the Assembly.
        num_contigs - number of contigs in the Assembly.
        contig_ids - contig identifier strings for the Assembly.
        external_source - name of the external source.
        external_source_date - date of origin the external source indicates for this GenomeAnnotation.
        release - release version for this GenomeAnnotation data.
        original_source_filename - name of the file used to generate this GenomeAnnotation.
        feature_type_counts - number of features of each type.
    */
    typedef structure {
        string scientific_name;
        int taxonomy_id;
        string kingdom;
        list<string> scientific_lineage;
        int genetic_code;
        list<string> organism_aliases;
        string assembly_source;
        string assembly_source_id;
        string assembly_source_date;
        float gc_content;
        int dna_size;
        int num_contigs;
        list<string> contig_ids;
        string external_source;
        string external_source_date;
        string release;
        string original_source_filename;
        mapping<string, int> feature_type_counts;
        list<FeatureData> features;
    } GenomeData;

    typedef structure {
        string genome_ref;
    } LoadNewGenomeDataParams;

    funcdef load_new_genome_data(LoadNewGenomeDataParams params)
        returns (GenomeData) authentication required;
};
