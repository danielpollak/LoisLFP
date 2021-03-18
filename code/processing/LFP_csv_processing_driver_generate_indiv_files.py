print('importing packages')
import os

import numpy as np
import pandas as pd

from scipy.signal import periodogram

import tqdm as tqdm

import spikeextractors as se

print('imported')



def write_LFP_csv(data_path, subject, channel_ind, recording, timestamp, replace=False):
    # 
    channel_id = recording.get_channel_ids()[channel_ind]
    # Get sampling rate
    sr = recording.get_sampling_frequency()
    # rounds down
    num_sec = int(recording.get_num_frames() / sr)
    
    # Write path for csv
    write_path = os.path.join("../../data/", data_path, '_'.join([timestamp, str(channel_id), subject])+'.csv')
    # If we aren't replacing and it's already there, return
    if os.path.isfile(write_path) and not replace:
        return
    
    # If it is there and we are replacing it, delete it
    elif os.path.isfile(write_path) and replace:
        os.remove(write_path)
    
    for second in tqdm.tqdm(range(num_sec-1)): # one less than total
        # Get trace
        trace=recording.get_traces(
            channel_ids=[channel_id],
            start_frame=second*sr,
            end_frame=(second+1)*sr
        )
        
        f, Pxx = periodogram(trace, sr)

        # Flatten
        Pxx = Pxx.flatten()

        # Get inds for frequencies we want
        inds = (f > 0) & np.array(f<201)
        
        # Truncate arrays to 1-200 Hz
        f = f[inds]
        Pxx = Pxx[inds]

        # Sacrificing precision for space
        # Pxx = np.log10(Pxx).astype('float16')

        # Cast to smaller data type with range 0-255
        f = f.astype('uint8')
        
        # Add to csv file!
        df = pd.DataFrame(dict(t=second,f=f,logpower=np.log10(Pxx)))
        
        # Only write a head if it's the first second
        if second==0:
            df.to_csv(write_path, mode='w', header=True)
        else:
            df.to_csv(write_path, mode='a', header=False)

channel_inds_to_record = [0,2,4,6,8]
#%% Copy files to directories from template to folders
# Get path to your recording file

# Get folders for making notebooks
dir_list = [elem for elem in os.listdir(r'../../data/') 
            if (elem != 'README.md') and (elem != '.ipynb_checkpoints')]

# For each folder in ../../data/,
for data_directory in dir_list:
    
    # Read paths in LFP_location.txt files
    print(os.path.join(r'../../data/', data_directory, 'LFP_location.txt'))
    with open(os.path.normpath(os.path.join(r'../../data/', data_directory, 'LFP_location.txt'))) as f:    
        OE_data_path = f.read()
    
    
    # Whole recording from the hard drive
    if 'Or179' in data_directory and 'Or177' in data_directory:
        nchan=40
    elif 'Or179' in data_directory and 'Or177' not in data_directory:
        nchan=24
    else:
        raise Exception(f'Or177 cannot be the only subject in the directory ({data_directory})')
    
    print('reading bin file')
    recording = se.BinDatRecordingExtractor(OE_data_path,30000,nchan, dtype='int16')
    print('read bin')
    
    recordings, subjects = [], []

    # Add relevant something
    if 'OR179' in data_directory or 'Or179' in data_directory or 'or179' in data_directory:
        # First bird
        if nchan==24:
            Or179_recording = se.SubRecordingExtractor(
                recording,channel_ids=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13,14,15,16]
            )
        elif nchan==40:
            Or179_recording = se.SubRecordingExtractor(
                recording,channel_ids=[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10,11,12,13,14,15, 32]
            )
        else:
            raise Exception("unexpected channel count")
            
        recordings.append(Or179_recording)
        subjects.append('Or179')

    if 'OR177' in data_directory or 'Or177' in data_directory or 'or177' in data_directory:
        # Second bird
        Or177_recording = se.SubRecordingExtractor(
            recording,
            channel_ids=[16, 17,18,19,20,21,22,23,24,25,26,27,28,29,30,31, 33]
        )
        recordings.append(Or177_recording)
        subjects.append('Or177')
    
    # Write CSVs for a recording
    for subject, recording in zip(subjects, recordings):
        for channel_ind in channel_inds_to_record:
        
            # Get timestamp of the target directory for naming the CSV
            separator = "_"
            directory_split = data_directory.split(separator)
            timestamp = separator.join([directory_split[0], directory_split[1]])
            
            print(data_directory, timestamp, channel_ind)
            
            # Write our csv file
            write_LFP_csv(data_directory, subject, channel_ind, recording, timestamp)