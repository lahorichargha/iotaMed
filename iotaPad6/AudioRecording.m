//
//  AudioRecording.m
//  iotaPad6
//
//  Created by Shiva on 10/18/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import "AudioRecording.h"
#import "ItemSelectViewController.h"

@implementation AudioRecording


@synthesize btnRec=_btnRec;
@synthesize btnPlay=_btnPlay;
@synthesize avRecorder=_avRecorder;
@synthesize avPlayer=_avPlayer;
@synthesize uuids=_uuids;
@synthesize timer=_timer;
@synthesize VUmeter=_VUmeter;
@synthesize slider = _slider;
@synthesize labelCellCurrent = _labelCellCurrent;
@synthesize labelCellDuration = _labelCellDuration;
@synthesize playing;
@synthesize playWasPaused;
@synthesize recording;
@synthesize stopBool;
@synthesize myIdeaOfVolume;
@synthesize myIdeaOfPeakVolume;
@synthesize didFinishPlay;

- (void)dealloc {
    [self.btnRec release];
    [self.btnPlay release];
    self.avRecorder=nil;
    self.avPlayer=nil;
    self.uuids=nil;
    self.timer=nil;
    self.VUmeter=nil;
    self.slider=nil;
    self.labelCellCurrent=nil;
    self.labelCellDuration=nil;
  
    [super dealloc];
}


// -----------------------------------------------------------
#pragma - recorder delegate
//------------------------------------------------------------------

-(void) audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder successfully:(BOOL)flag{
    NSLog(@"did finish recording!");
    [self.timer invalidate];
    [self.btnRec setTitle:@"Record" forState:UIControlStateNormal];
    self.btnRec.enabled=YES;
    
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
    [self.btnPlay setTitle:@"Play" forState:UIControlStateNormal];
    self.btnPlay.enabled=YES;
    playing=NO;
    playWasPaused=NO;
    didFinishPlay=YES;
    // [self setSymbolnamed:nil];
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

-(void) currentTimeForPlayer: (AVAudioPlayer *) p {
    self.labelCellCurrent.text=[NSString stringWithFormat:@"%d:%02d", (int) p.currentTime/60, (int) p.currentTime % 60, nil];
    self.slider.value=p.currentTime;
    timePaused=p.currentTime;
    
}

-(void) durationTimeForPlayer:  (AVAudioPlayer *) p{
    self.labelCellDuration.text=[NSString stringWithFormat:@"%d:%02d", (int) p.duration/60, (int) p.duration % 60, nil];
    self.slider.maximumValue=p.duration;
    
}

-(void) updateCurrentTime{
    [self currentTimeForPlayer:self.avPlayer];
    [self durationTimeForPlayer:self.avPlayer];
    
}

-(void) updateUVMeter: (MyVUMeter *) myVU {
    [self.avRecorder updateMeters];
    CGFloat db = [self.avRecorder averagePowerForChannel:0];
    CGFloat peakDb = [self.avRecorder peakPowerForChannel:0];
    // db goes from -160.0 to 0.0, but iOS only goes from -120 to 0
    
    NSLog(@"db, peakDb: %f %f", db, peakDb);
    
    // with this conversion, the volume values should become 0.0 - 1.0
    myIdeaOfVolume = (db + dbRange) / dbRange;
    myIdeaOfPeakVolume = (peakDb + dbRange) / dbRange;
    
    myVU.volume = myIdeaOfVolume;
    myVU.peakVolume = myIdeaOfPeakVolume;
    [myVU setNeedsDisplay];
    }

-(void)prepareMeter{
    
    [self updateUVMeter:self.VUmeter];
   
}

- (void)prepareToRecord{
    
    
    NSTimeInterval ti=1.0/30.0;
    self.timer=[NSTimer scheduledTimerWithTimeInterval:ti target:self selector:@selector(prepareMeter) userInfo:nil repeats:YES];
    

    
      //      [self.btnRec setTitle:@"Stop" forState:UIControlStateNormal];
            
        NSLog(@"prepare to record.");
        //[self setSymbolnamed:@"record_image@2x"];
        
       
        
        AVAudioSession *audioSession=[AVAudioSession sharedInstance];
        
        //sharedInstance Returns the singleton audio session.
        
        [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        
        [audioSession setActive:YES error:nil];
        
        //    NSURL *url=[self getFileURL];
        //    NSLog(@"record url%@",url);
        
        NSURL *urluuid=[self getFileURL];
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
    self.avRecorder.meteringEnabled=YES;}

-(void)record{
        
        BOOL didStartRecord=[self.avRecorder record];
        if (!didStartRecord) 
            NSLog(@"faile to record");
        else 
            NSLog(@"Could record");
        
        }
    


- (void)play{
    
    
        if (playWasPaused) {
            
            [self.avPlayer play];
            NSLog(@"playing again");
            
            [self.btnPlay setTitle:@"PauseAgain" forState:UIControlStateNormal];
            playing=YES;}
        else{
            
            
            NSLog(@"start playing");
            // [self setSymbolnamed:@"play_image@2x"];
            
            
            //    NSURL *url = [self getFileURL];
            //    NSLog(@"Url to play: %@", url);
            
            NSURL *urlPlay=[self.uuids objectAtIndex:0];
            
            if (!playWasPaused || !self.avPlayer) {
                self.avPlayer=[[[AVAudioPlayer alloc]initWithContentsOfURL:urlPlay error:nil]autorelease];
                self.avPlayer.delegate = self;
                
                self.timer=[NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(updateCurrentTime) userInfo:self.avPlayer repeats:YES];
                
                
                [self.avPlayer play];
                [self currentTimeForPlayer:self.avPlayer];
                [self.btnPlay setTitle:@"Pause" forState:UIControlStateNormal];
               // playing=YES; 
            }
            
       }
        
    }
    


- (void)pausing{
    NSLog(@"paused");
    [self.btnPlay setTitle:@"PlayAgain" forState:UIControlStateNormal];
    [self.avPlayer pause];
   // playWasPaused=YES;
   // playing=NO;
    
    //[self setSymbolnamed:@"pause_image@2x"];
}

- (void)stopping{
    NSLog(@"Stopped recording");
    
        [self.avRecorder stop];
//        stopping=YES;
//        recording=NO;
    //[self setSymbolnamed:@"stop_image@2x"];
}

- (IBAction)sliderValue:(UISlider*)sender {
    
    self.slider=sender;
    
    

       
    self.timer = [NSTimer scheduledTimerWithTimeInterval:.1 target:self selector:@selector(processComplete:) userInfo:nil repeats:YES]; 
    
  
    
    
}

- (void)processComplete:(id)sender {
  
    [self updateCurrentTime];
    [self.timer invalidate];
}




@end
