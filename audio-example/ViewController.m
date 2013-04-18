//
//  ViewController.m
//  audio-example
//
//  Created by Jaco on 4/18/13.
//  Copyright (c) 2013 Jaco. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIButton *recordButton;
@property BOOL isRecording;
@property (strong, nonatomic) AVAudioRecorder *recorder;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.isRecording = NO;
}

- (IBAction)toggleRecord
{
    if (!self.isRecording)
        [self startRecording];
    else
        [self stopRecording];
}

- (IBAction)playRecording
{
}

- (void)startRecording
{
    if (![self startAudioSession])
        return;
    
    NSError *err = nil;
    self.recorder = [[ AVAudioRecorder alloc] initWithURL:self.createDatedRecordingFile settings:self.recordSettings error:&err];
    if(!self.recorder){
        NSLog(@"Could not create recorder: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return;
    }
    
    [self.recorder prepareToRecord];
    [self.recorder record];
    self.isRecording = YES;
    [self.recordButton setTitle:@"Stop Recording" forState:UIControlStateNormal];
}

- (void)stopRecording
{
    [self.recorder stop];
    self.isRecording = NO;
    [self.recordButton setTitle:@"Record" forState:UIControlStateNormal];
}

- (BOOL)startAudioSession
{
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *err = nil;
    [audioSession setCategory :AVAudioSessionCategoryPlayAndRecord error:&err];
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
    
    [audioSession setActive:YES error:&err];
    err = nil;
    if(err){
        NSLog(@"audioSession: %@ %d %@", [err domain], [err code], [[err userInfo] description]);
        return NO;
    }
    
    BOOL audioHWAvailable = audioSession.inputAvailable;
    if (! audioHWAvailable) {
        NSLog(@"Audio input hardware not available");
        return NO;
    }
    
    return YES;
}

- (NSDictionary *)recordSettings
{
    NSMutableDictionary *recordSettings = [[NSMutableDictionary alloc] init];
    
    [recordSettings setValue :[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSettings setValue:[NSNumber numberWithFloat:24000.0] forKey:AVSampleRateKey];
    [recordSettings setValue:[NSNumber numberWithInt: 1] forKey:AVNumberOfChannelsKey];
    
    return recordSettings;
}

- (NSURL *)createDatedRecordingFile
{
    NSDate *now = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString *caldate = [now description];
    NSString *recorderFilePath = [NSString stringWithFormat:@"%@/%@.m4a", [NSHomeDirectory() stringByAppendingPathComponent:@"tmp"], caldate];
    return [NSURL fileURLWithPath:recorderFilePath];
}

@end
