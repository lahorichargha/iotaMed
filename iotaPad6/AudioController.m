//
//  AudioController.m
//  iotaPad6
//
//  Created by Shiva on 10/12/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "AudioController.h"
#import <AVFoundation/AVAudioSession.h>

@implementation AudioController

@synthesize myVUmeter=_myVUmeter;
@synthesize uuids = _uuids;
@synthesize avPlayer = _avPlayer;
@synthesize avRecorder = _avRecorder;
@synthesize timer = _timer;
@synthesize itemString=_itemString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

-(void)dealloc{
    self.myVUmeter=nil;
    self.uuids=nil;
    self.avPlayer=nil;
    self.avRecorder=nil;
    self.timer=nil;
    self.itemString=nil;
    [super dealloc];
}

// -----------------------------------------------------------
#pragma - recorder delegate
//------------------------------------------------------------------

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"did finish recording!");
    [self.timer invalidate];
    [self.itemString.vvbar.customView setHidden:YES];
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
    [self.timer invalidate];
    [self.itemString.sliderbarbutton.customView setHidden:YES];
    [self.itemString.labelBarC.customView setHidden:YES];
    [self.itemString.labelBarD.customView setHidden:YES];
    [self setSymbolnamed:nil];
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
}

-(NSURL*) getURLToSend{
    
    NSString *docDir=[self uniquePathDirctory];
    NSURL *url;
    url=[NSURL fileURLWithPath:docDir];
    return url;    
}

//---------------------------------------------------------
#pragma mark -
#pragma mark Soundrecording stuff
//---------------------------------------------------------

static const CGFloat dbRange = 120.0;



-(void) updateUVMeter{
    [self.avRecorder updateMeters];
    CGFloat db = [self.avRecorder averagePowerForChannel:0];
    CGFloat peakDb = [self.avRecorder peakPowerForChannel:0];
    // db goes from -160.0 to 0.0, but iOS only goes from -120 to 0
    
    NSLog(@"db, peakDb: %f %f", db, peakDb);
    
    // with this conversion, the volume values should become 0.0 - 1.0
    CGFloat myIdeaOfVolume = (db + dbRange) / dbRange;
    CGFloat myIdeaOfPeakVolume = (peakDb + dbRange) / dbRange;
    
    self.myVUmeter.volume = myIdeaOfVolume;
    self.myVUmeter.peakVolume = myIdeaOfPeakVolume;
    [self.myVUmeter setNeedsDisplay];
    
}

- (void)timerFired:(NSTimer *)timer {
    [self updateUVMeter];
}

- (void)doRecord:(id)sender {
    
    NSLog(@"start to record.");
    [self setSymbolnamed:@"record_image@2x"];
    self.itemString.play.enabled=NO;
    self.itemString.pauseBar.enabled=NO;
    [self.itemString.vvbar.customView setHidden:NO];
    
    NSTimeInterval ti=1.0/30.0;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
    
    AVAudioSession *audioSession=[AVAudioSession sharedInstance];
    
    //sharedInstance Returns the singleton audio session.
    
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    [audioSession setActive:YES error:nil];
    
    //    NSURL *url=[self getFileURL];
    //    NSLog(@"record url%@",url);
    
    NSURL *urluuid=[self getURLToSend];
    NSLog(@"record UUIDAdress %@",urluuid);
    
    if (!self.uuids) {
        self.uuids = [[[NSMutableArray alloc] initWithCapacity:5]autorelease];
    }
    [self.uuids addObject:urluuid];
    
    NSMutableDictionary *recordSetting=[[[NSMutableDictionary alloc]init]autorelease]; 
    
    //    [recordSetting setValue :[NSNumber numberWithInt:kAudioFormatLinearPCM] forKey:AVFormatIDKey];
    //    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey]; 
    //    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    //    [recordSetting setValue :[NSNumber numberWithInt:8] forKey:AVLinearPCMBitDepthKey];
    //    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsBigEndianKey];
    //    [recordSetting setValue :[NSNumber numberWithBool:NO] forKey:AVLinearPCMIsFloatKey];
    
    self.avRecorder=[[[AVAudioRecorder alloc]initWithURL:urluuid settings:recordSetting error:nil]autorelease];
    self.avRecorder.delegate=self; 
    [self.avRecorder prepareToRecord];
    self.avRecorder.meteringEnabled=YES;
        
    BOOL didStartRecord=[self.avRecorder record];
    if (!didStartRecord) 
        NSLog(@"faile to record");
    else 
        NSLog(@"Could record");
    
}

- (void)doPlay:(id)sender {
    NSLog(@"start playing");
    [self setSymbolnamed:@"play_image@2x"];
    
    [self.itemString.sliderbarbutton.customView setHidden:NO];
    [self.itemString.labelBarC.customView setHidden:NO];
    [self.itemString.labelBarD.customView setHidden:NO];
    
    //    NSURL *url = [self getFileURL];
    //    NSLog(@"Url to play: %@", url);
    
    NSURL *urlPlay=[self.uuids objectAtIndex:0];
    
    if (!playWasPaused || !self.avPlayer) {
        self.avPlayer=[[[AVAudioPlayer alloc]initWithContentsOfURL:urlPlay error:nil]autorelease];
        self.avPlayer.delegate = self;
    }
    
    [self.avPlayer play];
    [self.itemString currentTimeForPlayer:self.avPlayer];
    
    self.timer=[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:self.avPlayer repeats:YES];
    
    if (playWasPaused) {
        [self.itemString currentTimeForPlayer:self.avPlayer];
        
        [self.avPlayer playAtTime:timePaused];
    }
    
}

- (void)doPause:(id)sender {
    [self.avPlayer pause];
    NSLog(@"paused");
    playWasPaused=YES;
    [self setSymbolnamed:@"pause_image@2x"];
}

- (void)doStop:(id)sender  {
    NSLog(@"Stopped recording");
    
    self.itemString.play.enabled=YES;
    self.itemString.pauseBar.enabled=YES;
    
    [self.avRecorder stop];
    
    self.myVUmeter.volume = 0;
    self.myVUmeter.peakVolume = 0;
    [self.myVUmeter setNeedsDisplay];
    
    [self setSymbolnamed:@"stop_image@2x"];
}


-(void) setSymbolnamed: (NSString *) fileName{
    self.itemString.symbolView.image=[UIImage imageNamed:fileName];
    [self.itemString.symbolView setNeedsDisplay];
}



@end
