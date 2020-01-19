#
# TinyMediaManager Dockerfile
#
FROM romancin/tinymediamanager

# Install Chinese Fonts
RUN cd /tmp 
RUN wget https://soft.itbulu.com/fonts/simsun.zip
RUN unzip simsun.zip
RUN cp simsun/* /usr/share/fonts
RUN rm -rf simsun
RUN fc-cache
