
def write_LFP_csv(LFP_location_txt, subject, channel_ind, recording, timestamp):
    sr = recording.get_sampling_frequency()
    num_sec = int(recording.get_num_frames() / sr) # rounds down

    for second in tqdm.tqdm(range(num_sec-1)): # one less than total

        trace=recording.get_traces(channel_ids=recording.get_channel_ids()[channel_ind],start_frame=second*sr, end_frame=(second+1)*sr)
        f, Pxx = periodogram(trace, sr)

        # Flatten
        Pxx = Pxx.flatten()

        # Get inds
        inds = (f > 0) & np.array(f<201)

        # Truncate arrays to 1-150 Hz
        f = f[inds]
        Pxx = Pxx[inds]

        # Sacrificing precision for space
        # Pxx = np.log10(Pxx).astype('float16')

        # Cast to smaller data type
        f = f.astype('uint8')

        # Add to csv file!
        df = pd.DataFrame(dict(t=second,f=f,logpower=np.log10(Pxx)))
        
        df.to_csv(
            data_path = os.path.join(
                data_path,
                '_'.join(timestamp, channel, subject)+'.csv'
            ),
            mode='a',
            header=second==0 # only if it's the first second
        )
