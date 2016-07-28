package GenomeAnnotationFileUtil::GenomeAnnotationFileUtilClient;

use JSON::RPC::Client;
use POSIX;
use strict;
use Data::Dumper;
use URI;
use Bio::KBase::Exceptions;
my $get_time = sub { time, 0 };
eval {
    require Time::HiRes;
    $get_time = sub { Time::HiRes::gettimeofday() };
};

use Bio::KBase::AuthToken;

# Client version should match Impl version
# This is a Semantic Version number,
# http://semver.org
our $VERSION = "0.1.0";

=head1 NAME

GenomeAnnotationFileUtil::GenomeAnnotationFileUtilClient

=head1 DESCRIPTION





=cut

sub new
{
    my($class, $url, @args) = @_;
    

    my $self = {
	client => GenomeAnnotationFileUtil::GenomeAnnotationFileUtilClient::RpcClient->new,
	url => $url,
	headers => [],
    };

    chomp($self->{hostname} = `hostname`);
    $self->{hostname} ||= 'unknown-host';

    #
    # Set up for propagating KBRPC_TAG and KBRPC_METADATA environment variables through
    # to invoked services. If these values are not set, we create a new tag
    # and a metadata field with basic information about the invoking script.
    #
    if ($ENV{KBRPC_TAG})
    {
	$self->{kbrpc_tag} = $ENV{KBRPC_TAG};
    }
    else
    {
	my ($t, $us) = &$get_time();
	$us = sprintf("%06d", $us);
	my $ts = strftime("%Y-%m-%dT%H:%M:%S.${us}Z", gmtime $t);
	$self->{kbrpc_tag} = "C:$0:$self->{hostname}:$$:$ts";
    }
    push(@{$self->{headers}}, 'Kbrpc-Tag', $self->{kbrpc_tag});

    if ($ENV{KBRPC_METADATA})
    {
	$self->{kbrpc_metadata} = $ENV{KBRPC_METADATA};
	push(@{$self->{headers}}, 'Kbrpc-Metadata', $self->{kbrpc_metadata});
    }

    if ($ENV{KBRPC_ERROR_DEST})
    {
	$self->{kbrpc_error_dest} = $ENV{KBRPC_ERROR_DEST};
	push(@{$self->{headers}}, 'Kbrpc-Errordest', $self->{kbrpc_error_dest});
    }

    #
    # This module requires authentication.
    #
    # We create an auth token, passing through the arguments that we were (hopefully) given.

    {
	my $token = Bio::KBase::AuthToken->new(@args);
	
	if (!$token->error_message)
	{
	    $self->{token} = $token->token;
	    $self->{client}->{token} = $token->token;
	}
        else
        {
	    #
	    # All methods in this module require authentication. In this case, if we
	    # don't have a token, we can't continue.
	    #
	    die "Authentication failed: " . $token->error_message;
	}
    }

    my $ua = $self->{client}->ua;	 
    my $timeout = $ENV{CDMI_TIMEOUT} || (30 * 60);	 
    $ua->timeout($timeout);
    bless $self, $class;
    #    $self->_validate_version();
    return $self;
}




=head2 genbank_to_genome_annotation

  $details = $obj->genbank_to_genome_annotation($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a GenomeAnnotationFileUtil.GenbankToGenomeAnnotationParams
$details is a GenomeAnnotationFileUtil.GenomeAnnotationDetails
GenbankToGenomeAnnotationParams is a reference to a hash where the following keys are defined:
	file_path has a value which is a string
	shock_id has a value which is a string
	ftp_url has a value which is a string
	genome_name has a value which is a string
	workspace_name has a value which is a string
	source has a value which is a string
	taxon_wsname has a value which is a string
	convert_to_legacy has a value which is a GenomeAnnotationFileUtil.boolean
boolean is an int
GenomeAnnotationDetails is a reference to a hash where the following keys are defined:
	genome_annotation_ref has a value which is a string

</pre>

=end html

=begin text

$params is a GenomeAnnotationFileUtil.GenbankToGenomeAnnotationParams
$details is a GenomeAnnotationFileUtil.GenomeAnnotationDetails
GenbankToGenomeAnnotationParams is a reference to a hash where the following keys are defined:
	file_path has a value which is a string
	shock_id has a value which is a string
	ftp_url has a value which is a string
	genome_name has a value which is a string
	workspace_name has a value which is a string
	source has a value which is a string
	taxon_wsname has a value which is a string
	convert_to_legacy has a value which is a GenomeAnnotationFileUtil.boolean
boolean is an int
GenomeAnnotationDetails is a reference to a hash where the following keys are defined:
	genome_annotation_ref has a value which is a string


=end text

=item Description



=back

=cut

 sub genbank_to_genome_annotation
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function genbank_to_genome_annotation (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to genbank_to_genome_annotation:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'genbank_to_genome_annotation');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "GenomeAnnotationFileUtil.genbank_to_genome_annotation",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'genbank_to_genome_annotation',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method genbank_to_genome_annotation",
					    status_line => $self->{client}->status_line,
					    method_name => 'genbank_to_genome_annotation',
				       );
    }
}
 


=head2 genome_annotation_to_genbank

  $file = $obj->genome_annotation_to_genbank($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a GenomeAnnotationFileUtil.GenomeAnnotationToGenbankParams
$file is a GenomeAnnotationFileUtil.GenbankFile
GenomeAnnotationToGenbankParams is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
	genome_name has a value which is a string
	workspace_name has a value which is a string
	new_genbank_file_name has a value which is a string
	save_to_shock has a value which is a GenomeAnnotationFileUtil.boolean
boolean is an int
GenbankFile is a reference to a hash where the following keys are defined:
	path has a value which is a string
	shock_id has a value which is a string

</pre>

=end html

=begin text

$params is a GenomeAnnotationFileUtil.GenomeAnnotationToGenbankParams
$file is a GenomeAnnotationFileUtil.GenbankFile
GenomeAnnotationToGenbankParams is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
	genome_name has a value which is a string
	workspace_name has a value which is a string
	new_genbank_file_name has a value which is a string
	save_to_shock has a value which is a GenomeAnnotationFileUtil.boolean
boolean is an int
GenbankFile is a reference to a hash where the following keys are defined:
	path has a value which is a string
	shock_id has a value which is a string


=end text

=item Description



=back

=cut

 sub genome_annotation_to_genbank
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function genome_annotation_to_genbank (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to genome_annotation_to_genbank:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'genome_annotation_to_genbank');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "GenomeAnnotationFileUtil.genome_annotation_to_genbank",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'genome_annotation_to_genbank',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method genome_annotation_to_genbank",
					    status_line => $self->{client}->status_line,
					    method_name => 'genome_annotation_to_genbank',
				       );
    }
}
 


=head2 export_genome_annotation_as_genbank

  $output = $obj->export_genome_annotation_as_genbank($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a GenomeAnnotationFileUtil.ExportParams
$output is a GenomeAnnotationFileUtil.ExportOutput
ExportParams is a reference to a hash where the following keys are defined:
	input_ref has a value which is a string
ExportOutput is a reference to a hash where the following keys are defined:
	shock_id has a value which is a string

</pre>

=end html

=begin text

$params is a GenomeAnnotationFileUtil.ExportParams
$output is a GenomeAnnotationFileUtil.ExportOutput
ExportParams is a reference to a hash where the following keys are defined:
	input_ref has a value which is a string
ExportOutput is a reference to a hash where the following keys are defined:
	shock_id has a value which is a string


=end text

=item Description

A method designed especially for download, this calls 'genome_annotation_to_genbank' to do
the work, but then packages the output with WS provenance and object info into
a zip file and saves to shock.

=back

=cut

 sub export_genome_annotation_as_genbank
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function export_genome_annotation_as_genbank (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to export_genome_annotation_as_genbank:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'export_genome_annotation_as_genbank');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "GenomeAnnotationFileUtil.export_genome_annotation_as_genbank",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'export_genome_annotation_as_genbank',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method export_genome_annotation_as_genbank",
					    status_line => $self->{client}->status_line,
					    method_name => 'export_genome_annotation_as_genbank',
				       );
    }
}
 


=head2 load_new_genome_data

  $return = $obj->load_new_genome_data($params)

=over 4

=item Parameter and return types

=begin html

<pre>
$params is a GenomeAnnotationFileUtil.LoadNewGenomeDataParams
$return is a GenomeAnnotationFileUtil.GenomeData
LoadNewGenomeDataParams is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
GenomeData is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	taxonomy_id has a value which is an int
	kingdom has a value which is a string
	scientific_lineage has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	organism_aliases has a value which is a reference to a list where each element is a string
	assembly_source has a value which is a string
	assembly_source_id has a value which is a string
	assembly_source_date has a value which is a string
	gc_content has a value which is a float
	dna_size has a value which is an int
	num_contigs has a value which is an int
	contig_ids has a value which is a reference to a list where each element is a string
	external_source has a value which is a string
	external_source_date has a value which is a string
	release has a value which is a string
	original_source_filename has a value which is a string
	feature_type_counts has a value which is a reference to a hash where the key is a string and the value is an int
	features has a value which is a reference to a list where each element is a GenomeAnnotationFileUtil.FeatureData
FeatureData is a reference to a hash where the following keys are defined:
	feature_id has a value which is a string
	feature_type has a value which is a string
	feature_function has a value which is a string
	feature_aliases has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
	feature_dna_sequence_length has a value which is an int
	feature_dna_sequence has a value which is a string
	feature_md5 has a value which is a string
	feature_locations has a value which is a reference to a list where each element is a GenomeAnnotationFileUtil.Region
	feature_publications has a value which is a reference to a list where each element is a string
	feature_quality_warnings has a value which is a reference to a list where each element is a string
	feature_quality_score has a value which is a reference to a list where each element is a string
	feature_notes has a value which is a string
	feature_inference has a value which is a string
	protein has a value which is a GenomeAnnotationFileUtil.ProteinData
Region is a reference to a hash where the following keys are defined:
	contig_id has a value which is a string
	strand has a value which is a string
	start has a value which is an int
	length has a value which is an int
ProteinData is a reference to a hash where the following keys are defined:
	protein_id has a value which is a string
	protein_amino_acid_sequence has a value which is a string
	protein_function has a value which is a string
	protein_aliases has a value which is a reference to a list where each element is a string
	protein_md5 has a value which is a string
	protein_domain_locations has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

$params is a GenomeAnnotationFileUtil.LoadNewGenomeDataParams
$return is a GenomeAnnotationFileUtil.GenomeData
LoadNewGenomeDataParams is a reference to a hash where the following keys are defined:
	genome_ref has a value which is a string
GenomeData is a reference to a hash where the following keys are defined:
	scientific_name has a value which is a string
	taxonomy_id has a value which is an int
	kingdom has a value which is a string
	scientific_lineage has a value which is a reference to a list where each element is a string
	genetic_code has a value which is an int
	organism_aliases has a value which is a reference to a list where each element is a string
	assembly_source has a value which is a string
	assembly_source_id has a value which is a string
	assembly_source_date has a value which is a string
	gc_content has a value which is a float
	dna_size has a value which is an int
	num_contigs has a value which is an int
	contig_ids has a value which is a reference to a list where each element is a string
	external_source has a value which is a string
	external_source_date has a value which is a string
	release has a value which is a string
	original_source_filename has a value which is a string
	feature_type_counts has a value which is a reference to a hash where the key is a string and the value is an int
	features has a value which is a reference to a list where each element is a GenomeAnnotationFileUtil.FeatureData
FeatureData is a reference to a hash where the following keys are defined:
	feature_id has a value which is a string
	feature_type has a value which is a string
	feature_function has a value which is a string
	feature_aliases has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
	feature_dna_sequence_length has a value which is an int
	feature_dna_sequence has a value which is a string
	feature_md5 has a value which is a string
	feature_locations has a value which is a reference to a list where each element is a GenomeAnnotationFileUtil.Region
	feature_publications has a value which is a reference to a list where each element is a string
	feature_quality_warnings has a value which is a reference to a list where each element is a string
	feature_quality_score has a value which is a reference to a list where each element is a string
	feature_notes has a value which is a string
	feature_inference has a value which is a string
	protein has a value which is a GenomeAnnotationFileUtil.ProteinData
Region is a reference to a hash where the following keys are defined:
	contig_id has a value which is a string
	strand has a value which is a string
	start has a value which is an int
	length has a value which is an int
ProteinData is a reference to a hash where the following keys are defined:
	protein_id has a value which is a string
	protein_amino_acid_sequence has a value which is a string
	protein_function has a value which is a string
	protein_aliases has a value which is a reference to a list where each element is a string
	protein_md5 has a value which is a string
	protein_domain_locations has a value which is a reference to a list where each element is a string


=end text

=item Description



=back

=cut

 sub load_new_genome_data
{
    my($self, @args) = @_;

# Authentication: required

    if ((my $n = @args) != 1)
    {
	Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
							       "Invalid argument count for function load_new_genome_data (received $n, expecting 1)");
    }
    {
	my($params) = @args;

	my @_bad_arguments;
        (ref($params) eq 'HASH') or push(@_bad_arguments, "Invalid type for argument 1 \"params\" (value was \"$params\")");
        if (@_bad_arguments) {
	    my $msg = "Invalid arguments passed to load_new_genome_data:\n" . join("", map { "\t$_\n" } @_bad_arguments);
	    Bio::KBase::Exceptions::ArgumentValidationError->throw(error => $msg,
								   method_name => 'load_new_genome_data');
	}
    }

    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
	    method => "GenomeAnnotationFileUtil.load_new_genome_data",
	    params => \@args,
    });
    if ($result) {
	if ($result->is_error) {
	    Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
					       code => $result->content->{error}->{code},
					       method_name => 'load_new_genome_data',
					       data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
					      );
	} else {
	    return wantarray ? @{$result->result} : $result->result->[0];
	}
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method load_new_genome_data",
					    status_line => $self->{client}->status_line,
					    method_name => 'load_new_genome_data',
				       );
    }
}
 
  
sub status
{
    my($self, @args) = @_;
    if ((my $n = @args) != 0) {
        Bio::KBase::Exceptions::ArgumentValidationError->throw(error =>
                                   "Invalid argument count for function status (received $n, expecting 0)");
    }
    my $url = $self->{url};
    my $result = $self->{client}->call($url, $self->{headers}, {
        method => "GenomeAnnotationFileUtil.status",
        params => \@args,
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(error => $result->error_message,
                           code => $result->content->{error}->{code},
                           method_name => 'status',
                           data => $result->content->{error}->{error} # JSON::RPC::ReturnObject only supports JSONRPC 1.1 or 1.O
                          );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(error => "Error invoking method status",
                        status_line => $self->{client}->status_line,
                        method_name => 'status',
                       );
    }
}
   

sub version {
    my ($self) = @_;
    my $result = $self->{client}->call($self->{url}, $self->{headers}, {
        method => "GenomeAnnotationFileUtil.version",
        params => [],
    });
    if ($result) {
        if ($result->is_error) {
            Bio::KBase::Exceptions::JSONRPC->throw(
                error => $result->error_message,
                code => $result->content->{code},
                method_name => 'load_new_genome_data',
            );
        } else {
            return wantarray ? @{$result->result} : $result->result->[0];
        }
    } else {
        Bio::KBase::Exceptions::HTTP->throw(
            error => "Error invoking method load_new_genome_data",
            status_line => $self->{client}->status_line,
            method_name => 'load_new_genome_data',
        );
    }
}

sub _validate_version {
    my ($self) = @_;
    my $svr_version = $self->version();
    my $client_version = $VERSION;
    my ($cMajor, $cMinor) = split(/\./, $client_version);
    my ($sMajor, $sMinor) = split(/\./, $svr_version);
    if ($sMajor != $cMajor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Major version numbers differ.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor < $cMinor) {
        Bio::KBase::Exceptions::ClientServerIncompatible->throw(
            error => "Client minor version greater than Server minor version.",
            server_version => $svr_version,
            client_version => $client_version
        );
    }
    if ($sMinor > $cMinor) {
        warn "New client version available for GenomeAnnotationFileUtil::GenomeAnnotationFileUtilClient\n";
    }
    if ($sMajor == 0) {
        warn "GenomeAnnotationFileUtil::GenomeAnnotationFileUtilClient version is $svr_version. API subject to change.\n";
    }
}

=head1 TYPES



=head2 boolean

=over 4



=item Description

A boolean - 0 for false, 1 for true.
@range (0, 1)


=item Definition

=begin html

<pre>
an int
</pre>

=end html

=begin text

an int

=end text

=back



=head2 GenbankToGenomeAnnotationParams

=over 4



=item Description

file_path or shock_id -- Local path or shock_id of the uploaded file with genome
               sequence in GenBank format or zip-file with GenBank files.

genome_name -- The name you would like to use to reference this GenomeAnnotation.  
               If not supplied, will use the Taxon Id and the data source to 
               determine the name.
taxon_wsname - name of the workspace containing the Taxonomy data, defaults to 'ReferenceTaxons'


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
file_path has a value which is a string
shock_id has a value which is a string
ftp_url has a value which is a string
genome_name has a value which is a string
workspace_name has a value which is a string
source has a value which is a string
taxon_wsname has a value which is a string
convert_to_legacy has a value which is a GenomeAnnotationFileUtil.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
file_path has a value which is a string
shock_id has a value which is a string
ftp_url has a value which is a string
genome_name has a value which is a string
workspace_name has a value which is a string
source has a value which is a string
taxon_wsname has a value which is a string
convert_to_legacy has a value which is a GenomeAnnotationFileUtil.boolean


=end text

=back



=head2 GenomeAnnotationDetails

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_annotation_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_annotation_ref has a value which is a string


=end text

=back



=head2 GenomeAnnotationToGenbankParams

=over 4



=item Description

genome_ref -- Reference to the GenomeAnnotation or Genome object in KBase in 
              any ws supported format
OR
genome_name + workspace_name -- specifiy the genome name and workspace name
              of what you want.  If genome_ref is defined, these args are ignored.

new_genbank_file_name -- specify the output name of the genbank file, optional

save_to_shock -- set to 1 or 0, if 1 then output is saved to shock. default is zero


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_ref has a value which is a string
genome_name has a value which is a string
workspace_name has a value which is a string
new_genbank_file_name has a value which is a string
save_to_shock has a value which is a GenomeAnnotationFileUtil.boolean

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_ref has a value which is a string
genome_name has a value which is a string
workspace_name has a value which is a string
new_genbank_file_name has a value which is a string
save_to_shock has a value which is a GenomeAnnotationFileUtil.boolean


=end text

=back



=head2 GenbankFile

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
path has a value which is a string
shock_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
path has a value which is a string
shock_id has a value which is a string


=end text

=back



=head2 ExportParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
input_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
input_ref has a value which is a string


=end text

=back



=head2 ExportOutput

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
shock_id has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
shock_id has a value which is a string


=end text

=back



=head2 Region

=over 4



=item Description

contig_id - the identifier for the contig to which this region corresponds.
strand - either a "+" or a "-", for the strand on which the region is located.
start - starting position for this region.
length - distance from the start position that bounds the end of the region.


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
contig_id has a value which is a string
strand has a value which is a string
start has a value which is an int
length has a value which is an int

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
contig_id has a value which is a string
strand has a value which is a string
start has a value which is an int
length has a value which is an int


=end text

=back



=head2 ProteinData

=over 4



=item Description

protein_id - protein identifier, which is feature ID plus ".protein"
protein_amino_acid_sequence - amino acid sequence for this protein
protein_function - function of protein
protein_aliases - list of aliases for the protein
protein_md5 - MD5 hash of the protein translation (uppercase)


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
protein_id has a value which is a string
protein_amino_acid_sequence has a value which is a string
protein_function has a value which is a string
protein_aliases has a value which is a reference to a list where each element is a string
protein_md5 has a value which is a string
protein_domain_locations has a value which is a reference to a list where each element is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
protein_id has a value which is a string
protein_amino_acid_sequence has a value which is a string
protein_function has a value which is a string
protein_aliases has a value which is a reference to a list where each element is a string
protein_md5 has a value which is a string
protein_domain_locations has a value which is a reference to a list where each element is a string


=end text

=back



=head2 FeatureData

=over 4



=item Description

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


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
feature_id has a value which is a string
feature_type has a value which is a string
feature_function has a value which is a string
feature_aliases has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
feature_dna_sequence_length has a value which is an int
feature_dna_sequence has a value which is a string
feature_md5 has a value which is a string
feature_locations has a value which is a reference to a list where each element is a GenomeAnnotationFileUtil.Region
feature_publications has a value which is a reference to a list where each element is a string
feature_quality_warnings has a value which is a reference to a list where each element is a string
feature_quality_score has a value which is a reference to a list where each element is a string
feature_notes has a value which is a string
feature_inference has a value which is a string
protein has a value which is a GenomeAnnotationFileUtil.ProteinData

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
feature_id has a value which is a string
feature_type has a value which is a string
feature_function has a value which is a string
feature_aliases has a value which is a reference to a hash where the key is a string and the value is a reference to a list where each element is a string
feature_dna_sequence_length has a value which is an int
feature_dna_sequence has a value which is a string
feature_md5 has a value which is a string
feature_locations has a value which is a reference to a list where each element is a GenomeAnnotationFileUtil.Region
feature_publications has a value which is a reference to a list where each element is a string
feature_quality_warnings has a value which is a reference to a list where each element is a string
feature_quality_score has a value which is a reference to a list where each element is a string
feature_notes has a value which is a string
feature_inference has a value which is a string
protein has a value which is a GenomeAnnotationFileUtil.ProteinData


=end text

=back



=head2 GenomeData

=over 4



=item Description

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


=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
taxonomy_id has a value which is an int
kingdom has a value which is a string
scientific_lineage has a value which is a reference to a list where each element is a string
genetic_code has a value which is an int
organism_aliases has a value which is a reference to a list where each element is a string
assembly_source has a value which is a string
assembly_source_id has a value which is a string
assembly_source_date has a value which is a string
gc_content has a value which is a float
dna_size has a value which is an int
num_contigs has a value which is an int
contig_ids has a value which is a reference to a list where each element is a string
external_source has a value which is a string
external_source_date has a value which is a string
release has a value which is a string
original_source_filename has a value which is a string
feature_type_counts has a value which is a reference to a hash where the key is a string and the value is an int
features has a value which is a reference to a list where each element is a GenomeAnnotationFileUtil.FeatureData

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
scientific_name has a value which is a string
taxonomy_id has a value which is an int
kingdom has a value which is a string
scientific_lineage has a value which is a reference to a list where each element is a string
genetic_code has a value which is an int
organism_aliases has a value which is a reference to a list where each element is a string
assembly_source has a value which is a string
assembly_source_id has a value which is a string
assembly_source_date has a value which is a string
gc_content has a value which is a float
dna_size has a value which is an int
num_contigs has a value which is an int
contig_ids has a value which is a reference to a list where each element is a string
external_source has a value which is a string
external_source_date has a value which is a string
release has a value which is a string
original_source_filename has a value which is a string
feature_type_counts has a value which is a reference to a hash where the key is a string and the value is an int
features has a value which is a reference to a list where each element is a GenomeAnnotationFileUtil.FeatureData


=end text

=back



=head2 LoadNewGenomeDataParams

=over 4



=item Definition

=begin html

<pre>
a reference to a hash where the following keys are defined:
genome_ref has a value which is a string

</pre>

=end html

=begin text

a reference to a hash where the following keys are defined:
genome_ref has a value which is a string


=end text

=back



=cut

package GenomeAnnotationFileUtil::GenomeAnnotationFileUtilClient::RpcClient;
use base 'JSON::RPC::Client';
use POSIX;
use strict;

#
# Override JSON::RPC::Client::call because it doesn't handle error returns properly.
#

sub call {
    my ($self, $uri, $headers, $obj) = @_;
    my $result;


    {
	if ($uri =~ /\?/) {
	    $result = $self->_get($uri);
	}
	else {
	    Carp::croak "not hashref." unless (ref $obj eq 'HASH');
	    $result = $self->_post($uri, $headers, $obj);
	}

    }

    my $service = $obj->{method} =~ /^system\./ if ( $obj );

    $self->status_line($result->status_line);

    if ($result->is_success) {

        return unless($result->content); # notification?

        if ($service) {
            return JSON::RPC::ServiceObject->new($result, $self->json);
        }

        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    elsif ($result->content_type eq 'application/json')
    {
        return JSON::RPC::ReturnObject->new($result, $self->json);
    }
    else {
        return;
    }
}


sub _post {
    my ($self, $uri, $headers, $obj) = @_;
    my $json = $self->json;

    $obj->{version} ||= $self->{version} || '1.1';

    if ($obj->{version} eq '1.0') {
        delete $obj->{version};
        if (exists $obj->{id}) {
            $self->id($obj->{id}) if ($obj->{id}); # if undef, it is notification.
        }
        else {
            $obj->{id} = $self->id || ($self->id('JSON::RPC::Client'));
        }
    }
    else {
        # $obj->{id} = $self->id if (defined $self->id);
	# Assign a random number to the id if one hasn't been set
	$obj->{id} = (defined $self->id) ? $self->id : substr(rand(),2);
    }

    my $content = $json->encode($obj);

    $self->ua->post(
        $uri,
        Content_Type   => $self->{content_type},
        Content        => $content,
        Accept         => 'application/json',
	@$headers,
	($self->{token} ? (Authorization => $self->{token}) : ()),
    );
}



1;
