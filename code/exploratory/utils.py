import datetime
import numpy as np
from scipy.io.wavfile import read
import spikeextractors as se

def get_SAP_wav_datetime(SAP_wav, year):
    '''Takes path and returns datetime object of wav filename
    Example filename: 'Or179_44238.36510326_2_11_10_8_30.wav'
    '''
    
    # Remove any c://user//etc stuff
    SAP_wav = SAP_wav.split('/')[-1]
    SAP_wav = SAP_wav.split('\\')[-1]
    
    # Split up wave file
    ID, time, ext = SAP_wav.split('.')
    
    # Split up time segment
    _,M,D,h,m,s=time.split('_')
    
    return datetime.datetime(year, int(M), int(D), int(h), int(m), int(s))
    
def get_recording_datetime(recording_dir):
    '''Takes path and returns datetime object of recording dir
    example recoridng dir: 2021-02-11_07-00-18_OR179_3_136_U223_morning
    '''
    recording_dir = recording_dir.split('/')[-1]
    recording_dir = recording_dir.split('\\')[-1]
    # Split up dir name
    dir_splits = recording_dir.split('_')
    date, time = dir_splits[0], dir_splits[1]
    
    ## This file does not have the year, which is really inconsiderate. I am
    # manually adding the current year to each file for parsimony, but this is not
    # good programming.
    return datetime.datetime(
        *[int(spl) for spl in date.split('-')], #date
        *[int(spl) for spl in time.split('-')] # time
    )
    

def get_trange(rec_dir, wav_file, duration=10, offset=datetime.timedelta(minutes=5, seconds=44)):
    ''' Gets a particular datetime range from the recording
    Parameters
    ----------
    start: datetime
        When the recording started
    target: datetime
        When you want to sample from
    
    Returns
    -------
    output: list
        trange for spikeinterface in seconds
    '''
    # Get datetime for recording
    rec=get_recording_datetime(rec_dir)
    
    # Get datetime for SAP wav file
    sap=get_SAP_wav_datetime(wav_file, rec.year)
    
    # Get difference in time and convert to seconds
    
    timedelta = sap-rec
    s = timedelta.seconds + offset.seconds
    return [s-duration/2, s+duration/2]


def get_wav_recording(wav_path):
    '''Am I lazy or am I genius? 
    This returns a spikeinterface object representing the wav file
    Which allows you to plot it and such with great ease
    
    Parameters
    ----------
    wav_path: str
        Path to .wav file
    
    Returns
    -------
    wav_recording: se.NumpyRecordingExtractor
        Recording object of sound. Happy plotting!
    '''
    # Put into numpy array
    fs, wav_data = read(wav_path)
    
    # Put into NumpyRecordingExtractor
    # Stack it to trick numpy into accepting it; like stereo sound. We
    # will only use the first channel.
    wav_recording = se.NumpyRecordingExtractor(np.vstack([wav_data,wav_data]), fs)
    
    return wav_recording

