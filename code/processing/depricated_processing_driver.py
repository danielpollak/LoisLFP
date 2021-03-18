# -*- coding: utf-8 -*-
"""
Created on Thu Feb 18 13:29:24 2021

@author: danpo
"""
#%%
# Takes each folder in the data processing folder and makes a folder in the processing folder
# with the same name that generates the sleep csvs and generates exploratory
# ipython notebooks

import os
from shutil import copy

# First, exploratory notebooks
from run_jnb import possible_parameter, run_jnb

#%% Set paths
templates_path = r'../../templates/'
processing_path = r'.'

# Template name
song_explorer_template_name = 'YYYY-MM-DD_hh-mm-ss_subject1_subject2.ipynb'

# Get folders for making notebooks
dir_list = [elem for elem in os.listdir(r'../../data/') 
            if (elem != 'README.md') and (elem != '.ipynb_checkpoints')]

from_path = os.path.join(templates_path, song_explorer_template_name)

#%% Copy files to directories from template to folders
for data_directory in dir_list:

    # Get timestamp for renaming
    separator = "_"
    directory_split = data_directory.split(separator)
    timestamp = separator.join([directory_split[0], directory_split[1]])

    # Make processing code directory
    if not os.path.isdir(os.path.join(processing_path, timestamp)):
        os.mkdir(os.path.join(processing_path, timestamp))
    
    # Notebook to make
    to_path = os.path.join(
        processing_path,
        timestamp,
        data_directory+".ipynb") 
    
    # Copy file (overwrite if necessary)
    from_path = os.path.normpath(from_path)
    to_path = os.path.normpath(to_path)
    
    # Copy file
    if not os.path.isfile(to_path):
        copy(from_path,to_path)
    
    # Get params of each notebook
    params = possible_parameter(to_path)
    print(data_directory)
    
    # Parameterize and run notebook
    run_jnb(to_path, return_mode='parametrised_only', arg='{'+'"data_path":{}'.format(data_directory)+'}')
    #, data_path=data_directory)

