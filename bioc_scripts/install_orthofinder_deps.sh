#!/bin/bash
set -e

# 'debconf: unable to initialize frontend: Dialog'
export DEBIAN_FRONTEND=noninteractive
# Update apt-get
apt-get update
################ MCScanX install ########################
cd /opt
git clone https://github.com/wyp1125/MCScanX.git && \
	cd MCScanX && \
	make
################ Fastree install ########################
cd /opt && \
	mv /tmp/FastTree /usr/local/bin/ && \
	chmod a+x /usr/local/bin/FastTree

################ FastME install ##########################
cd /opt
git clone https://gite.lirmm.fr/atgc/FastME.git && \
	cd FastME && \
	./configure && \
	make && \
	make install

################# DIAMOND install ########################
cd /opt
git clone https://github.com/bbuchfink/diamond.git && \
  cd diamond && \
  mkdir build && \
  cd build && \
  cmake .. && \
  make && \
  make install

########################### orthoFinder install #############################
cd /opt
curl -L -O https://github.com/davidemms/OrthoFinder/releases/latest/download/OrthoFinder.tar.gz && \
tar -xzf OrthoFinder.tar.gz && \
ln -s /opt/OrthoFinder/orthofinder /usr/local/bin/ && \
ln -s /opt/OrthoFinder/config.json /usr/local/bin/ && \
rm -r /opt/OrthoFinder/bin && \
rm /opt/OrthoFinder.tar.gz
