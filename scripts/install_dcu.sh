#!/bin/bash

ENV_NAME=openfold_venv
# Grab conda-only packages
PATH=lib/conda/bin:$PATH
conda update -qy conda \
    && conda create --name $ENV_NAME -y python==3.8 \
    && source $CONDA_PREFIX/etc/profile.d/conda.sh \
    && conda activate $ENV_NAME \
    && pip install -r requirements.txt \
    && conda install -qy -c conda-forge \
      openmm=7.5.1 \
      pdbfixer

pip3 install torch -f https://download.pytorch.org/whl/rocm4.2/torch_stable.html
# Comment out if you have these already installed on your system, for example in /usr/bin/
conda install -c bioconda aria2
conda install -y -c bioconda hmmer==3.3.2 hhsuite==3.3.0 kalign2==2.04

pip install nvidia-pyindex
pip install nvidia-dllogger

# Install DeepMind's OpenMM patch
OPENFOLD_DIR=$PWD
pushd $CONDA_PREFIX/envs/$ENV_NAME/lib/python3.7/site-packages/ \
    && patch -p0 < $OPENFOLD_DIR/lib/openmm.patch \
    && popd

# Download folding resources
wget -q -P openfold/resources \
    https://git.scicore.unibas.ch/schwede/openstructure/-/raw/7102c63615b64735c4941278d92b554ec94415f8/modules/mol/alg/src/stereo_chemical_props.txt

# Certain tests need access to this file
mkdir -p tests/test_data/alphafold/common
ln -rs openfold/resources/stereo_chemical_props.txt tests/test_data/alphafold/common

# Download pretrained openfold weights
#scripts/download_alphafold_params.sh openfold/resources

# Decompress test data
gunzip tests/test_data/sample_feats.pickle.gz
