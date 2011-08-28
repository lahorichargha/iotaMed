//
//  AudioViewController.m
//  Audio
//
//  Created by Shiva on 7/25/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AudioViewController.h"
#import <AVFoundation/AVAudioSession.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "MyVUMeter.h"
#import "ItemCellDelegate.h"
#import "ItemCellDelegate.h"

//#define kRECORDBUTTON2_TAG  1001
//#define kSTOP_TAG 1002


@implementation AudioViewController


@synthesize playButton;
@synthesize pauseButton;
@synthesize currentTime;
@synthesize duration;
@synthesize progressSlider;
@synthesize stopButton;
@synthesize recordButton;
@synthesize avPlayer;
@synthesize avRecorder;
@synthesize timer;
@synthesize myVuMeter = _myVuMeter;
@synthesize uuids = _uuids;
@synthesize ItemCellDelegate=_ItemCellDelegate;

//------------------------------------------------------------------

#pragma - recorder delegate
//------------------------------------------------------------------

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"did finish recording!");
    [self.timer invalidate];
}


-(void) audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder error:(NSError *)error{
    NSLog(@"an error accured");
}

//Martin had two more delegate here! Check Later.


//------------------------------------------------------------------

#pragma - player delegate
//------------------------------------------------------------------


-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    NSLog(@"did finish playing!");
//    self.pauseButton.hidden = YES;
//    self.playButton.hidden = NO;
}


-(void) audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error{
    NSLog(@"An error accured!");
}




//------------------------------------------------------------------

#pragma - get directory
//------------------------------------------------------------------

-(NSString*) getDocumentDirectory{
    NSString *path=[NSTemporaryDirectory() stringByAppendingPathComponent: @"recordedFile.caf"];  
    return path;
    
    NSLog(@"path%@",path);
}

-(NSURL*) getFileURL{
    NSString *docDir=[self getDocumentDirectory];
    //NSString *filePath=[NSString stringWithFormat:@"%@/testfile.caf", docDir];
    NSURL *url=[NSURL fileURLWithPath:docDir];
    return url;
}



-(NSString*) uniquePathDirctory{
    CFUUIDRef uuid = CFUUIDCreate(NULL);
    CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    NSString *newPath = [NSString stringWithFormat:@"%@/%@.caf", NSTemporaryDirectory(), uuidString];
    CFRelease(uuidString);
    return newPath;
    
    
//    NSString *pathDic=[NSTemporaryDirectory() stringByAppendingPathComponent:(__bridge NSString*)uuidString];
//    CFRelease(uuidString);
//    NSError *error = nil;
//    [[NSFileManager defaultManager] createDirectoryAtPath:pathDic withIntermediateDirectories:YES attributes:nil error:&error];
//    if (error) {
//        NSLog(@"error: %@", error);
//    }
//    NSString *result=[NSString stringWithFormat:@"%@/testfile.caf", pathDic];
//    return result;
}

-(NSURL*) getURLToSend{
    
    NSString *docDir=[self uniquePathDirctory];
    //NSString *filePath=[NSString stringWithFormat:@"%@/testfile.caf", docDir];
    NSURL *url;
    url=[NSURL fileURLWithPath:docDir];
        return url;    
}

//---------------------------------------------------------
#pragma - buttonsAction
//---------------------------------------------------------


-(void) currentTimeForPlayer: (AVAudioPlayer *) p {
    
   
        self.currentTime.text=[NSString stringWithFormat:@"%d:%02d", (int) p.currentTime/60, (int) p.currentTime % 60, nil];
        progressSlider.value=p.currentTime;
    timePaused=p.currentTime;
       
}

-(void) durationTimeForPlayer:  (AVAudioPlayer *) p{
    self.duration.text=[NSString stringWithFormat:@"%d:%02d", (int) p.duration/60, (int) p.duration % 60, nil];
    progressSlider.maximumValue=p.duration;
        
}

-(void) updateCurrentTime{
    [self currentTimeForPlayer:avPlayer];
    [self durationTimeForPlayer:avPlayer];
    
}


static const CGFloat dbRange = 120.0;

-(void) updateUVMeter{
    [self.avRecorder updateMeters];
    CGFloat db = [self.avRecorder averagePowerForChannel:0];
    CGFloat peakDb = [self.avRecorder peakPowerForChannel:0];
    // db goes from -160.0 to 0.0
    
    CGFloat myIdeaOfVolume = (db + dbRange) / dbRange;
    CGFloat myIdeaOfPeakVolume = (peakDb + dbRange) / dbRange;
    
    self.myVuMeter.volume = myIdeaOfVolume;
    self.myVuMeter.peakVolume = myIdeaOfPeakVolume;
    [self.myVuMeter setNeedsDisplay];
    
        
    //not complete
}


- (IBAction)recordButton:(id)sender {
    
    NSLog(@"start to record.");
    NSTimeInterval ti=1.0/30.0;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(updateUVMeter) userInfo:nil repeats:YES];
    
   
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    
     //sharedInstance Returns the singleton audio session.
   
    
    
   [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession setActive:YES error:nil];
    
    NSURL *url=[self getFileURL];
    
    
    if (!self.uuids) {
        self.uuids = [[NSMutableArray alloc] initWithCapacity:5];
    }
    [self.uuids addObject:url];
    
    NSLog(@"record url%@",url);
    
    NSURL *urluuid=[self getURLToSend];
    NSLog(@"record UUIDAdress %@",urluuid);
    

    
    NSMutableDictionary *recordSetting=[[NSMutableDictionary alloc]init]; 
    
//    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
//	[recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
//	[recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
//	
//	[recordSetting setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
//	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
//	[recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
	

    
    

    
        recordButton.enabled=YES;
//    [self.recordButton setHidden:YES];
//       [self.stopButton setHidden:NO];
//    
//    [self.currentTime setHidden:YES];
//    [self.duration setHidden:YES];
//        
//    [self.progressSlider setHidden:YES];
    
        self.avRecorder=[[AVAudioRecorder alloc]initWithURL:url settings:recordSetting error:nil];
        self.avRecorder.delegate=self; 
        [self.avRecorder prepareToRecord];
        self.avRecorder.meteringEnabled=YES;
    
    BOOL didStartRecord=[self.avRecorder record];
    if (!didStartRecord) 
        NSLog(@"faile to record");
    else 
        NSLog(@"Could record");

    
    //not complete
    
}
    
    
     //For recording and playback of audio—simultaneous or not—such as for a VOIP (voice over IP) application.
     // This category silences audio from other applications,


- (IBAction)stopButton:(id)sender {
    
       NSLog(@"Stoped to record");
    stopButton.enabled=YES;
    [self.avRecorder stop];
    
//    [self.stopButton setHidden:YES];
//    [self.recordButton setHidden:NO];
    
    self.myVuMeter.volume=0;
    self.myVuMeter.peakVolume = 0;
    [self.myVuMeter setNeedsDisplay];
       
}

- (IBAction)pauseButton:(id)sender {
    NSLog(@"paused");
    pauseButton.enabled=YES;
    
    [self.avPlayer pause];
    
//    [self.pauseButton setHidden:YES];
//    [self.playButton setHidden:NO];
    
    playWasPaused=YES;
    
    
}


    


- (IBAction)playButton:(id)sender {
    NSLog(@"start Playing!");
    
    
    playButton.enabled=YES;
    
    NSURL *url=[self getFileURL];
    NSLog(@"Second for spela%@",url);
    
    if (!playWasPaused || !self.avPlayer) {
        self.avPlayer=[[AVAudioPlayer alloc]initWithContentsOfURL:url error:nil];
        self.avPlayer.delegate = self;
    }

//    [self.currentTime setHidden:NO];
//    [self.duration setHidden:NO];
//    [self.progressSlider setHidden:NO];
    
    [self.avPlayer play];
    
    [self currentTimeForPlayer:avPlayer];
    
    
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:avPlayer repeats:YES];
    
    
    
//    [self.playButton setHidden:YES];
//    [self.pauseButton setHidden:NO];
    
    
        if (playWasPaused) {
            [self currentTimeForPlayer:avPlayer];
            
            [self.avPlayer playAtTime:timePaused];
        }
//        else{
//            [self.avPlayer stop];
//            
//            [self.pauseButton setHidden:YES];
//            [self.playButton setHidden:NO];
//
//        }
    
    
       
          
    //not complete    
}






//--------------------------------------------

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [self.stopButton setHidden:YES];
    [self.pauseButton setHidden:YES];
    [self.currentTime setHidden:YES];
    [self.duration setHidden:YES];
    [self.progressSlider setHidden:YES];
    self.uuids = [[NSMutableArray alloc] initWithCapacity:5];
    
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self stopButton:nil];
    [self pauseButton:nil];
    [self playButton:nil];
    [self recordButton:nil];
   
   
    [self setCurrentTime:nil];
    [self setDuration:nil];
    [self setProgressSlider:nil];
    
    
    [super viewDidUnload];
    // Release any stronged subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}




- (void)dealloc {
	self.avPlayer = nil;
	self.avRecorder = nil;
	self.timer = nil;
	self.myVuMeter = nil;
    self.playButton=nil;
    self.recordButton=nil;
    self.playButton=nil;
    self.stopButton=nil;
    self.currentTime=nil;
    self.duration=nil;
    self.progressSlider=nil;
    self.uuids=nil;
    self.ItemCellDelegate=nil;
    
    [super dealloc];
}


- (IBAction)sliderValue:(UISlider*)sender {
    
    avPlayer.currentTime=sender.value;
    [self durationTimeForPlayer:avPlayer];
    
   
}


//----------------------------------------------------------------

///for second record button.

//----------------------------------------------------------------

@end
