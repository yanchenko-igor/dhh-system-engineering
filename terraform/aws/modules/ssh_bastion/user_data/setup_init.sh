#!/bin/bash -xe
######################################################################
echo "#### Running setup_init.sh"
######################################################################
echo "#### Setting up repos and software"
apt-get update
apt-get install --force-yes -y python-pip python-setuptools awscli
pip install --upgrade pip
wget -N https://s3.amazonaws.com/cloudformation-examples/aws-cfn-bootstrap-latest.tar.gz
easy_install aws-cfn-bootstrap-latest.tar.gz
######################################################################
echo "#### AWS user-data execution complete"
