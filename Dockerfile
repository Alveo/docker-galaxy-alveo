# Alveo Galaxy Flavour
#
# Version 0.1

FROM bgruening/galaxy-stable

MAINTAINER Steve Cassidy, steve.cassidy@mq.edu.au

ENV GALAXY_CONFIG_BRAND=Alveo \
    GALAXY_CONFIG_ENABLE_BETA_TOOL_COMMAND_ISOLATION=True \
    GALAXY_CONFIG_CONDA_AUTO_INSTALL=True \
    GALAXY_CONFIG_CONDA_AUTO_INIT=True

# ADD ./tool_conf.xml /export/galaxy-central/config/tool_conf.xml
ADD welcome.html /export/welcome.html
ADD alveo-logo.png /export/alveo-logo.png

RUN add-tool-shed --url 'https://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed'

RUN install-repository \
    "--url https://testtoolshed.g2.bx.psu.edu/ -o stevecassidy --name alveoimport --panel-section-name Alveo"


# Adding the tool definitions to the container
#ADD tool_list.yaml $GALAXY_ROOT/tool_list.yaml

# Install required tools
#RUN install-tools $GALAXY_ROOT/tool_list.yaml
