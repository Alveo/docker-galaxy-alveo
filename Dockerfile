# Alveo Galaxy Flavour
#
# Version 0.1

FROM bgruening/galaxy-stable:16.07

MAINTAINER Steve Cassidy, steve.cassidy@mq.edu.au

ENV GALAXY_CONFIG_BRAND=Alveo \
    GALAXY_CONFIG_CONDA_AUTO_INSTALL=True \
    GALAXY_CONFIG_CONDA_AUTO_INIT=True\
    GALAXY_CONFIG_ENABLE_BETA_TOOL_COMMAND_ISOLATION=True

# fix up conda install
RUN rm -R /tool_deps/_conda && \
    wget https://repo.continuum.io/miniconda/Miniconda3-4.0.5-Linux-x86_64.sh && \
    bash Miniconda3-4.0.5-Linux-x86_64.sh -b -p $GALAXY_CONDA_PREFIX && \
    rm Miniconda3-4.0.5-Linux-x86_64.sh && \
    $GALAXY_CONDA_PREFIX/bin/conda install -y conda==3.19.3

ADD ./tool_conf.xml /galaxy-central/config/tool_conf.xml
ADD welcome.html /etc/galaxy/web/welcome.html
ADD alveo-logo-alpha.png /galaxy-central/static/alveo-logo-alpha.png

RUN add-tool-shed --url 'https://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed'

# add toolshed tools
RUN install-repository \
    "--url https://toolshed.g2.bx.psu.edu/ -o devteam --name correlation --panel-section-name Statistics" \
    "--url https://toolshed.g2.bx.psu.edu/ -o lecorguille --name pca --panel-section-name Statistics" \
    "--url https://toolshed.g2.bx.psu.edu/ -o bgruening --name numeric_clustering --panel-section-name Statistics" \
    "--url https://toolshed.g2.bx.psu.edu/ -o bgruening --name text_processing --panel-section-name TextProcessing" \
    "--url https://toolshed.g2.bx.psu.edu/ -o devteam --name scatterplot --panel-section-name Graphics" \
    "--url https://toolshed.g2.bx.psu.edu/ -o guerler --name charts --panel-section-name Graphics"

# add the Alveo tools
RUN install-repository \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o stevecassidy --name alveoimport --panel-section-name Alveo" \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o stevecassidy --name textgrid --panel-section-name TextGrid" \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o stevecassidy --name vowelplot --panel-section-name Graphics" \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o stevecassidy --name wrassp --panel-section-name Wrassp"

# Adding the tool definitions to the container
#ADD tool_list.yaml $GALAXY_ROOT/tool_list.yaml

# Install required tools
#RUN install-tools $GALAXY_ROOT/tool_list.yaml
