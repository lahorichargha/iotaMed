//
//  ItemSelectViewController.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-10-09.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ItemSelectControllerDelegate.h"
#import "MyVUMeter.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>
#import <AVFoundation/AVFoundation.h>

@class ItemTableCellString;

@interface ItemSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,AVAudioPlayerDelegate,AVAudioRecorderDelegate>{
    BOOL  playWasPaused;
    BOOL recording;
    BOOL playing;
    BOOL stopping;
    double timePaused;
    UIButton *btnRec;
    UIButton *btnPlay;
}

@property (nonatomic, assign) id <ItemSelectControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *btnKeyboard;
@property (retain, nonatomic) IBOutlet UIButton *btnRec;
@property (retain,nonatomic) IBOutlet UIButton *btnPlay;
@property (nonatomic,retain) ItemTableCellString *itemString;
@property (nonatomic,retain) MyVUMeter *myVUmeter;
@property (retain, nonatomic) NSMutableArray *uuids;
@property (retain, nonatomic) AVAudioPlayer *avPlayer;
@property (retain,nonatomic) AVAudioRecorder *avRecorder;
@property (retain,nonatomic) NSTimer *timer;

+ (CGSize)neededSizeForRows:(NSUInteger)rows;
- (IBAction)btnKeyboard:(id)sender;
- (IBAction)recording:(id)sender;
- (IBAction)playing:(id)sender;
- (void)pausing;
- (void)stopping;

@end
