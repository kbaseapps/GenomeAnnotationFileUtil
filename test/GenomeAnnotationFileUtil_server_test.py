import unittest
import os
import json
import time
import shutil

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

    def test_one_simple_upload(self):
        genomeFileUtil = self.getImpl()

        tmp_dir = self.__class__.cfg['scratch']
        file_name = "GCF_000005845.2_ASM584v2_genomic.gbff.gz"
        shutil.copy(os.path.join("data", file_name), tmp_dir)
        gbk_path = os.path.join(tmp_dir, file_name)
        print('attempting upload')
        ws_obj_name = 'MyGenome'
        result = genomeFileUtil.genbank_to_genome_annotation(self.getContext(), 
            {
                'file_path':gbk_path,
                'workspace_name':self.getWsName(),
                'genome_name':ws_obj_name
            });
        pprint(result)
        # todo: add test that result is correct


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


        
