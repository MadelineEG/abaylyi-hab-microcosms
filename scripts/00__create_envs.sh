#!/bin/bash

# prep for conda
module load miniforge3
source "$(conda info --base)/etc/profile.d/conda.sh" 

# main pipeline env
conda env create --file de-env.yml

# env to handle salmon incompatibilites
conda env create --file salmon-env.yml
