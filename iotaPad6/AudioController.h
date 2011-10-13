//
//  AudioController.h
//  iotaPad6
//
//  Created by Shiva on 10/12/11.
//  Copyright 2011 MITM AB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyVUMeter.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "ItemTableCellString.h"

@interface AudioController : UIViewController <AVAudioPlayerDelegate,AVAudioRecorderDelegate>{
    BOOL  playWasPaused;
    double timePaused;
}
@property (nonatomic,retain) MyVUMeter *myVUmeter;
@property (retain, nonatomic) NSMutableArray *uuids;
@property (retain, nonatomic) AVAudioPlayer *avPlayer;
@property (retain,nonatomic) AVAudioRecorder *avRecorder;
@property (retain,nonatomic) NSTimer *timer;
@property (retain,nonatomic) ItemTableCellString *itemString;

-(void) setSymbolnamed: (NSString *) fileName;
- (void)doRecord:(id)sender; 
- (void)doPause:(id)sender ;
- (void)doStop:(id)sender;
- (void)doPlay:(id)sender;
@end
