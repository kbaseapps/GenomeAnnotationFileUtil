import unittest
import os
import json
import time
import shutil
import urllib2
from contextlib import closing

from os import environ
try:
    from ConfigParser import ConfigParser  # py2
except:
    from configparser import ConfigParser  # py3

from pprint import pprint

from biokbase.workspace.client import Workspace as workspaceService
from GenomeAnnotationFileUtil.GenomeAnnotationFileUtilImpl import GenomeAnnotationFileUtil
from GenomeAnnotationFileUtil.GenomeAnnotationFileUtilServer import MethodContext

from DataFileUtil.DataFileUtilClient import DataFileUtil


class GenomeAnnotationFileUtilTest(unittest.TestCase):

    @classmethod
    def setUpClass(cls):
        token = environ.get('KB_AUTH_TOKEN', None)
        # WARNING: don't call any logging methods on the context object,
        # it'll result in a NoneType error
        cls.ctx = MethodContext(None)
        cls.ctx.update({'token': token,
                        'provenance': [
                            {'service': 'GenomeAnnotationFileUtil',
                             'method': 'please_never_use_it_in_production',
                             'method_params': []
                             }],
                        'authenticated': 1})
        config_file = environ.get('KB_DEPLOYMENT_CONFIG', None)
        cls.cfg = {}
        config = ConfigParser()
        config.read(config_file)
        for nameval in config.items('GenomeAnnotationFileUtil'):
            cls.cfg[nameval[0]] = nameval[1]
        cls.wsURL = cls.cfg['workspace-url']
        cls.wsClient = workspaceService(cls.wsURL, token=token)
        cls.serviceImpl = GenomeAnnotationFileUtil(cls.cfg)

    @classmethod
    def tearDownClass(cls):
        if hasattr(cls, 'wsName'):
            cls.wsClient.delete_workspace({'workspace': cls.wsName})
            print('Test workspace was deleted')

    def getWsClient(self):
        return self.__class__.wsClient

    def getWsName(self):
        if hasattr(self.__class__, 'wsName'):
            return self.__class__.wsName
        suffix = int(time.time() * 1000)
        wsName = "test_GenomeAnnotationFileUtil_" + str(suffix)
        ret = self.getWsClient().create_workspace({'workspace': wsName})
        self.__class__.wsName = wsName
        return wsName

    def getImpl(self):
        return self.__class__.serviceImpl

    def getContext(self):
        return self.__class__.ctx

    def getTempGenbank(self):
        tmp_dir = self.__class__.cfg['scratch']
        file_name = "GCF_000005845.2_ASM584v2_genomic.gbff.gz"
        gbk_path = os.path.join(tmp_dir, file_name)
        if not os.path.exists(gbk_path):
            ftp_url = 'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Escherichia_coli/reference/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.gbff.gz'
            with closing(urllib2.urlopen(ftp_url)) as r:
                with open(gbk_path, 'wb') as f:
                    shutil.copyfileobj(r, f)
        return gbk_path

    def test_simple_upload(self):
        genomeFileUtil = self.getImpl()

        ### Test for a Local Function Call - file needs to be just on disk
        tmp_dir = self.__class__.cfg['scratch']
        #file_name = "GCF_000005845.2_ASM584v2_genomic.gbff.gz"
        #shutil.copy(os.path.join("data", file_name), tmp_dir)
        gbk_path = self.getTempGenbank()  # os.path.join(tmp_dir, file_name)
        print('attempting upload via local function directly')
        ws_obj_name = 'MyGenome'
        result = genomeFileUtil.genbank_to_genome_annotation(self.getContext(), 
            {
                'file_path':gbk_path,
                'workspace_name':self.getWsName(),
                'genome_name':ws_obj_name
            });
        pprint(result)
        # todo: add test that result is correct

        ### Test for upload from SHOCK - upload the file to shock first
        print('attempting upload through shock')
        data_file_cli = DataFileUtil(os.environ['SDK_CALLBACK_URL'], 
                                token=self.__class__.ctx['token'],
                                service_ver='dev')
        shock_id = data_file_cli.file_to_shock({'file_path': gbk_path})['shock_id']
        ws_obj_name2 = 'MyGenome.2'
        result2 = genomeFileUtil.genbank_to_genome_annotation(self.getContext(), 
            {
                'shock_id':shock_id,
                'workspace_name':self.getWsName(),
                'genome_name':ws_obj_name2,
                'convert_to_legacy':1
            });
        pprint(result2)
        # todo: add test that result is correct

        ### Test for upload via FTP- use something from genbank
        print('attempting upload through ftp url')
        ws_obj_name3 = 'MyGenome.3'
        result2 = genomeFileUtil.genbank_to_genome_annotation(self.getContext(), 
            {
                'ftp_url':'ftp://ftp.ncbi.nlm.nih.gov/genomes/refseq/bacteria/Escherichia_coli/reference/GCF_000005845.2_ASM584v2/GCF_000005845.2_ASM584v2_genomic.gbff.gz',
                'workspace_name':self.getWsName(),
                'genome_name':ws_obj_name3,
                'convert_to_legacy':1
            });
        pprint(result2)


    def test_simple_download(self):
        genomeFileUtil = self.getImpl()

        tmp_dir = self.__class__.cfg['scratch']
        #file_name = "GCF_000005845.2_ASM584v2_genomic.gbff.gz"
        #shutil.copy(os.path.join("data", file_name), tmp_dir)
        gbk_path = self.getTempGenbank()  # os.path.join(tmp_dir, file_name)
        print('attempting upload via local function directly to test download')
        ws_obj_name = 'g.download_test'
        result = genomeFileUtil.genbank_to_genome_annotation(self.getContext(), 
            {
                'file_path':gbk_path,
                'workspace_name':self.getWsName(),
                'genome_name':ws_obj_name,
                'convert_to_legacy':1
            })[0];
        pprint(result)

        # download from the new type
        print('Download and save as local file')
        downloadResult = genomeFileUtil.genome_annotation_to_genbank(self.getContext(), 
            {
                'genome_ref':result['genome_annotation_ref']
            });
        pprint(downloadResult)

        # download and save to shock, test using the genome_name and workspace_name
        print('Download and save single file to shock')
        downloadResult = genomeFileUtil.genome_annotation_to_genbank(self.getContext(), 
            {
                'genome_name':ws_obj_name,
                'workspace_name':self.getWsName(),
                'save_to_shock':1
            });
        pprint(downloadResult)

        print('Download and package as zip archive')
        exportResult = genomeFileUtil.export_genome_annotation_as_genbank(self.getContext(), 
            {
                'input_ref':self.getWsName()+'/'+ws_obj_name
            });
        pprint(exportResult)

        # download from the old type -- seems like this should work, but fails with error:
        # Traceback (most recent call last):
        #   File "GenomeAnnotationFileUtil_server_test.py", line 158, in test_simple_download
        #     'output_name':'legacy_genome_genbank.gbk'
        #   File "/kb/module/lib/GenomeAnnotationFileUtil/GenomeAnnotationFileUtilImpl.py", line 249, in genome_annotation_to_genbank
        #     working_directory)
        #   File "/kb/module/lib/doekbase/data_api/downloaders/GenomeAnnotation.py", line 75, in downloadAsGBK
        #     writeFeaturesOrdered(ga_api, regions, out_file)
        #   File "/kb/module/lib/doekbase/data_api/downloaders/GenomeAnnotation.py", line 132, in writeFeaturesOrdered
        #     cds_by_gene = ga_api.get_cds_by_gene(feature_ids['by_type']['gene'])
        #   File "/kb/module/lib/doekbase/data_api/annotation/genome_annotation/api.py", line 600, in get_cds_by_gene
        #     return self.proxy.get_cds_by_gene(gene_feature_id_list)
        #   File "/kb/module/lib/doekbase/data_api/annotation/genome_annotation/api.py", line 1125, in get_cds_by_gene
        #     "  This method cannot return valid results for this data type.")
        # TypeError: The Genome type does not contain relationships between features.  This method cannot return valid results for this data type.

        #downloadResult = genomeFileUtil.genome_annotation_to_genbank(self.getContext(), 
        #    {
        #        'genome_name':ws_obj_name + '_genome_legacy',
        #        'workspace_name':self.getWsName(),
        #        'output_name':'legacy_genome_genbank.gbk'
        #    });
        #pprint(downloadResult)

        # download from the old type, test putting the result in shock
        #downloadResult = genomeFileUtil.genome_annotation_to_genbank(self.getContext(), 
        #    {
        #        'genome_name':ws_obj_name + '_genome_legacy',
        #        'workspace_name':self.getWsName(),
        #        'output_name':'legacy_genome_genbank.gbk',
        #        'save_to_shock':1
        #    });
        #pprint(downloadResult)
