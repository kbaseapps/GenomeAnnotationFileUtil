#BEGIN_HEADER

import os
import sys
import shutil
import traceback
import uuid
from pprint import pprint, pformat

from biokbase.workspace.client import Workspace

# utilities for unpacking things- could switch to functions in DataFileUtil when available
import biokbase.Transform.script_utils as script_utils

import trns_transform_Genbank_Genome_to_KBaseGenomeAnnotations_GenomeAnnotation as uploader
from DataFileUtil.DataFileUtilClient import DataFileUtil

#END_HEADER


class GenomeAnnotationFileUtil:
    '''
    Module Name:
    GenomeAnnotationFileUtil

    Module Description:
    
    '''

    ######## WARNING FOR GEVENT USERS #######
    # Since asynchronous IO can lead to methods - even the same method -
    # interrupting each other, you must be *very* careful when using global
    # state. A method could easily clobber the state set by another while
    # the latter method is running.
    #########################################
    VERSION = "0.0.1"
    GIT_URL = ""
    GIT_COMMIT_HASH = "HEAD"
    
    #BEGIN_CLASS_HEADER
    #END_CLASS_HEADER

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        self.workspaceURL = config['workspace-url']
        self.shockURL = config['shock-url']
        self.handleURL = config['handle-service-url']
        self.sharedFolder = config['scratch']
        #END_CONSTRUCTOR
        pass
    

    def genbank_to_genome_annotation(self, ctx, params):
        """
        :param params: instance of type "GenbankToGenomeAnnotationParams"
           (file_path or shock_id -- Local path or shock_id of the uploaded
           file with genome sequence in GenBank format or zip-file with
           GenBank files. genome_name -- The name you would like to use to
           reference this GenomeAnnotation. If not supplied, will use the
           Taxon Id and the data source to determine the name.) -> structure:
           parameter "file_path" of String, parameter "shock_id" of String,
           parameter "ftp_url" of String, parameter "genome_name" of String,
           parameter "workspace_name" of String, parameter "source" of String
        :returns: instance of type "GenomeAnnotationDetails" -> structure:
        """
        # ctx is the context object
        # return variables are: details
        #BEGIN genbank_to_genome_annotation

        print('genbank_to_genome_annotation -- paramaters = ')
        pprint(params)

        # validate input and set defaults.  Note that because we don't call the uploader method
        # as a stand alone script, we do the validation here.
        if 'workspace_name' not in params:
            raise ValueError('workspace_name field was not defined')
        workspace_name = params['workspace_name']

        if 'genome_name' not in params:
            raise ValueError('genome_name field was not defined')
        genome_name = params['genome_name']

        source = 'Genbank'
        if 'source' in params:
            source = source;

        taxon_wsname = 'ReferenceTaxons'
        if 'taxon_wsname' in params:
            taxon_wsname = params['taxon_wsname']

        # other options to handle
        # release
        # taxon_reference
        # exclude_feature_types
        # type


        # construct the input directory where we stage files
        input_directory =  os.path.join(self.sharedFolder, 'assembly-upload-staging-'+str(uuid.uuid4()))
        os.makedirs(input_directory)

        # determine how to get the file: if it is from shock, download it.  If it
        # is just sitting there, then use it.  Move the file to the staging input directory


        genbank_file_path = None

        if 'file_path' not in params:
            if 'shock_id' not in params:
                if 'ftp_url' not in params:
                    raise ValueError('No input file (either file_path, shock_id, or ftp_url) provided')
                else:
                    # TODO handle ftp - this creates a directory for us, so update the input directory
                    print('calling Transform download utility: script_utils.download');
                    print('URL provided = '+params['ftp_url']);
                    script_utils.download_from_urls(
                            working_directory = input_directory,
                            token = ctx['token'], # not sure why this requires a token to download from a url...
                            urls  = {
                                        'ftpfiles': params['ftp_url']
                                    }
                        );
                    input_directory = os.path.join(input_directory,'ftpfiles')
                    # unpack everything in input directory
                    dir_contents = os.listdir(input_directory)
                    print('downloaded directory listing:')
                    pprint(dir_contents)
                    dir_files = []
                    for f in dir_contents:
                        if os.path.isfile(os.path.join(input_directory, f)):
                            dir_files.append(f)

                    print('processing files in directory...')
                    for f in dir_files:
                        # unpack if needed using the standard transform utility
                        print('unpacking '+f)
                        script_utils.extract_data(filePath=os.path.join(input_directory,f))

            else:
                # handle shock file
                dfUtil = DataFileUtil(os.environ['SDK_CALLBACK_URL'], token=ctx['token'])
                file_name = dfUtil.shock_to_file({
                                    'file_path': input_directory,
                                    'shock_id': params['shock_id']
                                })['node_file_name']
                genbank_file_path = os.path.join(input_directory, file_name)
        else:
            # copy the local file to the input staging directory
            # (NOTE: could just move it, but then this method would have the side effect of moving your
            # file which another SDK module might have an open handle on)
            local_file_path = params['file_path']
            genbank_file_path = os.path.join(input_directory, os.path.basename(local_file_path))
            shutil.copy2(local_file_path, genbank_file_path)

        if genbank_file_path is not None:
            print("input genbank file =" + genbank_file_path)

            # unpack if needed using the standard transform utility
            script_utils.extract_data(filePath=genbank_file_path)

        # do the upload (doesn't seem to return any information)
        uploader.upload_genome(
                logger=None,

                shock_service_url = self.shockURL,
                handle_service_url = self.handleURL,
                workspace_service_url = self.workspaceURL,

                input_directory=input_directory,

                workspace_name   = workspace_name,
                core_genome_name = genome_name,
                source           = source,
                taxon_wsname     = taxon_wsname
            )

        #### Code to convert to legacy type if requested
        if 'convert_to_legacy' in params and params['convert_to_legacy']==1:
            from doekbase.data_api.converters import genome as cvt
            print('Converting to legacy type, object={}'.format(genome_name))
            cvt.convert_genome(
                    shock_url=self.shockURL,
                    handle_url=self.handleURL,
                    ws_url=self.workspaceURL,
                    obj_name=genome_name,
                    ws_name=workspace_name)


        # get WS metadata to return the reference to the object (could be returned by the uploader method...)
        ws = Workspace(url=self.workspaceURL)
        info = ws.get_object_info_new({'objects':[{'ref':workspace_name + '/' + genome_name}],'includeMetadata':0, 'ignoreErrors':0})[0]

        details = {
            'genome_annotation_ref':str(info[6]) + '/' + str(info[0]) + '/' + str(info[4])
        }


        #END genbank_to_genome_annotation

        # At some point might do deeper type checking...
        if not isinstance(details, dict):
            raise ValueError('Method genbank_to_genome_annotation return value ' +
                             'details is not type dict as required.')
        # return the results
        return [details]

    def status(self, ctx):
        #BEGIN_STATUS
        returnVal = {'state': "OK", 'message': "", 'version': self.VERSION, 
                     'git_url': self.GIT_URL, 'git_commit_hash': self.GIT_COMMIT_HASH}
        #END_STATUS
        return [returnVal]
