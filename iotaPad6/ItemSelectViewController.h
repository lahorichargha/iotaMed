//
//  ItemSelectViewController.h
//  iotaPad6
//
//  Created by Martin Wehlou on 2011-10-09.
//  Copyright (c) 2011 MITM AB. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "ItemSelectControllerDelegate.h"
#import "AudioRecording.h"
#import <AVFoundation/AVAudioRecorder.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "MyVUMeter.h"

@class ItemTableCellString;

@interface ItemSelectViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>{
    double timePaused;
    
}

@property (nonatomic, assign) id <ItemSelectControllerDelegate> delegate;
@property (retain, nonatomic) IBOutlet UIButton *btnKeyboard;
@property (retain, nonatomic) IBOutlet UIButton *btnRec;
@property (retain,nonatomic) IBOutlet UIButton *btnPlay;
@property (retain, nonatomic) AudioRecording *audioRec;
@property (retain,nonatomic) AVAudioRecorder *avRec;
@property (retain, nonatomic) AVAudioPlayer *avPlay;
@property (retain, nonatomic)  MyVUMeter *vum;
@property (retain, nonatomic) NSTimer *timer;
@property (retain,nonatomic) IBOutlet UISlider *sliderItemSelect;
@property (nonatomic,retain) IBOutlet UILabel *currentLabelItemSelect;
@property (nonatomic,retain) IBOutlet UILabel *durationLabelItemSelect;

+ (CGSize)neededSizeForRows:(NSUInteger)rows;
- (IBAction)btnKeyboard:(id)sender;
-(IBAction)recording:(id)sender;
-(IBAction)playing:(id)sender;
-(void)updateMeter;
-(IBAction)sliderChanged:(id)sender;
@end
