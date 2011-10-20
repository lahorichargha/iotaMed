//
//  AudioRecording.h
//  iotaPad6
//
//  Created by Shiva on 10/18/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyVUMeter.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>

@interface AudioRecording:UIViewController <AVAudioPlayerDelegate,AVAudioRecorderDelegate>{

    double timePaused;
    
}

@property (retain, nonatomic) IBOutlet UIButton *btnRec;
@property (retain,nonatomic) IBOutlet UIButton *btnPlay;
@property (retain, nonatomic) NSMutableArray *uuids;
@property (retain, nonatomic) AVAudioPlayer *avPlayer;
@property (retain,nonatomic) AVAudioRecorder *avRecorder;
@property (retain,nonatomic) NSTimer *timer;
@property (nonatomic,retain) MyVUMeter *VUmeter;
@property (nonatomic, retain) UISlider *slider;
@property (nonatomic, retain) UILabel *labelCellCurrent;
@property (nonatomic,retain)UILabel *labelCellDuration;
@property (nonatomic) BOOL  playing;
@property (nonatomic) BOOL playWasPaused;
@property (nonatomic) BOOL recording;
@property (nonatomic) BOOL stopBool;
@property (nonatomic) BOOL didFinishPlay;
@property (nonatomic,assign) CGFloat myIdeaOfVolume;
@property (nonatomic,assign) CGFloat myIdeaOfPeakVolume;


- (void)prepareToRecord;
- (void)record;
- (void)play;
- (void)pausing;
- (void)stopping;
-(void) currentTimeForPlayer: (AVAudioPlayer *) p;
-(void) updateUVMeter: (MyVUMeter *) myVU;
-(void)prepareMeter;
- (IBAction)sliderValue:(UISlider*)sender;
-(void) durationTimeForPlayer:  (AVAudioPlayer *) p;
-(void) updateCurrentTime;
- (IBAction)sliderValue:(UISlider*)sender; 
-(void) labels;
@end
