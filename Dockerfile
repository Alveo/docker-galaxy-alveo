# Alveo Galaxy Flavour
#
# Version 0.1

FROM bgruening/galaxy-stable:17.09

MAINTAINER Steve Cassidy, steve.cassidy@mq.edu.au

ENV GALAXY_CONFIG_BRAND=Alveo \
    GALAXY_CONFIG_CONDA_AUTO_INSTALL=True \
    GALAXY_CONFIG_CONDA_AUTO_INIT=True \
    GALAXY_CONFIG_ENABLE_BETA_TOOL_COMMAND_ISOLATION=True\
    GALAXY_DOCKER_ENABLED=True\
    GALAXY_DOCKER_SUDO=False\
    GALAXY_DOCKER_VOLUMES_FROM=''\
    BARE=True

WORKDIR /galaxy-central


# add our own config file
ADD galaxy.ini /etc/galaxy/galaxy.ini
ADD ./tool_conf.xml /galaxy-central/config/tool_conf.xml
ADD welcome.html $GALAXY_CONFIG_DIR/web/welcome.html
ADD alveo-logo-alpha.png $GALAXY_CONFIG_DIR/web/alveo-logo-alpha.png

# patch galaxy to add speech datatypes (speech.py, audio visualisation)
ADD datatypes/speech.py /galaxy-central/lib/galaxy/datatypes/
ADD datatypes/audio /galaxy-central/config/plugins/visualizations/
ADD datatypes/datatypes_conf.xml /galaxy-central/config/
ADD datatypes/audio.mako /galaxy-central/templates/webapps/galaxy/dataset/

RUN add-tool-shed --url 'https://testtoolshed.g2.bx.psu.edu/' --name 'Test Tool Shed'
ADD tool_list.yml $GALAXY_ROOT/alveo_tool_list.yml

# clean up unused conda downloads after installing tools
RUN install-tools $GALAXY_ROOT/alveo_tool_list.yml

#ADD job_conf.xml /galaxy-central/config/job_conf.xml
