FROM ghcr.io/rgcgithub/regenie/regenie:v3.2.5.2.gz

RUN apt-get update && apt-get install -y python3 python3-pip && \
    pip3 install pyyaml

COPY . /

# set working directory to /
WORKDIR /
