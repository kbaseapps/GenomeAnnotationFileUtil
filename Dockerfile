FROM kbase/kbase:sdkbase.latest
MAINTAINER KBase Developer
# -----------------------------------------

# Make sure SSL certs are properly installed
RUN apt-get install python-dev libffi-dev libssl-dev \
    && pip install pyopenssl ndg-httpsclient pyasn1 \
    && pip install requests --upgrade \
    && pip install 'requests[security]' --upgrade

# Install KBase Data API Library + dependencies
RUN mkdir -p /kb/module && cd /kb/module && git clone https://github.com/jkbaumohl/data_api && \
    cd data_api && git checkout 598035d && cd /kb/module && \
    mkdir -p lib/ && cp -a data_api/lib/doekbase lib/ && \
    pip install -r /kb/module/data_api/requirements.txt

# Install KBase Transform Scripts + dependencies
# Note: may not always be safe to copy things to /kb/deployment/lib

# to make things easy, we copy the specific scripts we need to the lib directory

RUN mkdir -p /kb/module && cd /kb/module && git clone https://github.com/jkbaumohl/transform && \
    cd transform && git checkout 3bb0eb5 && cd /kb/module && \
    mkdir -p lib/ && cp -a transform/lib/biokbase /kb/deployment/lib/ && \
    cp transform/plugins/scripts/upload/trns_transform_FASTA_DNA_Assembly_to_KBaseGenomeAnnotations_Assembly.py lib/. && \
    cp transform/plugins/scripts/upload/trns_transform_Genbank_Genome_to_KBaseGenomeAnnotations_GenomeAnnotation.py lib/. && \
    pip install -r /kb/module/data_api/requirements.txt


COPY ./ /kb/module
RUN mkdir -p /kb/module/work
RUN chmod 777 /kb/module

WORKDIR /kb/module

RUN make all

ENTRYPOINT [ "./scripts/entrypoint.sh" ]

CMD [ ]
